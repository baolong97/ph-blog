defmodule BlogWeb.ChatGPTControllerTest do
  use BlogWeb.ConnCase

  import Blog.ChatGPTsFixtures

  alias Blog.ChatGPTs.ChatGPT

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all chatgpts", %{conn: conn} do
      conn = get(conn, ~p"/api/chatgpts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create chat_gpt" do
    test "renders chat_gpt when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/chatgpts", chat_gpt: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/chatgpts/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/chatgpts", chat_gpt: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update chat_gpt" do
    setup [:create_chat_gpt]

    test "renders chat_gpt when data is valid", %{
      conn: conn,
      chat_gpt: %ChatGPT{id: id} = chat_gpt
    } do
      conn = put(conn, ~p"/api/chatgpts/#{chat_gpt}", chat_gpt: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/chatgpts/#{id}")

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, chat_gpt: chat_gpt} do
      conn = put(conn, ~p"/api/chatgpts/#{chat_gpt}", chat_gpt: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete chat_gpt" do
    setup [:create_chat_gpt]

    test "deletes chosen chat_gpt", %{conn: conn, chat_gpt: chat_gpt} do
      conn = delete(conn, ~p"/api/chatgpts/#{chat_gpt}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/chatgpts/#{chat_gpt}")
      end
    end
  end

  defp create_chat_gpt(_) do
    chat_gpt = chat_gpt_fixture()
    %{chat_gpt: chat_gpt}
  end
end
