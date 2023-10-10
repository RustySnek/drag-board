defmodule DragBoard.Boards.BoardQueries do
  import Ecto.Query
  alias DragBoard.BoardTasks.TaskQueries
  alias DragBoard.Board

  def all(query \\ base()), do: query

  def from_group(query \\ base(), group_id) do
    query
    |> where([board: board], board.group_id == ^group_id)
  end

  def list_boards_with_tasks(query \\ base()) do
    query
    |> preload_tasks(TaskQueries.get_tasks_in_asc_order())
  end

  def preload_tasks(query \\ base(), preload_query) do
    query
    |> preload(board_tasks: ^preload_query)
  end

  def with_id(query \\ base(), board_id) do
    query
    |> where([board: board], board.id == ^board_id)
  end

  defp base do
    from(_ in Board, as: :board)
  end
end
