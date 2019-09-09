defmodule TempFile.NameGenerator do
  @moduledoc false

  @random_part_length 48

  @spec generate_filename(nil | String.t(), Keyword.t()) :: String.t()
  def generate_filename(basename, opts) do
    [opts[:prefix], basename, random_part(), opts[:suffix]]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("-")
  end

  defp random_part do
    @random_part_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, @random_part_length)
  end
end
