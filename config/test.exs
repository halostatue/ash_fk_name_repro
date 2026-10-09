import Config

config :ash_fk_name_repro, AshFkNameRepro.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ash_fk_name_repro_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :ash, policies: [show_policy_breakdowns?: true], disable_async?: true
