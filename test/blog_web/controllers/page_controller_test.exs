defmodule BlogWeb.PageControllerTest do
  use BlogWeb.ConnCase

  import Blog.AccountsFixtures

  test "GET /", %{conn: conn} do
    user = user_fixture()
    conn = conn |> log_in_user(user) |> get(~p"/")
    assert html_response(conn, 200) =~ "Our Blog"
  end
end
