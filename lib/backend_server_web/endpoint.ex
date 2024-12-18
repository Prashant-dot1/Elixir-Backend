defmodule BackendServerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :backend_server


  defmodule DebugPlug do
    import Plug.Conn

    def init(opts), do: opts

    def call(conn, _opts) do
      IO.inspect(conn.req_headers, label: "Incoming Request Headers")
      conn
    end
  end


  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_backend_server_key",
    signing_salt: "ibf7J+EN",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :backend_server,
    gzip: false,
    only: BackendServerWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug BackendServerWeb.Endpoint.DebugPlug

  IO.inspect(System.get_env("FRONTEND_HOST"), label: "Resolved FRONTEND_HOST")
  plug CORSPlug,
  origin: ["https://assignment-first.fly.dev" , "http://localhost:3000"], # Allow multiple origins
  methods: ["GET", "POST", "OPTIONS"],
  headers: ["Content-Type", "Authorization"]

  plug :log_response_headers

  defp log_response_headers(conn, _opts) do
    IO.inspect(conn.resp_headers, label: "Response Headers")
    conn
  end


  plug BackendServerWeb.Router

  # Configure CORS dynamically for production or development

  # plug Plug.Router
  # plug BackendServerWeb.Router

end
