defmodule TempFile.NameGenerator do
  @moduledoc false

  @random_part_length 48

  @spec generate_name() :: String.t()
  def generate_name do
    do_generate_name(nil, [])
  end

  @spec generate_name(String.t() | Keyword.t()) :: String.t()
  def generate_name(basename_or_opts)

  def generate_name(basename) when is_binary(basename) do
    do_generate_name(basename, [])
  end

  def generate_name(opts) when is_list(opts) do
    do_generate_name(nil, opts)
  end

  @spec generate_name(nil | String.t(), Keyword.t()) :: String.t()
  def generate_name(basename, opts) do
    do_generate_name(basename, opts)
  end

  defp do_generate_name(basename, opts) do
    [opts[:prefix], basename, generate_random_part(), opts[:suffix]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("-")
    |> Kernel.<>(to_string(opts[:extname]))
  end

  defp generate_random_part do
    @random_part_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, @random_part_length)
  end
end
