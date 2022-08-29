defmodule CmdGen.Naming do
  @spec underscore(String.t()) :: String.t()
  def underscore(value), do: Macro.underscore(value)

  @doc """
  Converts an attribute/form field into its humanize version.

  ## Examples

      iex> Phoenix.Naming.humanize(:username)
      "Username"
      iex> Phoenix.Naming.humanize(:created_at)
      "Created at"
      iex> Phoenix.Naming.humanize("user_id")
      "User"

  """
  @spec humanize(atom | String.t()) :: String.t()
  def humanize(atom) when is_atom(atom),
    do: humanize(Atom.to_string(atom))

  def humanize(bin) when is_binary(bin) do
    bin =
      if String.ends_with?(bin, "_id") do
        binary_part(bin, 0, byte_size(bin) - 3)
      else
        bin
      end

    bin |> String.replace("_", " ") |> String.capitalize()
  end

  @doc """
  Converts a string to camel case.

  Takes an optional `:lower` flag to return lowerCamelCase.

  ## Examples

      iex> Phoenix.Naming.camelize("my_app")
      "MyApp"

      iex> Phoenix.Naming.camelize("my_app", :lower)
      "myApp"

  In general, `camelize` can be thought of as the reverse of
  `underscore`, however, in some cases formatting may be lost:

      Phoenix.Naming.underscore "SAPExample"  #=> "sap_example"
      Phoenix.Naming.camelize   "sap_example" #=> "SapExample"

  """
  @spec camelize(String.t()) :: String.t()
  def camelize(value), do: Macro.camelize(value)

  @spec camelize(String.t(), :lower) :: String.t()
  def camelize("", :lower), do: ""

  def camelize(<<?_, t::binary>>, :lower) do
    camelize(t, :lower)
  end

  def camelize(<<h, _t::binary>> = value, :lower) do
    <<_first, rest::binary>> = camelize(value)
    <<to_lower_char(h)>> <> rest
  end

  defp to_lower_char(char) when char in ?A..?Z, do: char + 32
  defp to_lower_char(char), do: char
end
