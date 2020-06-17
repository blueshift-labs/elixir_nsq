defmodule NSQ.Client.Jason do
  @moduledoc "Json client using jason"
  @behaviour NSQ.Json
  @compile {:inline, encode!: 2, decode: 2, decode!: 2}

  @impl true
  def encode!(any, options \\ []) do
    Jason.encode!(any, options)
  end

  @impl true
  def decode(any, options \\ []) do
    case Jason.decode(any, options) do
      {:ok, _any} = res -> res
      {:error, _any} = err -> err
      err -> {:error, err}
    end
  end

  @impl true
  def decode!(any, options \\ []) do
    Jason.decode!(any, options)
  end
end
