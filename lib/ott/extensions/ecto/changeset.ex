defmodule OTT.Extensions.Ecto.Changeset do
  @moduledoc false

  @doc """
  A helper that allows to apply function on a changeset only if it is valid.
  It returns the changeset
  """
  @spec on_valid_changeset(Ecto.Changeset.t(), (Ecto.Changeset.t() -> Ecto.Changeset.t())) ::
          Ecto.Changeset.t()
  def on_valid_changeset(%Ecto.Changeset{} = changeset, fun)
      when is_function(fun) do
    if changeset.valid? do
      %Ecto.Changeset{} = fun.(changeset)
    else
      changeset
    end
  end
end
