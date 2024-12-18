import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: BackendServer.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Endpoint Configuration
config :backend_server, BackendServerWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST"), port: 443],
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  server: true,
  check_origin: [System.get_env("FRONTEND_HOST") || "http://localhost:3000"]

# # OpenAI Configuration
# config :backend_server, :openai,
#   api_url: System.fetch_env!("OPENAI_API_URL"),
#   api_key: System.fetch_env!("OPENAI_API_KEY")
