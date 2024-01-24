defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase
  alias Blog.Posts

  alias Blog.Posts.{CoverImage}

  import Blog.PostsFixtures
  import Blog.AccountsFixtures
  import Blog.TagsFixtures

  @create_attrs %{title: "some title", subtitle: "some subtitle", content: "some content"}
  @update_attrs %{
    title: "some updated title",
    subtitle: "some updated subtitle",
    content: "some updated content"
  }
  @invalid_attrs %{title: nil, subtitle: nil, content: nil}

  describe "index" do
    test "lists all posts", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user)
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ "Listing Posts"
    end
  end

  test "search for posts - non-matching", %{conn: conn} do
    user = user_fixture()
    conn = conn |> log_in_user(user)
    post = post_fixture(title: "some title #{NaiveDateTime.utc_now()}", user_id: user.id)
    conn = get(conn, ~p"/posts", title: "Non-Matching")
    refute html_response(conn, 200) =~ post.title
  end

  test "search for posts - exact match", %{conn: conn} do
    user = user_fixture()
    conn = conn |> log_in_user(user)
    post = post_fixture(title: "some title #{NaiveDateTime.utc_now()}", user_id: user.id)
    conn = get(conn, ~p"/posts", title: "some title")
    assert html_response(conn, 200) =~ post.title
  end

  test "search for posts - partial match", %{conn: conn} do
    user = user_fixture()
    conn = conn |> log_in_user(user)
    post = post_fixture(title: "some title #{NaiveDateTime.utc_now()}", user_id: user.id)
    conn = get(conn, ~p"/posts", title: "itl")
    assert html_response(conn, 200) =~ post.title
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user)
      conn = get(conn, ~p"/posts/new")
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user)

      conn =
        post(conn, ~p"/posts",
          post: %{
            title: "some title",
            subtitle: "title#{System.unique_integer()}",
            content: "some content",
            user_id: user.id
          }
        )

      assert %{id: id} = redirected_params(conn)

      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user)
      conn = post(conn, ~p"/posts", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post"
    end

    test "posts are created with a user", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user)

      conn =
        post(conn, ~p"/posts",
          post: %{
            title: "some title",
            subtitle: "title#{System.unique_integer()}",
            content: "some content",
            user_id: user.id
          }
        )

      assert %{id: id} = redirected_params(conn)

      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "of #{user.username}"
    end

    test "create post with tags", %{conn: conn} do
      # Arrange: Setup the necessary data
      user = user_fixture()
      conn = log_in_user(conn, user)

      tag1 = tag_fixture(name: "tag 1 name")
      tag2 = tag_fixture(name: "tag 2 name")

      create_attrs = %{
        content: "some content",
        title: "some title",
        visible: true,
        published_on: DateTime.utc_now(),
        user_id: user.id,
        tag_ids: [tag1.id, tag2.id]
      }

      # Act: send the HTTP POST request
      conn = post(conn, ~p"/posts", post: create_attrs)

      # Assert: Verify the response is redirected and that the post is created with tags.
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      assert Posts.get_post!(id).tags == [tag1, tag2]
    end

    test "create post with cover image", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      create_attrs = %{
        content: "some content",
        title: "some title",
        visible: true,
        published_on: DateTime.utc_now(),
        user_id: user.id,
        cover_image: %{
          url: "https://www.example.com/image.png"
        }
      }

      conn = post(conn, ~p"/posts", post: create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      post = Posts.get_post!(id)
      # post was created with cover image
      assert %CoverImage{url: "https://www.example.com/image.png"} = post.cover_image
      # post cover image is displayed on show page
      assert html_response(conn, 200) =~ "https://www.example.com/image.png"
    end
  end

  describe "edit post" do
    setup [:create_post]

    test "renders form for editing chosen post", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user)
      conn = get(conn, ~p"/posts/#{post}/edit")
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "update post" do
    setup [:create_post]

    test "redirects when data is valid", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user)
      conn = put(conn, ~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user)
      conn = put(conn, ~p"/posts/#{post}", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post"
    end

    test "update post with cover image", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user)

      conn =
        put(conn, ~p"/posts/#{post}",
          post:
            @update_attrs
            |> Enum.into(%{
              cover_image: %{
                url: "https://www.example.com/image.png"
              }
            })
        )

      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "some updated title"
      post = Posts.get_post!(post.id)
      # post was created with cover image
      assert %CoverImage{url: "https://www.example.com/image.png"} = post.cover_image
      # post cover image is displayed on show page
      assert html_response(conn, 200) =~ "https://www.example.com/image.png"
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "deletes chosen post", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user)
      conn = delete(conn, ~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/posts"

      assert_error_sent 404, fn ->
        get(conn, ~p"/posts/#{post}")
      end
    end

    test "deletes a post with image", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user)

      conn =
        put(conn, ~p"/posts/#{post}",
          post:
            @update_attrs
            |> Enum.into(%{
              cover_image: %{
                url: "https://www.example.com/image.png"
              }
            })
        )

      conn = delete(conn, ~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/posts"

      assert_error_sent 404, fn ->
        get(conn, ~p"/posts/#{post}")
      end
    end
  end

  test "the post page displays comments on the post", %{conn: conn} do
    user = user_fixture()
    conn = conn |> log_in_user(user)
    conn = post(conn, ~p"/posts", post: @create_attrs |> Enum.into(%{user_id: user.id}))

    assert %{id: id} = redirected_params(conn)

    post(conn, ~p"/comments",
      comment: %{post_id: id, content: "comment content", user_id: user.id}
    )

    assert redirected_to(conn) == ~p"/posts/#{id}"

    conn = get(conn, ~p"/posts/#{id}")
    assert html_response(conn, 200) =~ "Post #{id}"
    assert html_response(conn, 200) =~ "comment content"
  end

  defp create_post(_) do
    user = user_fixture()
    post = post_fixture(user_id: user.id)
    %{post: post, user: user}
  end
end
