require Wallaby

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Blog.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, BlogWeb.Endpoint.url())
