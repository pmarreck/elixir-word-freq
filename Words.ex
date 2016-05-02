defmodule Words do
  def word_freq(l) do
    case l do
      [] -> %{}
      [w|ws] ->
        counts = word_freq(ws)
        Map.update(counts, w, 1, fn(count) -> count + 1 end)
    end
  end

  # FIXME: This is very awful.
  def alphabetic?(c) do
    c in ?a..?z ||
    c in ?A..?Z ||
    c == 230
  end

  def numeric?(c) do
    c in ?0..?9
  end

  def alphanumeric?(c) do
    numeric?(c) || alphabetic?(c)
  end

  # Note: The regex chews most of the time here.
  def load(file) do
    punctuation = ~r/[^[:alnum:]]/u
    words = File.read!(file) |>
      String.downcase |> String.replace(punctuation, " ") |> String.splitter(" ", trim: true)
    words |> word_filter
  end

  def word_filter(words) do
    words |> Stream.filter(fn w -> String.length(w) > 3 end) |> Enum.to_list
  end

  def load!(file) do
    File.read!(file) |>
    to_char_list |>
    Enum.map(fn c -> if alphanumeric?(c), do: c, else: " " end) |>
    to_string |>
    String.downcase |>
    String.splitter(" ", trim: true) |>
    word_filter
  end
end

defmodule Benchmark do
  def measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end
