defmodule Blog.Repo.Migrations.Visibility do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :subtitle

      add :published_on , :date
      add :visible , :boolean, default: true

    end

    create unique_index(:posts, [:title])
  end
end
