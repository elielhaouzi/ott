defmodule OTT.TestRepo do
  use Ecto.Repo,
    otp_app: :ott,
    adapter: Ecto.Adapters.Postgres
end
