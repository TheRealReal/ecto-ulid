defmodule Ecto.ULID do
  @moduledoc """
  An Ecto type for ULID strings.
  """

  use Ecto.Type

  @typedoc """
  A hex-encoded ULID string.
  """
  @type t :: <<_::208>>

  @doc """
  The underlying schema type.
  """
  def type, do: :uuid

  @doc """
  Casts a string to ULID.
  """
  def cast(<<_::bytes-size(26)>> = value) do
    if valid?(value) do
      {:ok, value}
    else
      :error
    end
  end

  def cast(_), do: :error

  @doc """
  Same as `cast/1` but raises `Ecto.CastError` on invalid arguments.
  """
  def cast!(value) do
    case cast(value) do
      {:ok, ulid} -> ulid
      :error -> raise Ecto.CastError, type: __MODULE__, value: value
    end
  end

  @doc """
  Converts a Crockford Base32 encoded ULID into a binary.
  """
  def dump(<<_::bytes-size(26)>> = encoded), do: decode(encoded)
  def dump(_), do: :error

  @doc """
  Converts a binary ULID into a Crockford Base32 encoded string.
  """
  def load(<<_::unsigned-size(128)>> = bytes), do: encode(bytes)
  def load(_), do: :error

  @doc false
  def autogenerate, do: generate()

  @doc """
  Generates a Crockford Base32 encoded ULID.

  If a value is provided for `timestamp`, the generated ULID will be for the provided timestamp.
  Otherwise, a ULID will be generated for the current time.

  Arguments:

  * `timestamp`: A Unix timestamp with millisecond precision.
  """
  def generate(timestamp \\ System.system_time(:millisecond)) do
    {:ok, ulid} = encode(bingenerate(timestamp))
    ulid
  end

  @doc """
  Generates a binary ULID.

  If a value is provided for `timestamp`, the generated ULID will be for the provided timestamp.
  Otherwise, a ULID will be generated for the current time.

  Arguments:

  * `timestamp`: A Unix timestamp with millisecond precision.
  """
  def bingenerate(timestamp \\ System.system_time(:millisecond)) do
    <<timestamp::unsigned-size(48), :crypto.strong_rand_bytes(10)::binary>>
  end

  defp encode(
         <<b1::3, b2::5, b3::5, b4::5, b5::5, b6::5, b7::5, b8::5, b9::5,
           b10::5, b11::5, b12::5, b13::5, b14::5, b15::5, b16::5, b17::5,
           b18::5, b19::5, b20::5, b21::5, b22::5, b23::5, b24::5, b25::5,
           b26::5>>
       ) do
    <<e(b1), e(b2), e(b3), e(b4), e(b5), e(b6), e(b7), e(b8), e(b9), e(b10),
      e(b11), e(b12), e(b13), e(b14), e(b15), e(b16), e(b17), e(b18), e(b19),
      e(b20), e(b21), e(b22), e(b23), e(b24), e(b25), e(b26)>>
  catch
    :error -> :error
  else
    encoded -> {:ok, encoded}
  end

  defp encode(_), do: :error

  @compile {:inline, e: 1}

  defp e(0), do: ?0
  defp e(1), do: ?1
  defp e(2), do: ?2
  defp e(3), do: ?3
  defp e(4), do: ?4
  defp e(5), do: ?5
  defp e(6), do: ?6
  defp e(7), do: ?7
  defp e(8), do: ?8
  defp e(9), do: ?9
  defp e(10), do: ?A
  defp e(11), do: ?B
  defp e(12), do: ?C
  defp e(13), do: ?D
  defp e(14), do: ?E
  defp e(15), do: ?F
  defp e(16), do: ?G
  defp e(17), do: ?H
  defp e(18), do: ?J
  defp e(19), do: ?K
  defp e(20), do: ?M
  defp e(21), do: ?N
  defp e(22), do: ?P
  defp e(23), do: ?Q
  defp e(24), do: ?R
  defp e(25), do: ?S
  defp e(26), do: ?T
  defp e(27), do: ?V
  defp e(28), do: ?W
  defp e(29), do: ?X
  defp e(30), do: ?Y
  defp e(31), do: ?Z

  defp decode(
         <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8, c8::8, c9::8,
           c10::8, c11::8, c12::8, c13::8, c14::8, c15::8, c16::8, c17::8,
           c18::8, c19::8, c20::8, c21::8, c22::8, c23::8, c24::8, c25::8,
           c26::8>>
       ) do
    <<d(c1)::3, d(c2)::5, d(c3)::5, d(c4)::5, d(c5)::5, d(c6)::5, d(c7)::5,
      d(c8)::5, d(c9)::5, d(c10)::5, d(c11)::5, d(c12)::5, d(c13)::5, d(c14)::5,
      d(c15)::5, d(c16)::5, d(c17)::5, d(c18)::5, d(c19)::5, d(c20)::5,
      d(c21)::5, d(c22)::5, d(c23)::5, d(c24)::5, d(c25)::5, d(c26)::5>>
  catch
    :error -> :error
  else
    decoded -> {:ok, decoded}
  end

  defp decode(_), do: :error

  @compile {:inline, d: 1}

  defp d(?0), do: 0
  defp d(?1), do: 1
  defp d(?2), do: 2
  defp d(?3), do: 3
  defp d(?4), do: 4
  defp d(?5), do: 5
  defp d(?6), do: 6
  defp d(?7), do: 7
  defp d(?8), do: 8
  defp d(?9), do: 9
  defp d(?A), do: 10
  defp d(?B), do: 11
  defp d(?C), do: 12
  defp d(?D), do: 13
  defp d(?E), do: 14
  defp d(?F), do: 15
  defp d(?G), do: 16
  defp d(?H), do: 17
  defp d(?J), do: 18
  defp d(?K), do: 19
  defp d(?M), do: 20
  defp d(?N), do: 21
  defp d(?P), do: 22
  defp d(?Q), do: 23
  defp d(?R), do: 24
  defp d(?S), do: 25
  defp d(?T), do: 26
  defp d(?V), do: 27
  defp d(?W), do: 28
  defp d(?X), do: 29
  defp d(?Y), do: 30
  defp d(?Z), do: 31
  defp d(_), do: throw(:error)

  defp valid?(
         <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8, c8::8, c9::8,
           c10::8, c11::8, c12::8, c13::8, c14::8, c15::8, c16::8, c17::8,
           c18::8, c19::8, c20::8, c21::8, c22::8, c23::8, c24::8, c25::8,
           c26::8>>
       ) do
    v(c1) && v(c2) && v(c3) && v(c4) && v(c5) && v(c6) && v(c7) && v(c8) &&
      v(c9) && v(c10) &&
      v(c11) && v(c12) && v(c13) &&
      v(c14) && v(c15) && v(c16) && v(c17) && v(c18) && v(c19) && v(c20) &&
      v(c21) && v(c22) &&
      v(c23) && v(c24) && v(c25) && v(c26)
  end

  defp valid?(_), do: false

  @compile {:inline, v: 1}

  defp v(?0), do: true
  defp v(?1), do: true
  defp v(?2), do: true
  defp v(?3), do: true
  defp v(?4), do: true
  defp v(?5), do: true
  defp v(?6), do: true
  defp v(?7), do: true
  defp v(?8), do: true
  defp v(?9), do: true
  defp v(?A), do: true
  defp v(?B), do: true
  defp v(?C), do: true
  defp v(?D), do: true
  defp v(?E), do: true
  defp v(?F), do: true
  defp v(?G), do: true
  defp v(?H), do: true
  defp v(?J), do: true
  defp v(?K), do: true
  defp v(?M), do: true
  defp v(?N), do: true
  defp v(?P), do: true
  defp v(?Q), do: true
  defp v(?R), do: true
  defp v(?S), do: true
  defp v(?T), do: true
  defp v(?V), do: true
  defp v(?W), do: true
  defp v(?X), do: true
  defp v(?Y), do: true
  defp v(?Z), do: true
  defp v(_), do: false
end
