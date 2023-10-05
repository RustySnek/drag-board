defmodule DragBoard.Boards.BoardQueries do
  import Ecto.Query
  alias DragBoard.Board

  def all(query \\ base()), do: query

  def with_id(query \\ base(), board_id) do
    query
    |> where([board: board], board.id == ^board_id)
  end

  defp base do
    from(_ in Board, as: :board)
  end
end
