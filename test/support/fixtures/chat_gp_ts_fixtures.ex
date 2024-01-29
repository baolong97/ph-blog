defmodule Blog.ChatGPTsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.ChatGPTs` context.
  """

  @doc """
  Generate a chat_gpt.
  """
  def chat_gpt_fixture(attrs \\ %{}) do
    {:ok, chat_gpt} =
      attrs
      |> Enum.into(%{})
      |> Blog.ChatGPTs.create_chat_gpt()

    chat_gpt
  end
end
