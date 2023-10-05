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
  alias DragBoard.{Board, Repo}
  import Ecto.Query, only: [from: 2]

  def list_boards() do
    from(board in DragBoard.Board, select: board)
    |> DragBoard.Repo.all()
    |> DragBoard.Repo.preload(
      board_tasks: from(t in DragBoard.BoardTask, order_by: [asc: t.position])
    )
  end

  def add_board(name, group) do
    changeset =
      %Board{}
      |> Board.changeset(%{name: name, group: group})

    case Repo.insert(changeset) do
      {:ok, _board} -> {:ok, "Board added successfully"}
      {:error, changeset} -> {:error, "Failed to add board", changeset}
    end

    list_boards()
  end
end
