defmodule Ecto.ULIDTest do
  use ExUnit.Case, async: true

  @binary <<1, 95, 194, 60, 108, 73, 209, 114, 136, 236, 133, 115, 106, 195, 145, 22>>
  @encoded "01BZ13RV29T5S8HV45EDNC748P"
  @encoded_b64 "-0Mw7wQ3bGRcYgWMCekt3L"
  @encoded_push "-Kz1E5l8RcYgWMCekt3L"

  # generate/2

  test "generate/2 encodes milliseconds in first 10 characters" do
    # test case from ULID README: https://github.com/ulid/javascript#seed-time
    <<encoded::bytes-size(10), _rest::bytes-size(16)>> = Ecto.ULID.generate(1469918176385)

    assert encoded == "01ARYZ6S41"
  end

  test "generate/2 generates unique identifiers" do
    ulid1 = Ecto.ULID.generate()
    ulid2 = Ecto.ULID.generate()

    assert ulid1 != ulid2
  end

  # bingenerate/1

  test "bingenerate/1 encodes milliseconds in first 48 bits" do
    now = System.system_time(:millisecond)
    <<time::48, _random::80>> = Ecto.ULID.bingenerate()

    assert_in_delta now, time, 10
  end

  test "bingenerate/1 generates unique identifiers" do
    ulid1 = Ecto.ULID.bingenerate()
    ulid2 = Ecto.ULID.bingenerate()

    assert ulid1 != ulid2
  end

  # cast/2

  test "cast/2 returns valid ULID" do
    {:ok, ulid} = Ecto.ULID.cast(@encoded)
    assert ulid == @encoded
  end

  test "cast/2 returns ULID for encoding of correct length" do
    {:ok, ulid} = Ecto.ULID.cast("00000000000000000000000000")
    assert ulid == "00000000000000000000000000"
  end

  test "cast/2 returns error when encoding is too short" do
    assert Ecto.ULID.cast("0000000000000000000000000") == :error
  end

  test "cast/2 returns error when encoding is too long" do
    assert Ecto.ULID.cast("000000000000000000000000000") == :error
  end

  test "cast/2 returns error when encoding contains letter I" do
    assert Ecto.ULID.cast("I0000000000000000000000000") == :error
  end

  test "cast/2 returns error when encoding contains letter L" do
    assert Ecto.ULID.cast("L0000000000000000000000000") == :error
  end

  test "cast/2 returns error when encoding contains letter O" do
    assert Ecto.ULID.cast("O0000000000000000000000000") == :error
  end

  test "cast/2 returns error when encoding contains letter U" do
    assert Ecto.ULID.cast("U0000000000000000000000000") == :error
  end

  test "cast/2 returns error for invalid encoding" do
    assert Ecto.ULID.cast("$0000000000000000000000000") == :error
  end

  # dump/1

  test "dump/1 dumps valid ULID to binary" do
    {:ok, bytes} = Ecto.ULID.dump(@encoded)
    assert bytes == @binary
  end

  test "dump/1 dumps encoding of correct length" do
    {:ok, bytes} = Ecto.ULID.dump("00000000000000000000000000")
    assert bytes == <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
  end

  test "dump/1 returns error when encoding is too short" do
    assert Ecto.ULID.dump("0000000000000000000000000") == :error
  end

  test "dump/1 returns error when encoding is too long" do
    assert Ecto.ULID.dump("000000000000000000000000000") == :error
  end

  test "dump/1 returns error when encoding contains letter I" do
    assert Ecto.ULID.dump("I0000000000000000000000000") == :error
  end

  test "dump/1 returns error when encoding contains letter L" do
    assert Ecto.ULID.dump("L0000000000000000000000000") == :error
  end

  test "dump/1 returns error when encoding contains letter O" do
    assert Ecto.ULID.dump("O0000000000000000000000000") == :error
  end

  test "dump/1 returns error when encoding contains letter U" do
    assert Ecto.ULID.dump("U0000000000000000000000000") == :error
  end

  test "dump/1 returns error for invalid encoding" do
    assert Ecto.ULID.dump("$0000000000000000000000000") == :error
  end

  # load/2

  test "load/2 encodes binary as Base32" do
    {:ok, encoded} = Ecto.ULID.load(@binary)
    assert encoded == @encoded
  end

  test "load/2 encodes binary as Base64" do
    {:ok, encoded} = Ecto.ULID.load(@binary, :b64)
    assert encoded == @encoded_b64
  end

  test "load/2 encodes binary as Firebase-Push-Key" do
    {:ok, encoded} = Ecto.ULID.load(@binary, :push)
    assert encoded == @encoded_push
  end

  test "load/2 encodes binary of correct length" do
    {:ok, encoded} = Ecto.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>)
    assert encoded == "00000000000000000000000000"
  end

  test "load/2 returns error when data is too short" do
    assert Ecto.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) == :error
  end

  test "load/2 returns error when data is too long" do
    assert Ecto.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) == :error
  end

  defmodule SchemaWithUlidAsPrimaryKey do
    use Ecto.Schema

    @primary_key {:id, Ecto.ULID,
                  autogenerate: true, variant: :b64}
    schema "" do
    end
  end

  test "init primary key field" do
    assert SchemaWithUlidAsPrimaryKey.__schema__(:autogenerate_id) == nil
    assert SchemaWithUlidAsPrimaryKey.__schema__(:autogenerate) ==
      [{[:id], {Ecto.ULID, :autogenerate, [%{variant: :b64}]}}]
  end
end
