defmodule DragBoardWeb.Index do
  alias DragBoard.Boards
  alias DragBoard.BoardTasks
  use DragBoardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    boards = DragBoard.Boards.list_boards()

    socket =
      socket
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

    socket = assign(socket, :boards, Boards.list_boards())

    {:noreply, socket}
  end

  def handle_event("remove_board", %{"value" => board_id}, socket) do
    _remove_board = Boards.remove_board(board_id)
    boards = Boards.list_boards()

    socket =
      socket
      |> assign(:boards, boards)

    {:noreply, socket}
  end

  def handle_event("add_board", %{"board" => %{"name" => name, "group" => group}}, socket) do
    if String.length(name) < 3 do
      {:noreply, socket}
    else
      _add_board = Boards.add_board(name, group)
      boards = Boards.list_boards()

      socket =
        socket
        |> assign(:boards, boards)

      {:noreply, socket}
    end
  end

  def handle_event("remove_task", %{"value" => task_id}, socket) do
    _remove_task = BoardTasks.remove_task(task_id)
    boards = Boards.list_boards()
    socket = assign(socket, :boards, boards)
    {:noreply, socket}
  end

  def handle_event("add_item", %{"item" => %{"name" => name}, "board_id" => board_id}, socket) do
    if String.length(name) < 3 do
      {:noreply, socket}
    else
      BoardTasks.add_task(name, board_id)
      boards = Boards.list_boards()

      socket =
        socket
        |> assign(:boards, boards)

      {:noreply, socket}
    end
  end

  defp board(assigns) do
    ~H"""
    <div class="bg-gray-100 py-4 rounded-lg flex h-30">
      <div class=" mx-auto max-w-7xl px-4 space-y-4">
        <.header>
          <%= @list_name %>

          <form phx-submit="add_item">
            <input value={@id} name="board_id" class="hidden" />
            <input type="text" name="item[name]" placeholder="name" />
            <.button type="submit">Add Item</.button>
          </form>
        </.header>
        <div
          id={"#{@id}-items"}
          class="space-y-2 h-full"
          phx-hook="Sortable"
          data-list_id={@id}
          data-group={@group}
        >
          <div
            :for={item <- @list}
            id={"#{@id}-#{item.id}"}
            data-id={item.id}
            class="
          max-w-md 
         drag-item:focus-within:ring-0 drag-item:focus-within:ring-offset-0
         drag-ghost:bg-zinc-300 drag-ghost:border-0 drag-ghost:ring-0
         "
          >
            <div class="flex drag-ghost:opacity-0 border-2 pl-5 h-14 select-none">
              <div class="flex-auto self-center text-zinc-900">
                <%= item.position %>
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
      <button
        type="button"
        phx-click="remove_board"
        value={@id}
        class="w-10 scale-125 -mt-1 self-start"
      >
        <.icon name="hero-x-mark" />
      </button>
    </div>
    """
  end
end
