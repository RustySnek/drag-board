defmodule DragBoard.Repo do
  use Ecto.Repo,
    otp_app: :drag_board,
    adapter: Ecto.Adapters.Postgres
end
