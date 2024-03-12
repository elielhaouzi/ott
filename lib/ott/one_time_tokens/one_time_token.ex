defmodule OTT.OneTimeTokens.OneTimeToken do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset,
    only: [
      cast: 3,
      fetch_field!: 2,
      optimistic_lock: 2,
      put_change: 3,
      unique_constraint: 2,
      validate_number: 3,
      validate_required: 2
    ]

  import OTT.Extensions.Ecto.Changeset, only: [on_valid_changeset: 2]

  @type t :: %__MODULE__{
          data: map,
          expired_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          revoked_at: DateTime.t() | nil,
          scope: binary | nil,
          token: binary,
          updated_at: DateTime.t(),
          used_at: DateTime.t() | nil
        }

  schema "one_time_tokens" do
    field(:data, :map)
    field(:expires_in_minutes, :integer, virtual: true, default: OTT.default_expires_in_minutes())
    field(:expired_at, :utc_datetime)
    field(:lock_version, :integer, default: 1)
    field(:revoked_at, :utc_datetime)
    field(:scope, :string)
    field(:token, :string)
    field(:token_length, :integer, virtual: true, default: OTT.default_token_length())
    field(:used_at, :utc_datetime)

    timestamps()
  end

  @doc false
  @spec create_changeset(OneTimeToken.t(), map()) :: Ecto.Changeset.t()
  def create_changeset(%__MODULE__{} = one_time_token, attrs) do
    one_time_token
    |> cast(attrs, [
      :data,
      :expires_in_minutes,
      :scope,
      :token_length
    ])
    |> validate_required([:data, :expires_in_minutes, :token_length])
    |> validate_number(:token_length, greater_than_or_equal_to: 5, less_than_or_equal_to: 100)
    |> validate_number(:expires_in_minutes, greater_than_or_equal_to: 1)
    |> unique_constraint([:token])
    |> on_valid_changeset(&put_token/1)
    |> on_valid_changeset(&put_expired_at/1)
  end

  @doc false
  @spec update_changeset(OneTimeToken.t(), map()) :: Ecto.Changeset.t()
  def update_changeset(%__MODULE__{} = one_time_token, attrs) do
    one_time_token
    |> cast(attrs, [:revoked_at, :used_at])
    |> optimistic_lock(:lock_version)
  end

  defp put_token(%Ecto.Changeset{valid?: true} = changeset) do
    token_length = fetch_field!(changeset, :token_length)

    changeset
    |> put_change(:token, OTT.OneTimeTokens.generate_token(token_length))
  end

  defp put_expired_at(%Ecto.Changeset{valid?: true} = changeset) do
    expires_in_minutes = fetch_field!(changeset, :expires_in_minutes)

    expired_at =
      DateTime.utc_now()
      |> DateTime.add(expires_in_minutes, :minute)
      |> DateTime.truncate(:second)

    changeset
    |> put_change(:expired_at, expired_at)
  end
end
