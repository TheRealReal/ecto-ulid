defmodule ULIDBench do
  use Benchfella

  bench "generate/2" do
    Ecto.ULID.generate()
    nil
  end

  bench "generate/2 (:b64)" do
    Ecto.ULID.generate(:b64)
    nil
  end

  bench "generate/2 (:push)" do
    Ecto.ULID.generate(:push)
    nil
  end

  bench "bingenerate/1" do
    Ecto.ULID.bingenerate()
    nil
  end

  bench "cast/2" do
    Ecto.ULID.cast("01C0M0Y7BG2NMB15VVVJH807F3")
  end

  bench "cast/2 (:b64)" do
    Ecto.ULID.cast("-0N1VE6M-KPA1MTxmXV0rY")
  end

  bench "cast/2 (:push)" do
    Ecto.ULID.cast("-L-c2lpkPA1MTxmXV0rY")
  end

  bench "dump/1" do
    Ecto.ULID.dump("01C0M0Y7BG2NMB15VVVJH807F3")
  end

  bench "dump/1 (:b64)" do
    Ecto.ULID.dump("-0N1VE6M-KPA1MTxmXV0rY")
  end

  bench "dump/1 (:push)" do
    Ecto.ULID.dump("-L-c2lpkPA1MTxmXV0rY")
  end

  bench "load/2" do
    Ecto.ULID.load(<<1, 96, 40, 15, 29, 112, 21, 104, 176, 151, 123, 220, 162, 128, 29, 227>>)
  end

  bench "load/2 (:b64)" do
    Ecto.ULID.load(<<1, 96, 40, 15, 29, 112, 21, 104, 176, 151, 123, 220, 162, 128, 29, 227>>, :b64)
  end

  bench "load/2 (:push)" do
    Ecto.ULID.load(<<1, 96, 40, 15, 29, 112, 21, 104, 176, 151, 123, 220, 162, 128, 29, 227>>, :push)
  end
end
