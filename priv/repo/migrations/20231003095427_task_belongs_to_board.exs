defmodule DragBoard.Repo.Migrations.BoardTaskBelongsToBoard do
  use Ecto.Migration

  def change do
    alter table(:board_tasks) do
      add :board_id, references(:boards)
    end
  end
end
