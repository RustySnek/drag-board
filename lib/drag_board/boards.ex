defmodule DragBoard.Boards do
  alias DragBoard.Repo
  alias DragBoard.Boards.BoardQueries
  alias DragBoard.BoardTasks.TaskQueries
  alias DragBoard.Board

  def get_board_by_id(board_id) do
    BoardQueries.with_id(board_id)
    |> Repo.all()
  end

  def get_board_with_desc_tasks_by_id(board_id) do
    BoardQueries.with_id(board_id)
    |> Repo.one()
    |> Repo.preload(board_tasks: TaskQueries.get_tasks_in_desc_order())
  end

  def list_boards() do
    BoardQueries.all()
    |> Repo.all()
    |> Repo.preload(board_tasks: TaskQueries.get_tasks_in_asc_order())
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
