defmodule Ecto.ULID do
  @moduledoc """
  An Ecto type for ULID strings.
  """

  @default_params %{variant: :b32}

  # replace with `use Ecto.ParameterizedType` after Ecto 3.2.0 is required
  @behaviour Ecto.ParameterizedType
  # and remove both of these functions
  def embed_as(_, _params), do: :self
  def equal?(term1, term2, _params), do: term1 == term2

  @doc """
  The underlying schema type.
  """
  def type(_params), do: :uuid

  @doc false
    def init(opts) do
    case Keyword.get(opts, :variant, :b32) do
      v when v in [:b32, :b64, :push] -> %{variant: v}
      _ -> raise "Ecto.ULID variant must be one of [:b32, :b64, :push]"
    end
  end

  @doc """
  Casts a string to ULID.
  """
  def cast(value, params \\ @default_params)
  def cast(nil, _params), do: {:ok, nil}
  def cast(<<_::bytes-size(26)>> = value, %{variant: :b32}) do
    # Crockford Base32 encoded string
    if valid?(value) do
      {:ok, value}
    else
      :error
    end
  end
  def cast(<<_::bytes-size(22)>> = value, %{variant: :b64}) do
    # Lexicographic Base64 encoded string
    if valid64?(value) do
      {:ok, value}
    else
      :error
    end
  end
  def cast(<<_::bytes-size(20)>> = value, %{variant: :push}) do
    # Firebase-Push-Key Base64 encoded string
    if valid64?(value) do
      {:ok, value}
    else
      :error
    end
  end
  def cast(_, _params), do: :error

  @doc """
  Same as `cast/2` but raises `Ecto.CastError` on invalid arguments.
  """
  def cast!(value, params \\ @default_params) do
    case cast(value, params) do
      {:ok, ulid} -> ulid
      :error -> raise Ecto.CastError, type: __MODULE__, value: value
    end
  end

  @doc """
  Converts a Crockford Base32 encoded string or
  Lexicographic Base64 encoded string or Firebase-Push-Key Base64 encoded string
  into a binary ULID.
  """
  def dump(encoded)
  def dump(<<_::bytes-size(26)>> = encoded), do: decode(encoded)
  def dump(<<_::bytes-size(22)>> = encoded), do: decode64(encoded)
  def dump(<<_::bytes-size(20)>> = encoded), do: decode64(encoded)
  def dump(_), do: :error

  @doc false
  def dump(nil, _, _), do: {:ok, nil}
  def dump(encoded, _dumper, _params), do: dump(encoded)

  @doc """
  Converts a binary ULID into an encoded string (defaults to Crockford Base32 encoding).

  Variants:

  * `:b32`: Crockford Base32 encoding (default)
  * `:b64`: Lexicographic Base64 encoding
  * `:push`: Firebase Push-Key Base64 encoding

  Arguments:

  * `bytes`: A binary ULID.
  * `variant`: :b32 (default), :b64 (Base64), or :push (Firebase Push-Key).
  """
  def load(bytes, variant \\ :b32)
  def load(<<_::unsigned-size(128)>> = bytes, :b32), do: encode(bytes)
  def load(<<_::unsigned-size(128)>> = bytes, :b64), do: encode64(bytes)
  def load(<<ts::bits-size(48), _::bits-size(8), rand::bits-size(72)>> = _bytes, :push), do: encode64(<<ts::binary, rand::binary>>)
  def load(_, _variant), do: :error

  @doc false
  def load(nil, _, _), do: {:ok, nil}
  def load(bytes, _loader, %{variant: variant}), do: load(bytes, variant)
  def load(_, _loader, _params), do: :error

  @doc false
  def autogenerate(%{variant: variant} = _params), do: generate(variant)

  @doc """
  Generates a string encoded ULID (defaults to Crockford Base32 encoding).

  If a value is provided for `timestamp`, the generated ULID will be for the provided timestamp.
  Otherwise, a ULID will be generated for the current time.

  Variants:

  * `:b32`: Crockford Base32 encoding (default)
  * `:b64`: Lexicographic Base64 encoding
  * `:push`: Firebase Push-Key Base64 encoding

  Arguments:

  * `variant`: :b32 (default), :b64 (Base64), or :push (Firebase Push-Key).
  * `timestamp`: A Unix timestamp with millisecond precision.
  """
  def generate(variant \\ :b32, timestamp \\ System.system_time(:millisecond))
  def generate(:b32, timestamp) do
    {:ok, ulid} = encode(bingenerate(timestamp))
    ulid
  end
  def generate(:b64, timestamp) do
    {:ok, ulid} = encode64(bingenerate(timestamp))
    ulid
  end
  def generate(:push, timestamp) do
    <<ts::bits-size(48), _::bits-size(8), rand::bits-size(72)>> = bingenerate(timestamp)
    {:ok, ulid} = encode64(<<ts::binary, rand::binary>>)
    ulid
  end
  def generate(timestamp, _) when is_integer(timestamp) do
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

  defp encode(<< b1::3,  b2::5,  b3::5,  b4::5,  b5::5,  b6::5,  b7::5,  b8::5,  b9::5, b10::5, b11::5, b12::5, b13::5,
                b14::5, b15::5, b16::5, b17::5, b18::5, b19::5, b20::5, b21::5, b22::5, b23::5, b24::5, b25::5, b26::5>>) do
    <<e(b1), e(b2), e(b3), e(b4), e(b5), e(b6), e(b7), e(b8), e(b9), e(b10), e(b11), e(b12), e(b13),
      e(b14), e(b15), e(b16), e(b17), e(b18), e(b19), e(b20), e(b21), e(b22), e(b23), e(b24), e(b25), e(b26)>>
  catch
    :error -> :error
  else
    encoded -> {:ok, encoded}
  end
  defp encode(_), do: :error

  defp encode64(<< b1::2,  b2::6,  b3::6,  b4::6,  b5::6,  b6::6,  b7::6,  b8::6,  b9::6, b10::6, b11::6, b12::6, b13::6,
                b14::6, b15::6, b16::6, b17::6, b18::6, b19::6, b20::6, b21::6, b22::6>>) do
    <<e64(b1), e64(b2), e64(b3), e64(b4), e64(b5), e64(b6), e64(b7), e64(b8), e64(b9), e64(b10), e64(b11), e64(b12), e64(b13),
      e64(b14), e64(b15), e64(b16), e64(b17), e64(b18), e64(b19), e64(b20), e64(b21), e64(b22)>>
  catch
    :error -> :error
  else
    encoded -> {:ok, encoded}
  end
  defp encode64(<< b1::6,  b2::6,  b3::6,  b4::6,  b5::6,  b6::6,  b7::6,  b8::6,  b9::6, b10::6, b11::6, b12::6, b13::6,
                b14::6, b15::6, b16::6, b17::6, b18::6, b19::6, b20::6>>) do
    <<e64(b1), e64(b2), e64(b3), e64(b4), e64(b5), e64(b6), e64(b7), e64(b8), e64(b9), e64(b10), e64(b11), e64(b12), e64(b13),
      e64(b14), e64(b15), e64(b16), e64(b17), e64(b18), e64(b19), e64(b20)>>
  catch
    :error -> :error
  else
    encoded -> {:ok, encoded}
  end
  defp encode64(_), do: :error

  @compile {:inline, e: 1, e64: 1}

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

  defp e64(0), do: ?-
  defp e64(1), do: ?0
  defp e64(2), do: ?1
  defp e64(3), do: ?2
  defp e64(4), do: ?3
  defp e64(5), do: ?4
  defp e64(6), do: ?5
  defp e64(7), do: ?6
  defp e64(8), do: ?7
  defp e64(9), do: ?8
  defp e64(10), do: ?9
  defp e64(11), do: ?A
  defp e64(12), do: ?B
  defp e64(13), do: ?C
  defp e64(14), do: ?D
  defp e64(15), do: ?E
  defp e64(16), do: ?F
  defp e64(17), do: ?G
  defp e64(18), do: ?H
  defp e64(19), do: ?I
  defp e64(20), do: ?J
  defp e64(21), do: ?K
  defp e64(22), do: ?L
  defp e64(23), do: ?M
  defp e64(24), do: ?N
  defp e64(25), do: ?O
  defp e64(26), do: ?P
  defp e64(27), do: ?Q
  defp e64(28), do: ?R
  defp e64(29), do: ?S
  defp e64(30), do: ?T
  defp e64(31), do: ?U
  defp e64(32), do: ?V
  defp e64(33), do: ?W
  defp e64(34), do: ?X
  defp e64(35), do: ?Y
  defp e64(36), do: ?Z
  defp e64(37), do: ?_
  defp e64(38), do: ?a
  defp e64(39), do: ?b
  defp e64(40), do: ?c
  defp e64(41), do: ?d
  defp e64(42), do: ?e
  defp e64(43), do: ?f
  defp e64(44), do: ?g
  defp e64(45), do: ?h
  defp e64(46), do: ?i
  defp e64(47), do: ?j
  defp e64(48), do: ?k
  defp e64(49), do: ?l
  defp e64(50), do: ?m
  defp e64(51), do: ?n
  defp e64(52), do: ?o
  defp e64(53), do: ?p
  defp e64(54), do: ?q
  defp e64(55), do: ?r
  defp e64(56), do: ?s
  defp e64(57), do: ?t
  defp e64(58), do: ?u
  defp e64(59), do: ?v
  defp e64(60), do: ?w
  defp e64(61), do: ?x
  defp e64(62), do: ?y
  defp e64(63), do: ?z

  defp decode(<< c1::8,  c2::8,  c3::8,  c4::8,  c5::8,  c6::8,  c7::8,  c8::8,  c9::8, c10::8, c11::8, c12::8, c13::8,
                c14::8, c15::8, c16::8, c17::8, c18::8, c19::8, c20::8, c21::8, c22::8, c23::8, c24::8, c25::8, c26::8>>) do
    << d(c1)::3,  d(c2)::5,  d(c3)::5,  d(c4)::5,  d(c5)::5,  d(c6)::5,  d(c7)::5,  d(c8)::5,  d(c9)::5, d(c10)::5, d(c11)::5, d(c12)::5, d(c13)::5,
      d(c14)::5, d(c15)::5, d(c16)::5, d(c17)::5, d(c18)::5, d(c19)::5, d(c20)::5, d(c21)::5, d(c22)::5, d(c23)::5, d(c24)::5, d(c25)::5, d(c26)::5>>
  catch
    :error -> :error
  else
    decoded -> {:ok, decoded}
  end
  defp decode(_), do: :error

  defp decode64(<< c1::8,  c2::8,  c3::8,  c4::8,  c5::8,  c6::8,  c7::8,  c8::8,  c9::8, c10::8, c11::8, c12::8, c13::8,
                c14::8, c15::8, c16::8, c17::8, c18::8, c19::8, c20::8, c21::8, c22::8>>) do
    << d64(c1)::2,  d64(c2)::6,  d64(c3)::6,  d64(c4)::6,  d64(c5)::6,  d64(c6)::6,  d64(c7)::6,  d64(c8)::6,  d64(c9)::6, d64(c10)::6, d64(c11)::6, d64(c12)::6, d64(c13)::6,
      d64(c14)::6, d64(c15)::6, d64(c16)::6, d64(c17)::6, d64(c18)::6, d64(c19)::6, d64(c20)::6, d64(c21)::6, d64(c22)::6>>
  catch
    :error -> :error
  else
    decoded -> {:ok, decoded}
  end
  defp decode64(<< c1::8,  c2::8,  c3::8,  c4::8,  c5::8,  c6::8,  c7::8,  c8::8,  c9::8, c10::8, c11::8, c12::8, c13::8,
                c14::8, c15::8, c16::8, c17::8, c18::8, c19::8, c20::8>>) do
    << d64(c1)::6,  d64(c2)::6,  d64(c3)::6,  d64(c4)::6,  d64(c5)::6,  d64(c6)::6,  d64(c7)::6, d64(c8)::6, 0::unsigned-size(8), d64(c9)::6, d64(c10)::6, d64(c11)::6, d64(c12)::6, d64(c13)::6,
      d64(c14)::6, d64(c15)::6, d64(c16)::6, d64(c17)::6, d64(c18)::6, d64(c19)::6, d64(c20)::6>>
  catch
    :error -> :error
  else
    decoded -> {:ok, decoded}
  end
  defp decode64(_), do: :error

  @compile {:inline, d: 1, d64: 1}

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
  defp d(_), do: throw :error

  defp d64(?-), do: 0
  defp d64(?0), do: 1
  defp d64(?1), do: 2
  defp d64(?2), do: 3
  defp d64(?3), do: 4
  defp d64(?4), do: 5
  defp d64(?5), do: 6
  defp d64(?6), do: 7
  defp d64(?7), do: 8
  defp d64(?8), do: 9
  defp d64(?9), do: 10
  defp d64(?A), do: 11
  defp d64(?B), do: 12
  defp d64(?C), do: 13
  defp d64(?D), do: 14
  defp d64(?E), do: 15
  defp d64(?F), do: 16
  defp d64(?G), do: 17
  defp d64(?H), do: 18
  defp d64(?I), do: 19
  defp d64(?J), do: 20
  defp d64(?K), do: 21
  defp d64(?L), do: 22
  defp d64(?M), do: 23
  defp d64(?N), do: 24
  defp d64(?O), do: 25
  defp d64(?P), do: 26
  defp d64(?Q), do: 27
  defp d64(?R), do: 28
  defp d64(?S), do: 29
  defp d64(?T), do: 30
  defp d64(?U), do: 31
  defp d64(?V), do: 32
  defp d64(?W), do: 33
  defp d64(?X), do: 34
  defp d64(?Y), do: 35
  defp d64(?Z), do: 36
  defp d64(?_), do: 37
  defp d64(?a), do: 38
  defp d64(?b), do: 39
  defp d64(?c), do: 40
  defp d64(?d), do: 41
  defp d64(?e), do: 42
  defp d64(?f), do: 43
  defp d64(?g), do: 44
  defp d64(?h), do: 45
  defp d64(?i), do: 46
  defp d64(?j), do: 47
  defp d64(?k), do: 48
  defp d64(?l), do: 49
  defp d64(?m), do: 50
  defp d64(?n), do: 51
  defp d64(?o), do: 52
  defp d64(?p), do: 53
  defp d64(?q), do: 54
  defp d64(?r), do: 55
  defp d64(?s), do: 56
  defp d64(?t), do: 57
  defp d64(?u), do: 58
  defp d64(?v), do: 59
  defp d64(?w), do: 60
  defp d64(?x), do: 61
  defp d64(?y), do: 62
  defp d64(?z), do: 63
  defp d64(_), do: throw :error

  defp valid?(<< c1::8,  c2::8,  c3::8,  c4::8,  c5::8,  c6::8,  c7::8,  c8::8,  c9::8, c10::8, c11::8, c12::8, c13::8,
                c14::8, c15::8, c16::8, c17::8, c18::8, c19::8, c20::8, c21::8, c22::8, c23::8, c24::8, c25::8, c26::8>>) do
     c1 in [?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7] &&
     v(c2) &&  v(c3) &&  v(c4) &&  v(c5) &&  v(c6) &&  v(c7) &&  v(c8) &&  v(c9) && v(c10) && v(c11) && v(c12) && v(c13) &&
    v(c14) && v(c15) && v(c16) && v(c17) && v(c18) && v(c19) && v(c20) && v(c21) && v(c22) && v(c23) && v(c24) && v(c25) && v(c26)
  end
  defp valid?(_), do: false

  defp valid64?(<< c1::8,  c2::8,  c3::8,  c4::8,  c5::8,  c6::8,  c7::8,  c8::8,  c9::8, c10::8, c11::8, c12::8, c13::8,
                c14::8, c15::8, c16::8, c17::8, c18::8, c19::8, c20::8, c21::8, c22::8>>) do
     v64(c1) &&  v64(c2) &&  v64(c3) &&  v64(c4) &&  v64(c5) &&  v64(c6) &&  v64(c7) &&  v64(c8) &&  v64(c9) && v64(c10) && v64(c11) && v64(c12) && v64(c13) &&
    v64(c14) && v64(c15) && v64(c16) && v64(c17) && v64(c18) && v64(c19) && v64(c20) && v64(c21) && v64(c22)
  end
  defp valid64?(<< c1::8,  c2::8,  c3::8,  c4::8,  c5::8,  c6::8,  c7::8,  c8::8,  c9::8, c10::8, c11::8, c12::8, c13::8,
                c14::8, c15::8, c16::8, c17::8, c18::8, c19::8, c20::8>>) do
     v64(c1) &&  v64(c2) &&  v64(c3) &&  v64(c4) &&  v64(c5) &&  v64(c6) &&  v64(c7) &&  v64(c8) &&  v64(c9) && v64(c10) && v64(c11) && v64(c12) && v64(c13) &&
    v64(c14) && v64(c15) && v64(c16) && v64(c17) && v64(c18) && v64(c19) && v64(c20)
  end
  defp valid64?(_), do: false

  @compile {:inline, v: 1, v64: 1}

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

  defp v64(?-), do: true
  defp v64(?0), do: true
  defp v64(?1), do: true
  defp v64(?2), do: true
  defp v64(?3), do: true
  defp v64(?4), do: true
  defp v64(?5), do: true
  defp v64(?6), do: true
  defp v64(?7), do: true
  defp v64(?8), do: true
  defp v64(?9), do: true
  defp v64(?A), do: true
  defp v64(?B), do: true
  defp v64(?C), do: true
  defp v64(?D), do: true
  defp v64(?E), do: true
  defp v64(?F), do: true
  defp v64(?G), do: true
  defp v64(?H), do: true
  defp v64(?I), do: true
  defp v64(?J), do: true
  defp v64(?K), do: true
  defp v64(?L), do: true
  defp v64(?M), do: true
  defp v64(?N), do: true
  defp v64(?O), do: true
  defp v64(?P), do: true
  defp v64(?Q), do: true
  defp v64(?R), do: true
  defp v64(?S), do: true
  defp v64(?T), do: true
  defp v64(?U), do: true
  defp v64(?V), do: true
  defp v64(?W), do: true
  defp v64(?X), do: true
  defp v64(?Y), do: true
  defp v64(?Z), do: true
  defp v64(?_), do: true
  defp v64(?a), do: true
  defp v64(?b), do: true
  defp v64(?c), do: true
  defp v64(?d), do: true
  defp v64(?e), do: true
  defp v64(?f), do: true
  defp v64(?g), do: true
  defp v64(?h), do: true
  defp v64(?i), do: true
  defp v64(?j), do: true
  defp v64(?k), do: true
  defp v64(?l), do: true
  defp v64(?m), do: true
  defp v64(?n), do: true
  defp v64(?o), do: true
  defp v64(?p), do: true
  defp v64(?q), do: true
  defp v64(?r), do: true
  defp v64(?s), do: true
  defp v64(?t), do: true
  defp v64(?u), do: true
  defp v64(?v), do: true
  defp v64(?w), do: true
  defp v64(?x), do: true
  defp v64(?y), do: true
  defp v64(?z), do: true
  defp v64(_), do: false
end
