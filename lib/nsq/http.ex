defmodule NSQ.HTTP do
  @moduledoc "Behaviour for http requests"

  @type response :: %{status_code: pos_integer(), body: String.t(), headers: list()}

  @callback get(String.t(), list(), Keyword.t()) :: {:ok, response} | {:error, any()}
  @callback post(String.t(), list(), String.t(), Keyword.t()) :: {:ok, response} | {:error, any()}
end
