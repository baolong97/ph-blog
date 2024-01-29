defmodule Blog.ChatGPTsTest do
  use Blog.DataCase

  alias Blog.ChatGPTs

  describe "chatgpts" do
    alias Blog.ChatGPTs.ChatGPT

    import Blog.ChatGPTsFixtures

    @invalid_attrs %{}

    test "list_chatgpts/0 returns all chatgpts" do
      chat_gpt = chat_gpt_fixture()
      assert ChatGPTs.list_chatgpts() == [chat_gpt]
    end

    test "get_chat_gpt!/1 returns the chat_gpt with given id" do
      chat_gpt = chat_gpt_fixture()
      assert ChatGPTs.get_chat_gpt!(chat_gpt.id) == chat_gpt
    end

    test "create_chat_gpt/1 with valid data creates a chat_gpt" do
      valid_attrs = %{}

      assert {:ok, %ChatGPT{} = chat_gpt} = ChatGPTs.create_chat_gpt(valid_attrs)
    end

    test "create_chat_gpt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ChatGPTs.create_chat_gpt(@invalid_attrs)
    end

    test "update_chat_gpt/2 with valid data updates the chat_gpt" do
      chat_gpt = chat_gpt_fixture()
      update_attrs = %{}

      assert {:ok, %ChatGPT{} = chat_gpt} = ChatGPTs.update_chat_gpt(chat_gpt, update_attrs)
    end

    test "update_chat_gpt/2 with invalid data returns error changeset" do
      chat_gpt = chat_gpt_fixture()
      assert {:error, %Ecto.Changeset{}} = ChatGPTs.update_chat_gpt(chat_gpt, @invalid_attrs)
      assert chat_gpt == ChatGPTs.get_chat_gpt!(chat_gpt.id)
    end

    test "delete_chat_gpt/1 deletes the chat_gpt" do
      chat_gpt = chat_gpt_fixture()
      assert {:ok, %ChatGPT{}} = ChatGPTs.delete_chat_gpt(chat_gpt)
      assert_raise Ecto.NoResultsError, fn -> ChatGPTs.get_chat_gpt!(chat_gpt.id) end
    end

    test "change_chat_gpt/1 returns a chat_gpt changeset" do
      chat_gpt = chat_gpt_fixture()
      assert %Ecto.Changeset{} = ChatGPTs.change_chat_gpt(chat_gpt)
    end
  end
end
