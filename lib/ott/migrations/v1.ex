defmodule OTT.Migrations.V1 do
  @moduledoc false

  use Ecto.Migration

  def up do
    create_one_time_tokens_table()
  end

  def down do
    drop_one_time_tokens_table()
  end

  defp create_one_time_tokens_table() do
    create table(:one_time_tokens) do
      add(:data, :json, null: false)
      add(:expired_at, :utc_datetime, null: false)
      add(:lock_version, :integer, default: 1)
      add(:revoked_at, :utc_datetime, null: true)
      add(:scope, :string, null: true)
      add(:token, :string, null: false)
      add(:used_at, :utc_datetime, null: true)
      timestamps()
    end

    create(unique_index(:one_time_tokens, [:token, :used_at, :revoked_at, :expired_at]))
  end

  defp drop_one_time_tokens_table do
    drop(table(:one_time_tokens))
  end
end
