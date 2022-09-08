defmodule LoggerDev do
  @moduledoc """
  This supplies a formatting module for `Logger.Backends.Console` that makes the
  log a little more readable. It prints logs in different colors based on the
  logging module, and shows the time, level, and module in a left gutter.

  ## Config

  The width of the gutter can be controlled with the `:padding` config key. The
  default is 20.

      config :logger_dev, padding: 25

  Modules can be silenced from the log with the `:disable` config key.

      config :logger_dev, disable: [Phoenix.Logger, Ecto.Adapters.SQL]
  """
end
