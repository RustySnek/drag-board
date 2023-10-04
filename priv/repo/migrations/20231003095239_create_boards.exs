defmodule DragBoard.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :name, :string
      add :group, :string

      timestamps()
    end
  end
end
