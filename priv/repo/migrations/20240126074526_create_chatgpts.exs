defmodule Blog.Repo.Migrations.CreateChatgpts do
  use Ecto.Migration

  def change do
    create table(:chatgpts) do
      timestamps(type: :utc_datetime)
    end
  end
end
