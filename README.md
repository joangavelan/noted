# Noted

This is a multi-tenant notes application built with the Phoenix Framework, featuring OAuth2 authentication via Google and Facebook, Role-Based Access Control (RBAC), real-time updates with Phoenix PubSub, and multi-tenancy using foreign keys.

## Features

- **OAuth2 Authentication**: Supports authentication via Google and Facebook using the Assent library.
- **Multi-Tenancy**: Uses foreign keys to isolate tenant data securely.
- **RBAC (Role-Based Access Control)**: Provides authorization for different user roles.
- **Real-Time Updates**: Instant updates across tenants using Phoenix PubSub.
- **Notes Management**: Create, edit, delete, and organize notes within a tenant.

## Prerequisites

Before setting up the application, ensure you have the following installed:

- **Elixir**: Version 1.14 or later. [Installation Guide](https://elixir-lang.org/install.html)
- **Erlang**: Version 24 or later. [Installation Guide](https://elixir-lang.org/install.html)
- **PostgreSQL**: Ensure it's installed and running. [Installation Guide](https://www.postgresql.org/download/)

## Setup Instructions

### Clone the Repository

```bash
git clone https://github.com/joangavelan/noted.git
cd noted
```

### Install Dependencies

Fetch and install the necessary dependencies:

```bash
mix deps.get
```

### Configure Environment Variables

The application requires environment variables for Google and Facebook OAuth2 authentication. Create a file named `.env` in the project root and add the following variables:

```bash
export GOOGLE_CLIENT_ID=your_google_client_id
export GOOGLE_CLIENT_SECRET=your_google_client_secret

export FACEBOOK_CLIENT_ID=your_facebook_client_id
export FACEBOOK_CLIENT_SECRET=your_facebook_client_secret
```

Replace `your_google_client_id`, `your_google_client_secret`, `your_facebook_client_id`, and `your_facebook_client_secret` with your actual OAuth2 credentials.

### Database Configuration

Configure your database settings in `config/dev.exs`. Ensure the `username`, `password`, `hostname`, and `database` fields match your PostgreSQL setup:

```elixir
config :noted, Noted.Repo,
  username: "your_db_username",
  password: "your_db_password",
  hostname: "localhost",
  database: "noted_dev",
```
### Create and Migrate the Database

Set up the database by running:

```bash
mix ecto.create
mix ecto.migrate
```

### Start the Server

Start the Phoenix server while loading the `.env` file:

```bash
source .env && mix phx.server
```

The `source .env` command ensures your environment variables are loaded, and `mix phx.server` starts the application. The app will be accessible at [http://localhost:4000](http://localhost:4000).

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request with improvements or feedback.

---
