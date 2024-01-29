defmodule Blog.ChatGPTs do
  @moduledoc """
  The ChatGPTs context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.ChatGPTs.ChatGPT

  @doc """
  Creates a chat_gpt.

  ## Examples

      iex> create_chat_gpt(%{field: value})
      {:ok, %ChatGPT{}}

      iex> create_chat_gpt(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat_gpt(attrs \\ %{}) do
    host = System.get_env("BLOG_CHATGPT_HOST") || "https://mockgpt.wiremockapi.cloud/v1"
    token = System.get_env("BLOG_CHATGPT_TOKEN") || ""

    request =
      Finch.build(
        :post,
        "#{host}/chat/completions",
        [
          {"Authorization", "Bearer #{token}"},
          {"Content-Type", "application/json"}
        ],
        Jason.encode!(attrs)
      )

    {:ok, response} = Finch.request(request, Blog.Finch)
    {:ok, data} = Jason.decode(response.body)

    data =
      Enum.reduce(data, %{}, fn {key, val}, acc ->
        Map.put(acc, String.to_atom(key), val)
      end)

    {:ok, struct!(ChatGPT, Enum.into(data, %{}))}
  end
end
