defmodule GingerTea.Repo do
  use Ecto.Repo,
    otp_app: :ginger_tea,
    adapter: Ecto.Adapters.Postgres
end
