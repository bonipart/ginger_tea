defmodule GingerTeaWeb.PageController do
  use GingerTeaWeb, :controller

  import GingerTea.JsonResponse, only: [notify: 2]

  alias GingerTea.Accounts
  alias GingerTea.Twilio
  alias GingerTeaWeb.UserAuth

  def index(conn, _params) do
    # render(conn, "index.html")
    username = conn.assigns[:current_user].email
    user_data = %{msg: "You are authenticated", user: username}

    IO.inspect(conn)
    json(conn, user_data)
  end

  def delete(conn, _params) do
    conn
    |> text("Deleting session")
  end

  # def delete(conn, _params) do
  #   conn
  #   # |> put_flash(:info, "Logged out successfully.")
  #   |> UserAuth.log_out_user()
  # end

  def create_session(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      IO.puts("***** Invalid email or password. Sending json msg ****")
      # conn |> json(%{data: %{msg: "Invalid email or password"}})
      conn |> json(notify(:error, "Invalid email or password."))
    end
  end

  def create_user(conn, %{"user" => user_params}) do
    IO.puts("***** Creating new User *****")

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        IO.puts("***** New User Created! *****")

        conn
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> json(%{error: %{msg: inspect(changeset.errors)}})
    end
  end

  def new(conn, _params) do
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> json(%{data: %{msg: "Please login", return_to: user_return_to}})
  end

  def whoami(conn, _params) do
    username = conn.assigns[:current_user].email
    # user_token = UserAuth.show_token(conn)

    IO.puts("***** Inspecting conn in whoami() <<<<<<")
    IO.inspect(conn)
    IO.puts(">>>>>> Inspecting conn in whoami() ******")

    conn
    |> json(%{data: %{msg: "whoami(): #{username}"}})

    # |> json(user_token)
  end

  # def who(conn, params) do

  # end

  @doc """
  Returns a list of registered user emails
  """
  def show_users(conn, _params) do
    users = GingerTea.Repo.all(Accounts.User) |> Enum.map(& &1.email)

    conn
    |> json(%{data: %{users: users}})
  end

  def test(conn, _params) do
    conn
    |> json(notify(:ok, "Drink Canna"))
  end

  def julia(conn, _params) do
    conn
    |> text("Julia Malkina")
  end

  def room_callback(conn, params) do
    conn
    |> text(params)
  end

  def get_twilio_access_token(conn, %{"client_id" => client_id, "room_id" => room_id} = params) do
    case Twilio.generate_access_token(client_id, room_id) do
      {:ok, jwt} ->
        IO.puts(jwt)
        json(conn, %{status_code: :ok, msg: jwt})

      {:error, reason} ->
        json(conn, %{status_code: :error, msg: reason})
    end
  end
end
