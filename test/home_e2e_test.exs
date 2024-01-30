defmodule BlogWeb.HomeE2ETest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  feature "home page", %{session: session} do
    session
    |> visit("/")
    |> find(Query.xpath("/html/body/div/div[2]/*/div/div[1]", count: 3))
    |> List.first()
    |> assert_text("Post 1 Headline")
  end
end
