defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts

  describe "posts" do
    alias Blog.Posts.{Post, CoverImage}

    import Blog.PostsFixtures

    import Blog.CommentsFixtures

    import Blog.AccountsFixtures

    import Blog.TagsFixtures

    @invalid_attrs %{title: nil, subtitle: nil, content: nil}

    test "list_posts/0 returns all posts" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id}) |> Map.delete(:tags)
      assert Posts.list_posts() |> Enum.map(fn post -> Map.delete(post, :tags) end) == [post]
    end

    test "list_posts/0 returns all posts with visible: true" do
      user = user_fixture()
      post_fixture(%{visible: false, user_id: user.id})
      post = post_fixture(%{user_id: user.id}) |> Map.delete(:tags)
      assert Posts.list_posts() |> Enum.map(fn post -> Map.delete(post, :tags) end) == [post]
    end

    test "list_posts/0 posts are displayed from newest" do
      user = user_fixture()
      posts = Enum.map(1..10, fn i -> post_fixture(%{title: "title #{i}", user_id: user.id}) end)

      is_newest_to_oldest =
        posts
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.all?(fn [p1, p2] ->
          p1.inserted_at >= p2.inserted_at
        end)

      assert is_newest_to_oldest
    end

    test "list_posts/0 posts with a published date in the future are filtered from the list of posts" do
      user = user_fixture()
      post_fixture(%{published_on: ~D[4023-12-26], user_id: user.id})
      post = post_fixture(%{user_id: user.id}) |> Map.delete(:tags)
      assert Posts.list_posts() |> Enum.map(fn post -> Map.delete(post, :tags) end) == [post]
    end

    test "list_posts/1 filters posts by partial and case-insensitive title" do
      user = user_fixture()

      post =
        post_fixture(title: "Title #{NaiveDateTime.utc_now()}", user_id: user.id)
        |> Map.delete(:tags)

      # non-matching
      assert Posts.list_posts("Non-Matching") == []
      # exact match
      assert Posts.list_posts("Title") |> Enum.map(fn post -> Map.delete(post, :tags) end) == [
               post
             ]

      # partial match end
      assert Posts.list_posts("tle") |> Enum.map(fn post -> Map.delete(post, :tags) end) == [post]
      # partial match front
      assert Posts.list_posts("Titl") |> Enum.map(fn post -> Map.delete(post, :tags) end) == [
               post
             ]

      # partial match middle
      assert Posts.list_posts("itl") |> Enum.map(fn post -> Map.delete(post, :tags) end) == [post]
      # case insensitive lower
      assert Posts.list_posts("title") |> Enum.map(fn post -> Map.delete(post, :tags) end) == [
               post
             ]

      # case insensitive upper
      assert Posts.list_posts("TITLE") |> Enum.map(fn post -> Map.delete(post, :tags) end) == [
               post
             ]

      # case insensitive and partial match
      assert Posts.list_posts("ITL") |> Enum.map(fn post -> Map.delete(post, :tags) end) == [post]
      # empty
      assert Posts.list_posts("") |> Enum.map(fn post -> Map.delete(post, :tags) end) == [post]
    end

    test "get_post!/1 returns the post with given id" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})

      assert Posts.get_post!(post.id) |> remove_field([:cover_image]) ==
               Repo.preload(post, [:user, comments: [:user]]) |> remove_field([:cover_image])
    end

    test "create_post/1 with valid data creates a post" do
      user = user_fixture()
      title = "some title #{NaiveDateTime.utc_now()}"

      valid_attrs = %{
        title: title,
        content: "some content",
        published_on: ~D[2023-12-12],
        visible: true,
        user_id: user.id
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.title == title
      assert post.content == "some content"
      assert post.published_on == ~D[2023-12-12]
      assert post.visible == true
    end

    test "create_post/1 with invalid data returns error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Posts.create_post(@invalid_attrs |> Enum.into(%{user_id: user.id}))
    end

    test "create_post/1 posts are created with a user" do
      user = user_fixture()
      title = "some title #{NaiveDateTime.utc_now()}"

      valid_attrs = %{
        title: title,
        content: "some content",
        published_on: ~D[2023-12-12],
        visible: true,
        user_id: user.id
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.title == title
      assert post.content == "some content"
      assert post.published_on == ~D[2023-12-12]
      assert post.visible == true
      assert post.user_id == user.id
    end

    test "update_post/2 with valid data updates the post" do
      user = user_fixture()
      title = "some title #{NaiveDateTime.utc_now()}"

      post = post_fixture(user_id: user.id)

      update_attrs = %{
        title: title,
        content: "some content",
        published_on: ~D[2023-12-23],
        visible: false,
        user_id: user.id
      }

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.title == title
      assert post.content == "some content"
      assert post.published_on == ~D[2023-12-23]
      assert post.visible == false
    end

    test "update_post/2 with invalid data returns error changeset" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})

      assert {:error, %Ecto.Changeset{}} =
               Posts.update_post(post, @invalid_attrs |> Enum.into(%{user_id: user.id}))

      assert Posts.get_post!(post.id) |> remove_field([:cover_image]) ==
               Repo.preload(post, [:user, comments: [:user]]) |> remove_field([:cover_image])
    end

    test "delete_post/1 deletes the post" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end

    test "get_post!/1 returns the post with given id and associated comments" do
      user = user_fixture()
      post = post_fixture(%{user_id: user.id})
      comment = comment_fixture(%{user_id: user.id, post_id: post.id})
      assert Posts.get_post!(post.id).comments == [Repo.preload(comment, :user)]
    end

    test "create_post/1 with tags" do
      user = user_fixture()
      tag1 = tag_fixture()
      tag2 = tag_fixture()

      valid_attrs1 = %{content: "some content", title: "post 1", user_id: user.id, visible: true}
      valid_attrs2 = %{content: "some content", title: "post 2", user_id: user.id, visible: true}

      assert {:ok, %Post{} = post1} = Posts.create_post(valid_attrs1, [tag1, tag2])
      assert {:ok, %Post{} = post2} = Posts.create_post(valid_attrs2, [tag1])

      # posts have many tags
      assert Repo.preload(post1, :tags).tags == [tag1, tag2]
      assert Repo.preload(post2, :tags).tags == [tag1]

      # tags have many posts
      # we preload posts: [:tags] because posts contain the list of tags when created
      assert Repo.preload(tag1, posts: [:tags]).posts == [post1, post2]
      assert Repo.preload(tag2, posts: [:tags]).posts == [post1]
    end

    test "update_post/1 with tags" do
      user = user_fixture()
      tag1 = tag_fixture()
      tag2 = tag_fixture()

      valid_attrs1 = %{content: "some content", title: "post 1", user_id: user.id, visible: true}
      valid_attrs2 = %{content: "some content", title: "post 2", user_id: user.id, visible: true}

      assert {:ok, %Post{} = post1} = Posts.create_post(valid_attrs1, [tag1, tag2])
      assert {:ok, %Post{} = post2} = Posts.create_post(valid_attrs2, [tag1])

      assert {:ok, %Post{} = post1} = Posts.update_post(post1, valid_attrs1, [tag1])
      assert {:ok, %Post{} = post2} = Posts.update_post(post2, valid_attrs2, [tag1, tag2])

      # posts have many tags
      assert Repo.preload(post1, :tags).tags == [tag1]
      assert Repo.preload(post2, :tags).tags == [tag1, tag2]

      # tags have many posts
      # we preload posts: [:tags] because posts contain the list of tags when created
      assert Repo.preload(tag1, posts: [:tags]).posts
             |> Enum.map(fn post -> remove_field(post, [:cover_image]) end) ==
               [post1, post2] |> Enum.map(fn post -> remove_field(post, [:cover_image]) end)

      assert Repo.preload(tag2, posts: [:tags]).posts
             |> Enum.map(fn post -> remove_field(post, [:cover_image]) end) ==
               [post2] |> Enum.map(fn post -> remove_field(post, [:cover_image]) end)
    end

    test "delete_post/1 with tags" do
      user = user_fixture()
      tag1 = tag_fixture()

      valid_attrs1 = %{content: "some content", title: "post 1", user_id: user.id, visible: true}
      valid_attrs2 = %{content: "some content", title: "post 2", user_id: user.id, visible: true}

      assert {:ok, %Post{} = post1} = Posts.create_post(valid_attrs1, [tag1])
      assert {:ok, %Post{} = post2} = Posts.create_post(valid_attrs2, [tag1])

      Posts.delete_post(post2)

      assert Repo.preload(tag1, posts: [:tags]).posts == [post1]
    end

    test "create_post/1 with image" do
      valid_attrs = %{
        content: "some content",
        title: "some title",
        cover_image: %{
          url: "https://www.example.com/image.png"
        },
        visible: true,
        published_on: DateTime.utc_now(),
        user_id: user_fixture().id
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)

      assert %CoverImage{url: "https://www.example.com/image.png"} =
               Repo.preload(post, :cover_image).cover_image
    end

    test "update_post/1 add an image" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)

      assert {:ok, %Post{} = post} =
               Posts.update_post(post, %{
                 cover_image: %{url: "https://www.example.com/image2.png"}
               })

      assert post.cover_image.url == "https://www.example.com/image2.png"
    end

    test "update_post/1 update existing image" do
      user = user_fixture()

      post =
        post_fixture(user_id: user.id, cover_image: %{url: "https://www.example.com/image.png"})

      assert {:ok, %Post{} = post} =
               Posts.update_post(post, %{
                 cover_image: %{url: "https://www.example.com/image2.png"}
               })

      assert post.cover_image.url == "https://www.example.com/image2.png"
    end

    test "delete_post/1 deletes post and cover image" do
      user = user_fixture()

      post =
        post_fixture(user_id: user.id, cover_image: %{url: "https://www.example.com/image.png"})

      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(CoverImage, post.cover_image.id) end
    end
  end

  def remove_field(data, fields) do
    fields
    |> Enum.reduce(data, fn field, acc ->
      acc |> Map.delete(field)
    end)
  end
end
