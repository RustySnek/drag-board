defmodule DragBoard.Groups.GroupQueries do
  alias DragBoard.BoardTasks.TaskQueries
  alias DragBoard.Boards.BoardQueries
  alias DragBoard.Group
  import Ecto.Query

  def all(query \\ base()) do
    query
  end

  def with_id(query \\ base(), group_id) do
    query
    |> where([group: group], group.id == ^group_id)
  end

  def preload_boards_with_tasks(query \\ base()) do
    query
    |> preload(boards: ^BoardQueries.preload_tasks(TaskQueries.get_tasks_in_asc_order()))
  end

  defp base do
    from(_ in Group, as: :group)
  end
end
