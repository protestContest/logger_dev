defmodule LoggerDev.Formatter do
  def format(level, message, {_date, time}, metadata) do
    module = Keyword.get(metadata, :module)

    if module_disabled(module) do
      ""
    else
      try do
        format_message(level, message, time, module)
      rescue
        err -> "Could not log message: #{inspect(err)}\n#{inspect(message)}"
      end
    end
  end

  defp module_disabled(nil), do: false

  defp module_disabled(module), do: module in Application.get_env(:logger_dev, :disable, [])

  defp format_message(level, message, time, module) do
    padding = Application.get_env(:logger_dev, :padding, 20)
    time_str = format_time(time)

    prefixes = [
      String.pad_trailing("#{time_str} [#{level}]", padding) | module_str(module, padding)
    ]

    pad_str = String.duplicate(" ", padding)
    line_len = term_width() - padding

    msg_lines =
      IO.iodata_to_binary(message)
      |> String.split("\n")
      |> Enum.map(fn line -> fit_message(line, line_len) end)
      |> List.flatten()

    message =
      Range.new(0, max(length(msg_lines), length(prefixes)) - 1)
      |> Enum.map(fn i -> {Enum.at(prefixes, i), Enum.at(msg_lines, i)} end)
      |> Enum.reduce([], fn
        {_prefix, nil}, lines -> lines
        {nil, msg}, lines -> [pad_str <> msg | lines]
        {prefix, msg}, lines -> [prefix <> msg | lines]
      end)
      |> Enum.reverse()
      |> Enum.join("\n")

    color = color_str(level, module)
    color <> "#{message}\n" <> IO.ANSI.reset()
  end

  defp format_time({hour, min, sec, _ms}),
    do: [
      String.pad_leading("#{hour}", 2, "0"),
      58,
      String.pad_leading("#{min}", 2, "0"),
      58,
      String.pad_leading("#{sec}", 2, "0")
    ]

  defp module_str(nil, _padding), do: []

  defp module_str(module, padding) do
    mod_str = Atom.to_string(module)
    parts = if String.match?(mod_str, ~r/^Elixir/), do: Module.split(mod_str), else: [mod_str]

    parts
    |> Enum.reduce([], fn
      part, [] ->
        [part]

      part, [line | rest] = lines ->
        if String.length(part) + String.length(line) + 1 < padding do
          ["#{line}.#{part}" | rest]
        else
          [part | lines]
        end
    end)
    |> Enum.map(&String.pad_trailing(&1, padding))
  end

  defp color_str(:error, _module), do: IO.ANSI.red() <> IO.ANSI.bright()
  defp color_str(_level, nil), do: ""

  @red_colors [9, 124, 160, 161, 196, 197, 198]
  defp color_str(_level, module) do
    module.__info__(:md5)
    |> :binary.bin_to_list()
    |> Enum.find(0, fn byte -> if byte not in @red_colors, do: byte end)
    |> IO.ANSI.color()
  end

  defp fit_message("", _len), do: ""

  defp fit_message(message, len) do
    String.graphemes(message)
    |> Enum.reduce([], fn
      grapheme, [] ->
        [grapheme]

      grapheme, [line | rest] = lines ->
        if String.length(line) + 1 < len do
          [line <> grapheme | rest]
        else
          [grapheme | lines]
        end
    end)
    |> Enum.reverse()
  end

  defp term_width do
    case :io.columns() do
      {:ok, width} -> max(40, width)
      _ -> 80
    end
  end
end
