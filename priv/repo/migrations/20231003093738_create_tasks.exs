defmodule DragBoard.Repo.Migrations.CreateBoardTasks do
  use Ecto.Migration

  def change do
    create table(:board_tasks) do
      add :name, :string
      add :position, :integer

      timestamps()
    end
  end
end
