defmodule OTT.TestRepo.Migrations.CreateOttTables do
  use Ecto.Migration

  def up do
    OTT.Migrations.V1.up()
  end

  def down do
    OTT.Migrations.V1.down()
  end
end
