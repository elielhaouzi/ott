defmodule OTT.OneTimeTokens do
  @moduledoc false

  import Ecto.Query, only: [where: 3]
  import OTT.Extension.Elixir.Map, only: [maybe_put: 3]

  alias OTT.OneTimeTokens.OneTimeToken

  @spec generate_token!(map(), keyword()) :: binary
  @spec generate_token!(map()) :: binary
  def generate_token!(data, opts \\ []) when is_map(data) and is_list(opts) do
    expires_in_minutes = Keyword.get(opts, :expires_in_minutes)
    token_length = Keyword.get(opts, :token_length)

    %{data: data}
    |> maybe_put(:token_length, token_length)
    |> maybe_put(:expires_in_minutes, expires_in_minutes)
    |> create_one_time_token!()
    |> Map.get(:token)
  end

  @spec access_token_data(binary) :: map() | nil
  def access_token_data(token) when is_binary(token) do
    with(
      %OneTimeToken{data: data} = one_time_token <-
        get_valid_one_time_token_by_token(token),
      {:ok, %OneTimeToken{}} <- put_used_now(one_time_token)
    ) do
      data
    else
      nil -> nil
      {:error, %Ecto.Changeset{errors: [id: {"is stale", [stale: true]}]}} -> nil
    end
  end

  @spec generate_token(integer) :: binary
  def generate_token(length) when is_integer(length) and length > 0 do
    unfriendly_chars = ["_", "-"]

    replacement =
      [?0..?9, ?a..?z, ?A..?Z]
      |> Enum.flat_map(&Enum.to_list/1)
      |> Enum.random()
      |> List.wrap()
      |> to_string()

    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64(padding: false)
    |> String.replace(unfriendly_chars, replacement)
    |> binary_part(0, length)
  end

  defp get_valid_one_time_token_by_token(token) when is_binary(token) do
    utc_now = DateTime.utc_now()

    OneTimeToken
    |> where([ott], ott.token == ^token)
    |> where([ott], is_nil(ott.used_at))
    |> where([ott], is_nil(ott.revoked_at))
    |> where([ott], ott.expired_at >= ^utc_now)
    |> OTT.repo().one()
  end

  defp create_one_time_token!(attrs) do
    %OneTimeToken{}
    |> OneTimeToken.create_changeset(attrs)
    |> OTT.repo().insert!()
  end

  defp put_used_now(%OneTimeToken{} = one_time_token) do
    one_time_token
    |> OneTimeToken.update_changeset(%{used_at: DateTime.utc_now() |> DateTime.truncate(:second)})
    |> OTT.repo().update(stale_error_field: :id)
  end
end
