defmodule Blog.ChatGPTs.ChatGPT do
  @moduledoc false
  @derive Jason.Encoder
  defstruct [:id, :choices, :created, :model, :system_fingerprint, :object, :usage]
end
