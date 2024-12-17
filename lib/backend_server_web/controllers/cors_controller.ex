defmodule BackendServerWeb.CORSController do
  use BackendServerWeb, :controller

  def options(conn, _params) do
    conn
    |> put_resp_header("access-control-allow-origin", "http://localhost:3000")
    |> put_resp_header("access-control-allow-methods", "POST, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "Authorization, Content-Type")
    |> send_resp(204, "") # Respond with 204 No Content for preflight
  end
end
