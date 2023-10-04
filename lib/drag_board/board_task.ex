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
  end
end

defmodule DragBoard.BoardTasks do
  alias DragBoard.Board
  alias DragBoard.Repo
  alias DragBoard.BoardTask
  import Ecto.Query

  def add_task(name, board_id) do
    board =
      Repo.get(Board, board_id)
      |> Repo.preload(board_tasks: from(t in BoardTask, order_by: [desc: t.position]))

    last_position =
      if length(board.board_tasks) > 0 do
        hd(board.board_tasks).position
      else
        -1
      end

    new_task = Ecto.build_assoc(board, :board_tasks, %{name: name, position: last_position + 1})
    Repo.insert!(new_task)
  end

  def move_leftover_tasks_down(old_position, new_position, task_id, board_id) do
    query =
      from t in BoardTask,
        where:
          t.position <= ^new_position and t.id != ^task_id and t.position >= ^old_position and
            t.board_id == ^board_id

    tasks_to_move = Repo.all(query)

    for task <- tasks_to_move do
      new_position = task.position - 1
      BoardTask.changeset(task, %{"position" => new_position})
    end
  end

  def move_leftover_tasks_up(old_position, new_position, task_id, board_id) do
    query =
      from t in BoardTask,
        where:
          t.position >= ^new_position and t.id != ^task_id and t.position <= ^old_position and
            t.board_id == ^board_id

    tasks_to_move = Repo.all(query)

    for task <- tasks_to_move do
      new_position = task.position + 1
      BoardTask.changeset(task, %{"position" => new_position})
    end
  end

  def move_task_board(previous_board_id, board_id, task_id, new_position, old_position) do
    moved_task = Repo.get(BoardTask, task_id)

    changeset =
      BoardTask.changeset(moved_task, %{"position" => new_position, "board_id" => board_id})

    IO.inspect(changeset)
    Repo.update!(changeset)

    query_previous_board =
      from t in BoardTask,
        where:
          t.id != ^task_id and t.position >= ^old_position and
            t.board_id == ^previous_board_id

    tasks_to_move = Repo.all(query_previous_board)

    moved_tasks =
      for task <- tasks_to_move do
        new_position = task.position - 1
        BoardTask.changeset(task, %{"position" => new_position})
      end

    query_current_board =
      from t in BoardTask,
        where:
          t.position >= ^new_position and t.id != ^task_id and
            t.board_id == ^board_id

    moved_tasks_in_current_board =
      for task <- Repo.all(query_current_board) do
        new_position = task.position + 1
        BoardTask.changeset(task, %{"position" => new_position})
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

    Repo.transaction(fn ->
      Enum.each(moved_tasks_in_current_board, fn changeset ->
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
    moved_task = Repo.get(BoardTask, task_id)
    changeset = BoardTask.changeset(moved_task, %{"position" => new_position})
    Repo.update!(changeset)

    moved_tasks =
      cond do
        old_position > new_position ->
          move_leftover_tasks_up(old_position, new_position, task_id, board_id)

        old_position < new_position ->
          move_leftover_tasks_down(old_position, new_position, task_id, board_id)

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
