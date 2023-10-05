defmodule DragBoard.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :name, :string
    field :group, :string
    has_many :board_tasks, DragBoard.BoardTask
    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :group])
    |> validate_required([:name, :group])
  end
end
