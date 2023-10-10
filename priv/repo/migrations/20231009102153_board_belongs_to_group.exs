defmodule DragBoard.Repo.Migrations.BoardBelongsToGroup do
  use Ecto.Migration

  def change do
    alter table(:boards) do
      add :group_id, references(:groups, on_delete: :delete_all), null: false
    end
  end
end
