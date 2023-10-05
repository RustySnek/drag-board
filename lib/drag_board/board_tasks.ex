defmodule DragBoard.BoardTasks do
  alias DragBoard.Boards
  alias DragBoard.BoardTask
  alias DragBoard.BoardTasks.TaskQueries
  alias DragBoard.Repo

  def get_task_by_id(task_id) do
    TaskQueries.with_id(task_id)
    |> Repo.one()
  end

  defp get_last_task_position(board) do
    # Returns a -1 if the there are no other tasks, so when new one is created its position will be 0.
    case length(board.board_tasks) do
      0 ->
        -1

      _ ->
        board.board_tasks
        |> hd()
        |> Map.get(:position)
    end
  end

  def add_task(name, board_id) do
    board = Boards.get_board_with_desc_tasks_by_id(board_id)

    last_position = get_last_task_position(board)

    board
    |> TaskQueries.new_board_task(name, last_position)
    |> Repo.insert!()
  end

  def move_leftover_tasks_from_above_down(old_position, new_position, task_id, board_id) do
    tasks_to_move =
      TaskQueries.all_by_board_id(board_id)
      |> TaskQueries.get_leftover_tasks_from_above(old_position, new_position, task_id)
      |> Repo.all()

    for task <- tasks_to_move do
      new_position = task.position - 1
      BoardTask.changeset(task, %{"position" => new_position})
    end
  end

  def move_leftover_tasks_from_below_up(old_position, new_position, task_id, board_id) do
    tasks_to_move =
      TaskQueries.all_by_board_id(board_id)
      |> TaskQueries.get_leftover_tasks_from_below(old_position, new_position, task_id)
      |> Repo.all()

    for task <- tasks_to_move do
      new_position = task.position + 1
      BoardTask.changeset(task, %{"position" => new_position})
    end
  end

  def move_task_board(previous_board_id, board_id, task_id, new_position, old_position) do
    _move_task =
      get_task_by_id(task_id)
      |> BoardTask.changeset(%{"position" => new_position, "board_id" => board_id})
      |> Repo.update!()

    tasks_to_move =
      TaskQueries.all_by_board_id(previous_board_id)
      |> TaskQueries.get_leftover_tasks_from_below_without_new_position(old_position, task_id)
      |> Repo.all()

    moved_tasks_in_previous_board =
      for task <- tasks_to_move do
        new_position = task.position - 1
        BoardTask.changeset(task, %{"position" => new_position})
      end

    tasks_to_move =
      TaskQueries.all_by_board_id(board_id)
      |> TaskQueries.get_leftover_tasks_from_above_without_old_position(new_position, task_id)
      |> Repo.all()

    moved_tasks_in_current_board =
      for task <- tasks_to_move do
        new_position = task.position + 1
        BoardTask.changeset(task, %{"position" => new_position})
      end

    Repo.transaction(fn ->
      Enum.each(moved_tasks_in_previous_board ++ moved_tasks_in_current_board, fn changeset ->
        case Repo.update(changeset) do
          {:ok, _updated_task} ->
            IO.puts("BoardTask updated successfully")

          {:error, changeset} ->
            IO.puts("BoardTask update failed: #{inspect(changeset.errors)}")
        end
      end)
    end)
  end

  def move_task_position(old_position, new_position, task_id, board_id) do
    _move_task =
      get_task_by_id(task_id)
      |> BoardTask.changeset(%{"position" => new_position})
      |> Repo.update!()

    moved_tasks =
      cond do
        old_position > new_position ->
          move_leftover_tasks_from_below_up(old_position, new_position, task_id, board_id)

        old_position < new_position ->
          move_leftover_tasks_from_above_down(old_position, new_position, task_id, board_id)

        true ->
          []
      end

    Repo.transaction(fn ->
      Enum.each(moved_tasks, fn changeset ->
        case Repo.update(changeset) do
          {:ok, _updated_task} ->
            IO.puts("BoardTask updated successfully")

          {:error, changeset} ->
            IO.puts("BoardTask update failed: #{inspect(changeset.errors)}")
        end
      end)
    end)
  end
end
