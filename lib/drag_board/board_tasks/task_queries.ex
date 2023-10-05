defmodule DragBoard.BoardTasks.TaskQueries do
  alias DragBoard.BoardTask
  import Ecto.Query

  def with_id(query \\ base(), id) do
    query
    |> where([board_task: task], task.id == ^id)
  end

  def all_by_board_id(query \\ base(), board_id) do
    query
    |> where([board_task: board_task], board_task.board_id == ^board_id)
  end

  def get_tasks_in_asc_order(query \\ base()) do
    query
    |> order_by([board_task: board_task], asc: board_task.position)
  end

  def get_tasks_in_desc_order(query \\ base()) do
    query
    |> order_by([board_task: board_task], desc: board_task.position)
  end

  def get_leftover_tasks_from_below_without_new_position(
        query \\ base(),
        old_position,
        moved_task_id
      ) do
    query
    |> where(
      [board_task: t],
      t.id != ^moved_task_id and t.position >= ^old_position
    )
  end

  def get_leftover_tasks_from_above(query \\ base(), old_position, new_position, moved_task_id) do
    query
    |> get_leftover_tasks_from_below_without_new_position(old_position, moved_task_id)
    |> where(
      [board_task: t],
      t.position <= ^new_position
    )
  end

  def get_leftover_tasks_from_above_without_old_position(
        query \\ base(),
        new_position,
        moved_task_id
      ) do
    query
    |> where(
      [board_task: t],
      t.id != ^moved_task_id and t.position >= ^new_position
    )
  end

  def get_leftover_tasks_from_below(query \\ base(), old_position, new_position, moved_task_id) do
    query
    |> get_leftover_tasks_from_above_without_old_position(new_position, moved_task_id)
    |> where(
      [board_task: t],
      t.position <= ^old_position
    )
  end

  def new_board_task(board, name, last_task_position) do
    Ecto.build_assoc(board, :board_tasks, %{name: name, position: last_task_position + 1})
  end

  def base do
    from(_ in BoardTask, as: :board_task)
  end
end
