defmodule Blog.Seeding do
  alias Blog.Accounts
  alias Blog.Repo
  alias Blog.Posts.Post

  def seed do
    user =
      case Accounts.register_user(%{
             username: "user1",
             email: "user1@blogtest123.com",
             password: "123123123123"
           }) do
        {:ok, user} -> user
        {:error, _} -> Accounts.get_user_by_email("user1@blogtest123.com")
      end

    Repo.insert_all(Post, [
      [
        title: "seeding title 1",
        content: "seeding content 1",
        published_on: ~D[2023-12-12],
        visible: true,
        user_id: user.id,
        inserted_at: ~U[2023-12-11 00:00:00Z],
        updated_at: ~U[2023-12-11 00:00:00Z]
      ],
      [
        title: "seeding title 2",
        content: "seeding content 2",
        published_on: ~D[2023-12-12],
        visible: true,
        user_id: user.id,
        inserted_at: ~U[2023-12-11 00:00:00Z],
        updated_at: ~U[2023-12-11 00:00:00Z]
      ]
    ])
  end
end
