defmodule BackendServerWeb.ShaderController do
  use BackendServerWeb, :controller

  alias BackendServer.Shader

  def generate(conn, %{"description" => description}) do
    case Shader.generate_shader(description) do
      {:ok, shader_data} ->
        json(conn, shader_data)

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end
end
