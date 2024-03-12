defmodule OTT.Extension.Elixir.Map do
  @moduledoc false

  def maybe_put(map, key, value) do
    if value, do: Map.put(map, key, value), else: map
  end
end
