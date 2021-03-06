defmodule CoursePlanner.Accounts.Coordinators do
  @moduledoc false
  import Ecto.Query
  alias CoursePlanner.{Repo, Accounts.User, Accounts.Users}

  @coordinators from u in User, where: u.role == "Coordinator",
    order_by: [u.name, u.family_name, u.nickname]

  def all do
    Repo.all(@coordinators)
  end

  def new(user, token) do
    user
    |> Map.put("role", "Coordinator")
    |> Users.new_user(token)
  end

  def edit(id) do
    case Users.get(id) do
      {:ok, coordinator} -> {:ok, coordinator, User.changeset(coordinator)}
      error -> error
    end
  end

  def update(id, params) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      coordinator ->
        coordinator
        |> User.changeset(params, :update)
        |> Repo.update
        |> format_error(coordinator)
    end
  end

  defp format_error({:ok, coordinator}, _), do: {:ok, coordinator}
  defp format_error({:error, changeset}, coordinator), do: {:error, coordinator, changeset}

end
