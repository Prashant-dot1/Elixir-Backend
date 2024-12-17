import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: BackendServer.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

config :backend_server, BackendServerWeb.Endpoint,
  url: [host: "your-backend-domain.com", port: 443],
  http: [:inet6, port: System.get_env("PORT") || 4000],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  server: true,
  check_origin: ["https://your-frontend-domain.com"]

config :backend_server, :openai,
  api_url: System.fetch_env!("OPENAI_API_URL"),
  api_key: System.fetch_env!("OPENAI_API_KEY")

# CORS configuration
config :backend_server, :cors,
  allowed_origins: ["https://your-frontend-domain.com"]
