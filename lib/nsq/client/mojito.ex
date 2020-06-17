defmodule NSQ.Client.Mojito do
  @moduledoc "Http client using mojito"
  @behaviour NSQ.HTTP
  @compile {:inline, get: 3, post: 4}

  @impl true
  def get(url, headers \\ [], options \\ []) do
    case Mojito.get(url, headers, options) do
      {:ok, %Mojito.Response{
       body: body, headers: headers, status_code: status_code}} -> {:ok,  %{status_code: status_code, body: body, headers: headers}}
      {:error, _any} = res -> res
    end
  end

  @impl true
  def post(url, headers \\ [], payload  \\ "", options \\ []) do
    case Mojito.post(url, headers, payload, options) do
      {:ok, %Mojito.Response{
       body: body, headers: headers, status_code: status_code}} -> {:ok,  %{status_code: status_code, body: body, headers: headers}}
      {:error, _any} = res -> res
    end
  end
end
