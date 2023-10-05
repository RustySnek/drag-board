defmodule DragBoard.Repo.Migrations.AddUniquePositionPerBoard do
  use Ecto.Migration

  def change do
    alter table(:board_tasks) do
      modify :position, :integer, null: false
    end
  end
end
