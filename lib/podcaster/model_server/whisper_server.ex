defmodule Podcaster.ModelServer.WhisperServer do
  require Logger

  @type transcription_chunk :: %{
          text: binary(),
          start_timestamp_seconds: float(),
          end_timestamp_seconds: float()
        }

  @type audio_to_chunks_return :: %{
          transcription: list(transcription_chunk()),
          transcription_processing_seconds: integer()
        }

  @spec child_spec(keyword()) :: Supervisor.child_spec()
  def child_spec(opts) do
    Nx.Serving.child_spec(name: __MODULE__, serving: load_serving(opts))
  end

  @doc """
  Convert audio to chunk. A chunk is a map that contains text and start/end timestamps.
  Takes path to audio file. If path contains "http" then it assumes path is url.
  """
  @spec audio_to_chunks(binary()) :: audio_to_chunks_return()
  def audio_to_chunks(audio_file) do
    serving_input =
      case String.contains?(audio_file, "http") do
        true -> {:file_url, audio_file}
        false -> {:file, audio_file}
      end

    start_time = DateTime.utc_now()
    transcription_output = Nx.Serving.batched_run(__MODULE__, serving_input)
    end_time = DateTime.utc_now()
    seconds = DateTime.diff(end_time, start_time)

    Logger.info("generated transcription", transcription_processing_seconds: seconds)

    %{
      transcription: transcription_output.chunks,
      transcription_processing_seconds: seconds
    }
  end

  @spec load_serving(keyword()) :: Nx.Serving.t()
  defp load_serving(opts) do
    stream = Keyword.get(opts, :stream, false)
    chunk_num_seconds = Keyword.get(opts, :chunk_num_seconds, 30)
    batch_size = Keyword.get(opts, :batch_size, 10)

    whisper = {:hf, "openai/whisper-tiny"}
    {:ok, model_info} = Bumblebee.load_model(whisper, backend: EXLA.Backend)
    {:ok, featurizer} = Bumblebee.load_featurizer(whisper)
    {:ok, tokenizer} = Bumblebee.load_tokenizer(whisper)
    {:ok, generation_config} = Bumblebee.load_generation_config(whisper)

    serving =
      Bumblebee.Audio.speech_to_text_whisper(model_info, featurizer, tokenizer, generation_config,
        chunk_num_seconds: chunk_num_seconds,
        timestamps: :segments,
        defn_options: [compiler: EXLA, lazy_transfers: :never],
        compile: [batch_size: batch_size],
        stream: stream
      )

    serving
    |> Nx.Serving.client_preprocessing(fn
      {:file_url, url} ->
        {:ok, file_path} = download_file(url)

        {stream, info} = serving.client_preprocessing.({:file, file_path})

        {stream, [{:file_needs_disposal, file_path}] ++ Tuple.to_list(info)}

      input ->
        serving.client_preprocessing.(input)
    end)
    |> Nx.Serving.client_postprocessing(fn
      output_or_stream, [{:file_needs_disposal, file_path} | rest] ->
        File.rm(file_path)

        serving.client_postprocessing.(output_or_stream, List.to_tuple(rest))

      output_or_stream, _info ->
        serving.client_postprocessing.(output_or_stream, {})
    end)
  end

  defp download_file(url) do
    download_directory = Path.join(System.tmp_dir!(), "downloads")
    File.mkdir_p!(download_directory)

    filename = URI.parse(url) |> Map.fetch!(:path) |> Path.basename()
    out_path = Path.join(download_directory, filename)

    with {:ok, _res} <- Req.get(url: url, into: File.stream!(out_path)) do
      {:ok, out_path}
    end
  end
end
