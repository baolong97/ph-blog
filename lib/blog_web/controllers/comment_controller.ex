defmodule BlogWeb.CommentController do
  use BlogWeb, :controller

  alias Blog.Comments
  alias Blog.Comments.Comment

  alias Blog.Posts

  plug :require_user_owns_comment when action in [:edit, :update, :delete]

  def index(conn, _params) do
    comments = Comments.list_comments()
    render(conn, :index, comments: comments)
  end

  def new(conn, _params) do
    changeset = Comments.change_comment(%Comment{})
    render(conn, :new, changeset: changeset)
  end

  def add_comment(conn, params) do
    post = Posts.get_post!(params["id"])
    changeset = Comments.change_comment(%Comment{})
    render(conn, :add_comment, changeset: changeset, post: post)
  end

  def create(conn, %{"comment" => comment_params}) do
    case Comments.create_comment(comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment created successfully.")
        |> redirect(to: ~p"/posts/#{comment_params["post_id"]}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    render(conn, :show, comment: comment)
  end

  def edit(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    changeset = Comments.change_comment(comment)
    render(conn, :edit, comment: comment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Comments.get_comment!(id)

    case Comments.update_comment(comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: ~p"/comments/#{comment}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, comment: comment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    {:ok, comment} = Comments.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: ~p"/posts/#{comment.post_id}")
  end

  defp require_user_owns_comment(conn, _params) do
    comment_id = String.to_integer(conn.path_params["id"])
    comment = Comments.get_comment!(comment_id)

    if conn.assigns[:current_user].id == comment.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You can only edit or delete your own comments.")
      |> redirect(to: ~p"/comments/#{comment_id}")
      |> halt()
    end
  end
end
