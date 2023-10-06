defmodule DragBoardWeb.PageControllerTest do
  use DragBoardWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert conn.status == 200
  end
end
