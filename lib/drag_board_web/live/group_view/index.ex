defmodule DragBoardWeb.GroupView.Index do
  alias DragBoard.Boards
  alias DragBoard.BoardTasks
  use DragBoardWeb, :live_view

  @impl true
  def mount(%{"id" => group_id}, _session, socket) do
    boards = Boards.list_boards_from_group(group_id)

    socket =
      socket
      |> assign(:group_id, group_id)
      |> assign(:boards, boards)

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "reposition",
        %{
          "old" => old,
          "new" => new,
          "id" => id,
          "to" => %{"list_id" => board_id},
          "from" => %{"list_id" => from_board_id}
        },
        socket
      ) do
    if from_board_id != board_id do
      DragBoard.BoardTasks.move_task_board(from_board_id, board_id, id, new, old)
    else
      if new != old do
        DragBoard.BoardTasks.move_task_position(old, new, id, board_id)
      end
    end

    socket = assign(socket, :boards, Boards.list_boards_from_group(socket.assigns.group_id))

    {:noreply, socket}
  end

  def handle_event("remove_board", %{"value" => board_id}, socket) do
    _remove_board = Boards.remove_board(board_id)
    boards = Boards.list_boards_from_group(socket.assigns.group_id)

    socket =
      socket
      |> assign(:boards, boards)

    {:noreply, socket}
  end

  def handle_event("add_board", %{"board" => %{"name" => name}}, socket) do
    _add_board = Boards.add_board(name, socket.assigns.group_id)
    boards = Boards.list_boards_from_group(socket.assigns.group_id)

    socket =
      socket
      |> assign(:boards, boards)

    {:noreply, socket}
  end

  def handle_event("remove_task", %{"value" => task_id}, socket) do
    _remove_task = BoardTasks.remove_task(task_id)
    boards = Boards.list_boards_from_group(socket.assigns.group_id)
    socket = assign(socket, :boards, boards)
    {:noreply, socket}
  end

  def handle_event("add_item", %{"item" => %{"name" => name}, "board_id" => board_id}, socket) do
    if String.length(name) < 3 do
      {:noreply, socket}
    else
      BoardTasks.add_task(name, board_id)
      boards = Boards.list_boards_from_group(socket.assigns.group_id)

      socket =
        socket
        |> assign(:boards, boards)

      {:noreply, socket}
    end
  end

  defp board(assigns) do
    ~H"""
    <div class="bg-[#1f1f1f] py-4 rounded-lg flex h-30 w-full max-w-xl lg:w-fit">
      <div class=" mx-auto max-w-7xl px-4 space-y-4">
        <div class="font-bold flex-col text-center space-y-3 lg:flex items-center gap-x-4 truncate">
          <span>
            <%= @list_name %>
          </span>
          <div class="flex">
            <button
              type="button"
              phx-click="remove_board"
              value={@id}
              class="w-10 scale-125 text-red-700 -mt-2"
            >
              <.icon name="hero-x-mark" />
            </button>
            <form phx-submit="add_item" class="space-x-2">
              <input value={@id} name="board_id" class="hidden" />
              <input class="rounded-lg bg-[#121212]" type="text" name="item[name]" placeholder="name" />
              <button
                class="bg-green-600 hover:brightness-125 transition px-4 py-2 rounded-lg"
                type="submit"
              >
                Add Item
              </button>
            </form>
          </div>
        </div>
        <div
          id={"#{@id}-items"}
          class="space-y-2 h-full"
          phx-hook="Sortable"
          data-list_id={@id}
          data-group={@group_id}
        >
          <div
            :for={item <- @list}
            id={"#{@id}-#{item.id}"}
            data-id={item.id}
            class="
         drag-item:focus-within:ring-0 drag-item:focus-within:ring-offset-0
         drag-ghost:bg-zinc-600 drag-ghost:border-0 drag-ghost:rounded-xl drag-ghost:ring-0
         "
          >
            <div class="flex drag-ghost:opacity-0 border-2 border-zinc-700 rounded-lg pl-5 h-14 select-none">
              <div class="flex-auto self-center text-white">
                <%= item.name %>
              </div>
              <button
                type="button"
                phx-click="remove_task"
                value={item.id}
                class="w-10 -mt-1 flex-none"
              >
                <.icon name="hero-x-mark" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
