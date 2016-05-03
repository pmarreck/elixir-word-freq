defmodule Words do
  # def word_freq(l) do
  #   case l do
  #     [] -> %{}
  #     [w|ws] ->
  #       counts = word_freq(ws)
  #       Map.update(counts, w, 1, fn(count) -> count + 1 end)
  #   end
  # end

  def word_freq([]), do: %{}
  def word_freq([w|ws]), do: word_freq([w|ws], %{})
  def word_freq([], counts), do: counts
  def word_freq([w|ws], counts) do
    word_freq(ws, Map.update(counts, w, 1, &(&1+1)))
  end

  # FIXME: This is very awful.
  # def alphabetic?(c) do
  #   c in ?a..?z ||
  #   c in ?A..?Z ||
  #   c == 230
  # end

  def alphabetic?(c) when c in ?a..?z, do: true
  def alphabetic?(c) when c in ?A..?Z, do: true
  def alphabetic?(230), do: true
  def alphabetic?(_), do: false

  # def numeric?(c) do
  #   c in ?0..?9
  # end

  def numeric?(c) when c in ?0..?9, do: true
  def numeric?(_), do: false

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

# run this inline suite with "elixir #{__ENV__.file} bench"
if System.argv |> List.first == "bench" do
  defmodule Benchmark do
    def measure(function) do
      function
      |> :timer.tc
      |> elem(0)
      |> Kernel./(1_000_000)
    end
  end
  IO.puts "Benchmark for 'load!':"
  IO.puts Benchmark.measure(fn -> Words.load!("data/Zen.txt") end)
  IO.puts "Benchmark for 'load':"
  IO.puts Benchmark.measure(fn -> Words.load("data/Zen.txt") end)
end

# run this inline suite with "elixir #{__ENV__.file} test"
if System.argv |> List.first == "test" do
  ExUnit.start

  defmodule AlphanumericTest do
    use ExUnit.Case, async: true

    test "word_freq" do
      assert %{"Four" => 1, "ago" => 1, "and" => 2, "four" => 1, "score" => 1, "seconds" => 1, "seven" => 1, "years" => 1} == Words.word_freq("Four score and seven years ago and four seconds" |> String.split(" "))
    end
  end
end
