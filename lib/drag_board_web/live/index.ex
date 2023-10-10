defmodule DragBoardWeb.Index do
  alias DragBoard.Groups
  use DragBoardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    groups = Groups.list_groups_with_boards()
    socket = socket |> assign(:groups, groups)
    {:ok, socket}
  end

  @impl true
  def handle_event(
        "reposition",
        %{
          "old" => old,
          "new" => new,
          "id" => id,
          "to" => %{"list_id" => list_id},
          "from" => from
        },
        socket
      ) do
    if list_id == "trash" do
      Groups.remove_group(id)
    end

    {:noreply, assign(socket, :groups, Groups.list_groups_with_boards())}
  end

  def handle_event("add_group", %{"name" => name}, socket) do
    _add_group = Groups.add_group(name)
    groups = Groups.list_groups_with_boards()

    socket = socket |> assign(:groups, groups)
    {:noreply, socket}
  end

  def handle_event("remove_group", %{"value" => group_id}, socket) do
    _remove_group = Groups.remove_group(group_id)
    groups = Groups.list_groups_with_boards()
    socket = socket |> assign(:groups, groups)
    {:noreply, socket}
  end

  defp add_group_form(assigns) do
    ~H"""
    <form phx-submit="add_group" class="text-center space-x-4 text-white">
      <input class="bg-[#121212] rounded-lg" type="text" name="name" placeholder="name" />

      <button class="bg-green-600 hover:brightness-125 transition px-4 py-2 rounded-lg" type="submit">
        Add Group
      </button>
    </form>
    """
  end

  defp board_task(assigns) do
    ~H"""
    <div class="truncate">
      <%= @name %>
    </div>
    """
  end

  defp board(assigns) do
    ~H"""
    <div class="w-32 
    ">
      <div class="font-semibold ">
        <%= @name %>
      </div>
      <div class=" rounded-lg border-gray-300 border px-8 py-1 mt-1
        ">
        <.board_task :for={task <- @tasks} name={task.name} />
      </div>
    </div>
    """
  end

  defp group(assigns) do
    ~H"""
    <a
      href={~p"/boards/#{@group_id}"}
      id={"#{@group_id}-group"}
      data-id={@group_id}
      class="rounded-lg  text-white bg-[#1f1f1f] py-2 min-w-[15%] h-44 text-center "
    >
      <div class="font-bold border-b border-gray-600 pb-2">
        <%= @name %>
      </div>
      <div class="flex justify-evenly space-x-4 my-4 mx-4">
        <.board
          :for={board <- @boards}
          name={board.name}
          id={board.id}
          tasks={board.board_tasks |> Enum.take(3)}
        >
        </.board>
      </div>
    </a>
    """
  end
end
