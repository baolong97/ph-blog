defmodule BlogWeb.ChatGPTJSON do
  alias Blog.ChatGPTs.ChatGPT

  @doc """
  Renders a list of chatgpts.
  """
  def index(%{chatgpts: chatgpts}) do
    %{data: for(chat_gpt <- chatgpts, do: data(chat_gpt))}
  end

  @doc """
  Renders a single chat_gpt.
  """
  def show(%{chat_gpt: chat_gpt}) do
    %{data: data(chat_gpt)}
  end

  defp data(%ChatGPT{} = chat_gpt) do
    chat_gpt
    # %{
    #   id: chat_gpt.id
    # }
  end
end
