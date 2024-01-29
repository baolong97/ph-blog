defmodule BlogWeb.ChatGPTController do
  use BlogWeb, :controller

  alias Blog.ChatGPTs
  alias Blog.ChatGPTs.ChatGPT

  action_fallback BlogWeb.FallbackController

  def create(conn, params) do
    with {:ok, %ChatGPT{} = chat_gpt} <- ChatGPTs.create_chat_gpt(params) do
      conn
      |> put_status(:created)
      |> render(:show, chat_gpt: chat_gpt)
    end
  end
end
