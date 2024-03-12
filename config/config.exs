import Config

if(Mix.env() == :test) do
  config :logger, level: System.get_env("EX_LOG_LEVEL", "debug") |> String.to_atom()

  config :ott, ecto_repos: [OTT.TestRepo]

  config :ott, OTT.TestRepo,
    # url: System.get_env("DATABASE_URL"),
    url: "ecto://postgres:postgres@127.0.0.1:5432/ott",
    show_sensitive_data_on_connection_error: true,
    pool: Ecto.Adapters.SQL.Sandbox

  config :ott,
    repo: OTT.TestRepo
end
