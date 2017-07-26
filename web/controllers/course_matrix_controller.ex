defmodule CoursePlanner.CourseMatrixController do
  @moduledoc false
  use CoursePlanner.Web, :controller

  alias CoursePlanner.OfferedCourses

  import Canary.Plugs
  plug :authorize_controller

  def index(conn, %{"term_id" => term_id}) do
    render(conn, "index.html",
      courses: OfferedCourses.find_by_term_id(term_id) ,
      matrix: OfferedCourses.student_matrix(term_id))
  end
end
