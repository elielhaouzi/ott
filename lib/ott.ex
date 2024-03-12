defmodule OTT do
  @moduledoc """
  Documentation for `OTT`.
  """
  alias OTT.OneTimeTokens

  @doc """
  Generates a one-time token for the specified data.

  ## Options

    * `:expires_in_minutes` - the duration of validity for the token in minutes.
      Defaults to 5 minutes.
    * `:token_length` - the length of the generated token. Defaults to 10 chars.

  """
  @spec generate_token!(map(), keyword()) :: binary()
  @spec generate_token!(map()) :: binary()
  defdelegate generate_token!(data, opts \\ []), to: OneTimeTokens

  @doc """
  Access the token data.

  Returns the data associated with the token only if the token has not been used and has not been revoked.
  Otherwise, it returns `nil`.

  """
  @spec access_token_data(binary) :: map() | nil
  defdelegate access_token_data(token), to: OneTimeTokens

  @doc false
  @spec repo() :: any()
  def repo(), do: Application.fetch_env!(:ott, :repo)

  @doc false
  @spec default_token_length() :: integer
  def default_token_length(), do: Application.get_env(:ott, :default_token_length, 10)

  @doc false
  @spec default_expires_in_minutes() :: integer
  def default_expires_in_minutes(), do: Application.get_env(:ott, :default_expires_in_minutes, 5)
end
