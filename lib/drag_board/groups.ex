defmodule DragBoard.Groups do
  alias Ecto.Multi
  alias DragBoard.Group
  alias DragBoard.Groups.GroupQueries
  alias DragBoard.Repo

  def list_groups() do
    GroupQueries.all()
    |> Repo.all()
  end

  def list_groups_with_boards() do
    GroupQueries.preload_boards_with_tasks()
    |> Repo.all()
  end

  def get_group(group_id) do
    GroupQueries.with_id(group_id)
    |> Repo.one()
  end

  def remove_group(group_id) do
    group = get_group(group_id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:remove_group, group)
    |> Repo.transaction()
  end

  def add_group(name) do
    changeset = Group.changeset(%Group{}, %{name: name})

    Multi.new()
    |> Multi.insert(:insert_group, changeset)
    |> Repo.transaction()
  end
end
