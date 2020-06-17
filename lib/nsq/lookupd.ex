defmodule NSQ.Lookupd do
  @json Application.get_env(:elixir_nsq, :json_module)
  @http Application.get_env(:elixir_nsq, :http_module)
  alias NSQ.Connection, as: C
  require Logger

  @typedoc """
  All lookupd responses should return a map with these values. If the response
  is not of that form, it should be normalized into that form.
  """
  @type response :: %{
          data: binary,
          headers: [any],
          status_code: integer,
          status_txt: binary
        }

  @spec nsqds_with_topic([C.host_with_port()], String.t()) :: [C.host_with_port()]
  def nsqds_with_topic(lookupds, topic) do
    responses = Enum.map(lookupds, &topics_from_lookupd(&1, topic))

    nsqds =
      Enum.map(responses, fn response ->
        Enum.map(response["producers"] || [], fn producer ->
          if producer do
            {producer["broadcast_address"], producer["tcp_port"]}
          else
            nil
          end
        end)
      end)

    nsqds
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
  end

  @spec topics_from_lookupd(C.host_with_port(), String.t()) :: response
  def topics_from_lookupd({host, port}, topic) do
    lookupd_url = "http://#{host}:#{port}/lookup?topic=#{topic}"
    headers = [{"Accept", "application/vnd.nsq; version=1.0"}]

    case @http.get(lookupd_url, headers) do
      {:ok, %{status_code: 200, body: body, headers: headers}} ->
        normalize_200_response(headers, body)

      {:ok, %{status_code: 404}} ->
        %{} |> normalize_response

      {:ok, %{status_code: status, body: body}} ->
        Logger.error("Unexpected status code from #{lookupd_url}: #{status}")

        %{status_code: status, data: body}
        |> normalize_response

     {:error, error} ->
        Logger.error("Error connecting to #{lookupd_url}: #{inspect(error)}")
        normalize_response(%{})
    end
  end

  @spec normalize_200_response([any], binary) :: response
  defp normalize_200_response(headers, body) do
    body = if body == nil || body == "", do: "{}", else: body

    maybe_header = Enum.find(headers, {"", ""}, fn
      {str, _val} -> str == "x-nsq-content-type"
      _ -> false
    end)

    if elem(maybe_header, 1) == "nsq; version=1.0" do
      @json.decode!(body)
      |> normalize_response
    else
      %{status_code: 200, status_txt: "OK", data: body}
      |> normalize_response
    end
  end

  @spec normalize_response(map) :: response
  defp normalize_response(m) do
    Map.merge(
      %{
        status_code: nil,
        status_txt: "",
        data: "",
        headers: []
      },
      m
    )
  end
end
