defmodule DragBoard.Boards do
  alias DragBoard.Group
  alias DragBoard.Repo
  alias DragBoard.Boards.BoardQueries
  alias DragBoard.BoardTasks.TaskQueries

  def get_board_by_id(board_id) do
    BoardQueries.with_id(board_id)
    |> Repo.one()
  end

  def get_board_with_desc_tasks_by_id(board_id) do
    BoardQueries.with_id(board_id)
    |> BoardQueries.preload_tasks(TaskQueries.get_tasks_in_desc_order())
    |> Repo.one()
  end

  def list_boards_from_group(group_id) do
    BoardQueries.from_group(group_id)
    |> BoardQueries.list_boards_with_tasks()
    |> Repo.all()
  end

  def list_boards() do
    BoardQueries.list_boards_with_tasks()
    |> Repo.all()
  end

  def remove_board(board_id) do
    BoardQueries.with_id(board_id)
    |> Repo.delete_all()
  end

  def add_board(name, group_id) do
    group = Repo.get(Group, group_id)

    new_board = Ecto.build_assoc(group, :boards, %{name: name})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:insert_new_board, new_board)
    |> Repo.transaction()
  end
end
