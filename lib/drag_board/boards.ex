defmodule DragBoard.Boards do
  alias DragBoard.Repo
  alias DragBoard.Boards.BoardQueries
  alias DragBoard.BoardTasks.TaskQueries
  alias DragBoard.Board

  def get_board_by_id(board_id) do
    BoardQueries.with_id(board_id)
    |> Repo.one()
  end

  def get_board_with_desc_tasks_by_id(board_id) do
    BoardQueries.with_id(board_id)
    |> BoardQueries.preload_tasks(TaskQueries.get_tasks_in_desc_order())
    |> Repo.one()
  end

  def list_boards() do
    BoardQueries.list_boards_with_tasks()
    |> Repo.all()
  end

  def remove_board(board_id) do
    BoardQueries.with_id(board_id)
    |> Repo.delete_all()
  end

  def add_board(name, group) do
    changeset =
      %Board{}
      |> Board.changeset(%{name: name, group: group})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:insert_board, changeset)
    |> Repo.transaction()
  end
end
