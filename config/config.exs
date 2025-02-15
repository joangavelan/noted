# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :noted,
  ecto_repos: [Noted.Repo]

config :noted, Noted.Repo, migration_primary_key: [name: :id, type: :binary_id]
config :noted, Noted.Repo, migration_foreign_key: [column: :id, type: :binary_id]
config :noted, Noted.Repo, migration_timestamps: [type: :utc_datetime, inserted_at: :created_at]

# Configures the endpoint
config :noted, NotedWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: NotedWeb.ErrorHTML, json: NotedWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Noted.PubSub,
  live_view: [signing_salt: "/Rdz3Ss6"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  noted: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  noted: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :noted, :oauth_providers,
  google: [
    config: [
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET")
    ],
    strategy_mod: Assent.Strategy.Google
  ],
  facebook: [
    config: [
      client_id: System.get_env("FACEBOOK_CLIENT_ID"),
      client_secret: System.get_env("FACEBOOK_CLIENT_SECRET")
    ],
    strategy_mod: Assent.Strategy.Facebook
  ]
