# LoggerDev

This supplies a formatting module for `Logger.Backends.Console` that makes the
log a little more readable. It prints logs in different colors based on the
logging module, and shows the time, level, and module in a left gutter.

## Installation

The package can be installed by adding `logger_dev` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:logger_dev, "~> 0.1.1"}
  ]
end
```

## Config

For module-based color support (and to display module names), `:module` needs
to be added to the logger's metadata:

    config :logger, metadata: [:module]

The width of the gutter can be controlled with the `:padding` config key. The
default is 20.

    config :logger_dev, padding: 25

Modules can be silenced from the log with the `:disable` config key.

    config :logger_dev, disable: [Phoenix.Logger, Ecto.Adapters.SQL]

Dark colors are automatically avoided. If your terminal has a light background,
you can instead have light colors avoided.

    config :logger_dev, background: :light

Or, you can specify the colors to choose from. Colors are based on the [8-bit
ANSI terminal colors](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit).

    config :logger_dev, colors: [62, 63, 64, 65, 66, 67, 68, 69]

Red colors (9, 124, 160, 161, 196, 197, 198) are always avoided unless
included in the `:colors` config.
