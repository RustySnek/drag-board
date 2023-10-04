defmodule DragBoardWeb.Index do
  use DragBoardWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    boards = DragBoard.Boards.list_boards()

    socket =
      socket
      |> assign(:boards, boards)

    {:ok, socket}
  end

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

    {:noreply, socket}
  end

  def handle_event("add_item", %{"item" => %{"name" => name}, "board_id" => board_id}, socket) do
    if String.length(name) < 3 do
      {:noreply, socket}
    else
      DragBoard.BoardTasks.add_task(name, board_id)
      boards = DragBoard.Boards.list_boards()

      socket =
        socket
        |> assign(:boards, boards)

      {:noreply, socket}
    end
  end

  defp list_component(assigns) do
    ~H"""
    <div class="bg-gray-100 py-4 rounded-lg">
      <div class="space-y-5 mx-auto max-w-7xl px-4 space-y-4">
        <.header>
          <%= @list_name %>

          <form phx-submit="add_item">
            <input value={@id} name="board_id" class="hidden" />
            <input type="text" name="item[name]" id="item_name" />
            <.button type="submit">Add Item</.button>
          </form>
        </.header>
        <div
          id={"#{@id}-items"}
          class="space-y-2"
          phx-hook="Sortable"
          data-list_id={@id}
          data-group={@group}
        >
          <div
            :for={item <- @list}
            id={"#{@id}-#{item.id}"}
            data-id={item.id}
            class="
         drag-item:focus-within:ring-0 drag-item:focus-within:ring-offset-0
         drag-ghost:bg-zinc-300 drag-ghost:border-0 drag-ghost:ring-0
         "
          >
            <div class="flex drag-ghost:opacity-0 border-2 select-none">
              <button type="button" class="w-10">
                <.icon
                  name="hero-check-circle"
                  class={[
                    "w-7 h-7"
                  ]}
                />
              </button>
              <div class="flex-auto block text-sm leading-6 text-zinc-900">
                <%= item.name %>
              </div>
              <button type="button" class="w-10 -mt-1 flex-none">
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
