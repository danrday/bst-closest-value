defmodule BstClosestValue.Repo do
  use Ecto.Repo,
    otp_app: :bst_closest_value,
    adapter: Ecto.Adapters.Postgres
end
