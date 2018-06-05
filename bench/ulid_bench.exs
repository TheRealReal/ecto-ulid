defmodule ULIDBench do
  use Benchfella

  bench "generate/0" do
    Ecto.ULID.generate()
    nil
  end

  bench "bingenerate/0" do
    Ecto.ULID.bingenerate()
    nil
  end

  bench "cast/1" do
    Ecto.ULID.cast("01C0M0Y7BG2NMB15VVVJH807F3")
  end

  bench "dump/1" do
    Ecto.ULID.dump("01C0M0Y7BG2NMB15VVVJH807F3")
  end

  bench "load/1" do
    Ecto.ULID.load(<<1, 96, 40, 15, 29, 112, 21, 104, 176, 151, 123, 220, 162, 128, 29, 227>>)
  end
end
