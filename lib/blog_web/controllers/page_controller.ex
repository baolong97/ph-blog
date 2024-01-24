defmodule BlogWeb.PageController do
  use BlogWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def home1(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home1, layout: false)
  end
end
