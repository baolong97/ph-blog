defmodule BlogWeb.ChatGPTControllerTest do
  use BlogWeb.ConnCase

  import Blog.ChatGPTsFixtures

  alias Blog.ChatGPTs.ChatGPT

  import Blog.AccountsFixtures


  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create chat_gpt" do
    test "renders chat_gpt when data is valid", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user)
      conn = post(conn, ~p"/api/chatgpt", chat_gpt: @create_attrs)
      assert %{
               "choices" => choices
             } = json_response(conn, 201)["data"]
    end
  end

  defp create_chat_gpt(_) do
    chat_gpt = chat_gpt_fixture()
    %{chat_gpt: chat_gpt}
  end
end
