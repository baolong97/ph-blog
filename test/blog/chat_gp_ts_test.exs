defmodule Blog.ChatGPTsTest do
  use Blog.DataCase

  alias Blog.ChatGPTs

  describe "chatgpts" do
    alias Blog.ChatGPTs.ChatGPT

    import Blog.ChatGPTsFixtures

    @invalid_attrs %{}

    test "create_chat_gpt/1 with valid data creates a chat_gpt" do
      valid_attrs = %{}

      assert {:ok, %ChatGPT{} = chat_gpt} = ChatGPTs.create_chat_gpt(valid_attrs)
    end
  end
end
