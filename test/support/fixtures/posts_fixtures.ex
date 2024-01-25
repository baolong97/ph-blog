defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        title: "some title #{NaiveDateTime.utc_now()}",
        published_on: ~D[2023-12-12],
        visible: true,
        comments: []
      })
      |> Blog.Posts.create_post()

    post
  end
end
