defmodule CoursePlannerWeb.Auth.Api.V1.JsonSessionController do
  @moduledoc """
    This module handles api loging in to the system
  """
  use CoursePlannerWeb, :controller

  alias CoursePlanner.Accounts.{Users, User}

  plug :put_layout, ""

  def create(conn, %{"email" => email, "password" => password}) do
    trimmed_downcased_email =
      email
      |> String.trim()
      |> String.downcase()
    user = Repo.get_by(User, email: trimmed_downcased_email)

    case Users.check_password(user, password) do
      {:ok, _reason} ->
        conn
        |> json(%{token: get_login_token(conn, user)})

      {:error, _reason} ->
        conn
        |> json(%{token:  "error"})
    end
  end

  defp get_login_token(conn, user) do
    conn
    |> Guardian.Plug.api_sign_in(user)
    |> Guardian.Plug.current_token(new_conn)
  end

end
