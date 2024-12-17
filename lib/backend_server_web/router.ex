defmodule BackendServerWeb.Router do
  use BackendServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BackendServerWeb do
    pipe_through :api

    post "/generate-shader", ShaderController, :generate
  end

end
