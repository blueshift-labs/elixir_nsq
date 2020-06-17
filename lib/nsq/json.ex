defmodule NSQ.Json do
  @moduledoc "Behaviour for json encoding and decoding"

  @callback encode!(any(), list()) :: String.t() | no_return
  @callback decode(iodata, list()) :: {:ok, String.t(), {:error, any()}}
  @callback decode!(iodata(), list()) :: any() | no_return
end
