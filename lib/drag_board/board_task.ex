defmodule DragBoard.BoardTask do
  use Ecto.Schema
  import Ecto.Changeset

  schema "board_tasks" do
    field :name, :string
    field :position, :integer
    belongs_to :board, DragBoard.Board
    timestamps()
  end

  @doc false
  def changeset(board_task, attrs) do
    board_task
    |> cast(attrs, [:name, :position, :board_id])
    |> validate_required([:name, :position])
    |> validate_length(:name, min: 3)
    |> unique_constraint([:position, :board_id])
  end
end
