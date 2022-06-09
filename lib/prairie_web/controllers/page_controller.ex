defmodule PrairieWeb.PageController do
  use PrairieWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
