# OTT

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/elielhaouzi/ott/CI?cacheSeconds=3600&style=flat-square)](https://github.com/elielhaouzi/ott/actions) [![GitHub issues](https://img.shields.io/github/issues-raw/elielhaouzi/ott?style=flat-square&cacheSeconds=3600)](https://github.com/elielhaouzi/ott/issues) [![License](https://img.shields.io/badge/license-MIT-brightgreen.svg?cacheSeconds=3600?style=flat-square)](http://opensource.org/licenses/MIT) [![Hex.pm](https://img.shields.io/hexpm/v/ott?style=flat-square)](https://hex.pm/packages/ott) [![Hex.pm](https://img.shields.io/hexpm/dt/ott?style=flat-square)](https://hex.pm/packages/ott)

A One-Time Token (OTT) is a unique and time-sensitive authentication mechanism used for secure login processes or transactions, ensuring each token is single-use only.

This package facilitates the creation and management of OTTs, empowering developers to seamlessly integrate this robust security measure into their applications.

## Installation

OTT is published on [Hex](https://hex.pm/packages/ott). The package can be installed by adding `ott` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ott, "~> 0.1.0"}
  ]
end
```

After the packages are installed you must create a database migration to add the ott tables to your database:

```elixir
defmodule MyApp.Repo.Migrations.AddOTTTables do
  use Ecto.Migration

  def up do
    OTT.Migrations.V1.up()
  end

  def down do
    OTT.Migrations.V1.down()
  end
end
```

Now, run the migration to create the table:

```sh
mix ecto.migrate
```

## Usage

```elixir
iex(1)> OTT.generate_token!(%{"user_id" => 1})
"xDkfMo23dm"
iex(2)> OTT.access_token_data("xDkfMo23dm")
%{"user_id" => 1}
iex(3)> OTT.access_token_data("xDkfMo23dm")
nil
```
