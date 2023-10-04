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

defmodule DragBoard.Boards do
  import Ecto.Query, only: [from: 2]

  def list_boards() do
    from(board in DragBoard.Board, select: board)
    |> DragBoard.Repo.all()
    |> DragBoard.Repo.preload(
      board_tasks: from(t in DragBoard.BoardTask, order_by: [asc: t.position])
    )
  end
end
