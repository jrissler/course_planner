defmodule CoursePlanner.ClassControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.Class
  alias CoursePlanner.Course
  alias CoursePlanner.User
  alias CoursePlanner.Repo

  @valid_course_attrs %{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %{hour: 14, min: 0, sec: 0}, status: "Planned", syllabus: "some content"}
  @valid_attrs %{course_id: nil, date: %{day: 17, month: 4, year: 2010}, starting_at: %{hour: 14, min: 0, sec: 0}, finishes_at: %{hour: 15, min: 0, sec: 0}, status: "Planned"}
  @invalid_attrs %{}
  @user %User{
    name: "Test User",
    email: "testuser@example.com",
    password: "secret",
    password_confirmation: "secret"}

  setup do
    conn =
      Phoenix.ConnTest.build_conn()
        |> assign(:current_user, @user)
    {:ok, conn: conn}
  end

  defp create_course do
    changeset = Course.changeset(%Course{}, @valid_course_attrs, :create)
    Repo.insert(changeset)
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, class_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing classes"
  end

  test "lists all entries on index except if delete", %{conn: conn} do
    {:ok, created_course} = create_course()
    class_deleted_completed_attributes =  %{course_id: created_course.id, deleted_at: %{day: 17, month: 4, year: 2010}, date: %{day: 17, month: 4, year: 2010}, starting_at: %{hour: 14, min: 0, sec: 0}, finishes_at: %{hour: 15, min: 0, sec: 0}, status: "Planned"}
    Repo.insert(Class.changeset(%Class{}, class_deleted_completed_attributes))
    conn = get conn, class_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing classes"
    assert length(conn.assigns.classes) == 0
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, class_path(conn, :new)
    assert html_response(conn, 200) =~ "New class"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    {:ok, created_course} = create_course()
    completed_attributes = %{@valid_attrs | course_id: created_course.id}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert redirected_to(conn) == class_path(conn, :index)
    assert Repo.get_by(Class, completed_attributes)
  end

  test "creates resource and redirects when data is valid and status is Active", %{conn: conn} do
    {:ok, created_course} = create_course()
    completed_attributes = %{@valid_attrs | course_id: created_course.id, status: "Active"}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert redirected_to(conn) == class_path(conn, :index)
    assert Repo.get_by(Class, completed_attributes)
  end

  test "does not create resource and renders errors when data is empty", %{conn: conn} do
    conn = post conn, class_path(conn, :create), class: @invalid_attrs
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when no course", %{conn: conn} do
    conn = post conn, class_path(conn, :create), class: @valid_attrs
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when starting time is zero", %{conn: conn} do
    {:ok, created_course} = create_course()
    completed_attributes = %{@valid_attrs | course_id: created_course.id, starting_at: %{hour: 0, min: 0, sec: 0}}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when finishing time is zero", %{conn: conn} do
    {:ok, created_course} = create_course()
    completed_attributes = %{@valid_attrs | course_id: created_course.id, finishes_at: %{hour: 0, min: 0, sec: 0}}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when starting time is after finishing time", %{conn: conn} do
    {:ok, created_course} = create_course()
    completed_attributes = %{@valid_attrs | course_id: created_course.id, starting_at: %{hour: 12, min: 0, sec: 0},  finishes_at: %{hour: 10, min: 0, sec: 0}}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when status random", %{conn: conn} do
    {:ok, created_course} = create_course()
    completed_attributes = %{@valid_attrs | course_id: created_course.id, status: "random"}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when status Finsihed", %{conn: conn} do
    {:ok, created_course} = create_course()
    completed_attributes = %{@valid_attrs | course_id: created_course.id, status: "Finished"}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when status Graduated", %{conn: conn} do
    {:ok, created_course} = create_course()
    completed_attributes = %{@valid_attrs | course_id: created_course.id, status: "Graduated"}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
  end

  test "does not creates resource and redirects when status Frozen", %{conn: conn} do
    {:ok, created_course} = create_course()
    completed_attributes = %{@valid_attrs | course_id: created_course.id, status: "Frozen"}
    conn = post conn, class_path(conn, :create), class: completed_attributes
    assert html_response(conn, 200) =~ "New class"
  end

  test "shows chosen resource", %{conn: conn} do
    {:ok, created_course} = create_course()
    class = Repo.insert! %Class{course_id: created_course.id}
    conn = get conn, class_path(conn, :show, class)
    assert html_response(conn, 200) =~ "Show class"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, class_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    class = Repo.insert! %Class{}
    conn = get conn, class_path(conn, :edit, class)
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    {:ok, created_course} = create_course()
    class_insert_args = %Class{course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0}), status: "Planned"}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | course_id: created_course.id}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert redirected_to(conn) == class_path(conn, :show, class)
    assert Repo.get_by(Class, update_params)
  end

  test "updates chosen resource status to active", %{conn: conn} do
    {:ok, created_course} = create_course()
    class_insert_args = %Class{course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0}), status: "Planned"}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | course_id: created_course.id, status: "Active"}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert redirected_to(conn) == class_path(conn, :show, class)
    assert Repo.get_by(Class, update_params)
  end

  test "updates chosen resource time", %{conn: conn} do
    {:ok, created_course} = create_course()
    class_insert_args = %Class{course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0}), status: "Planned"}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | course_id: created_course.id, starting_at: %{hour: 18, min: 0, sec: 0},  finishes_at: %{hour: 19, min: 0, sec: 0}}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert redirected_to(conn) == class_path(conn, :show, class)
    assert Repo.get_by(Class, update_params)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    class = Repo.insert! %Class{}
    conn = put conn, class_path(conn, :update, class), class: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "does not update chosen resource if course not selected", %{conn: conn} do
    {:ok, created_course} = create_course()
    class_insert_args = %Class{course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0}), status: "Planned"}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | course_id: nil}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "does not update chosen resource if starting time is zero", %{conn: conn} do
    {:ok, created_course} = create_course()
    class_insert_args = %Class{course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0}), status: "Planned"}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | course_id: created_course.id, starting_at: %{hour: 0, min: 0, sec: 0}}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "does not update chosen resource if finishing time is zero", %{conn: conn} do
    {:ok, created_course} = create_course()
    class_insert_args = %Class{course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0}), status: "Planned"}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | course_id: created_course.id, finishes_at: %{hour: 0, min: 0, sec: 0}}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "does not update chosen resource if finishing time is less than starting time", %{conn: conn} do
    {:ok, created_course} = create_course()
    class_insert_args = %Class{course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0}), status: "Planned"}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | course_id: created_course.id, starting_at: %{hour: 2, min: 0, sec: 0}, finishes_at: %{hour: 1, min: 0, sec: 0}}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "does not update chosen resource if finishing time is equal to starting time", %{conn: conn} do
    {:ok, created_course} = create_course()
    class_insert_args = %Class{course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0}), status: "Planned"}
    class = Repo.insert! class_insert_args
    update_params = %{@valid_attrs | course_id: created_course.id, starting_at: %{hour: 2, min: 0, sec: 0}, finishes_at: %{hour: 2, min: 0, sec: 0}}
    conn = put conn, class_path(conn, :update, class), class: update_params
    assert html_response(conn, 200) =~ "Edit class"
  end

  test "deletes a non-existing id", %{conn: conn} do
    conn = delete conn, class_path(conn, :delete, -1)
    assert html_response(conn, 404)
  end

  test "hard deletes chosen resource when status is Planned", %{conn: conn} do
    {:ok, created_course} = create_course()
    class_args = %Class{course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0}), status: "Planned"}
    class = Repo.insert! class_args
    conn = delete conn, class_path(conn, :delete, class)
    assert redirected_to(conn) == class_path(conn, :index)
    refute Repo.get(Class, class.id)
  end


  test "all values which will be soft deleted", %{conn: conn} do
    ["Active", "Finished", "Graduated", "Frozen"]
    |> Enum.map(fn(status)->
         delete_and_check_soft_delete_with_status(status, conn)
       end)
  end

  defp delete_and_check_soft_delete_with_status(status, conn) do
    {:ok, created_course} = create_course()
    class_args = %Class{course_id: created_course.id, date: Ecto.Date.from_erl({2010, 01, 01}), starting_at: Ecto.Time.from_erl({13, 0, 0}), finishes_at: Ecto.Time.from_erl({14, 0, 0}), status: status}
    class = Repo.insert! class_args
    conn = delete conn, class_path(conn, :delete, class)
    assert redirected_to(conn) == class_path(conn, :index)
    soft_deleted_course = Repo.get(Class, class.id)
    assert soft_deleted_course.deleted_at
  end
end