defmodule Blog.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Accounts` context.
  """

  def unique_user_email, do: "u#{System.unique_integer()}@example.com"

  def valid_user_password, do: "valid password 123456789"

  def valid_user_attributes(attrs \\ %{}) do
    unique_username = "#{System.unique_integer()}"

    Enum.into(attrs, %{
      username: "u#{unique_username}",
      email: "u#{unique_username}@example.com",
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Blog.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
