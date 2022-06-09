defmodule Prairie.Repo do
  use Ecto.Repo,
    otp_app: :prairie,
    adapter: Ecto.Adapters.Postgres
end
