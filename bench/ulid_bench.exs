Benchee.run(%{
  "generate/0" => fn ->
    Ecto.ULID.generate()
    nil
  end,
  "bingenerate/0" => fn ->
    Ecto.ULID.bingenerate()
    nil
  end,
  "cast/1" => fn ->
    Ecto.ULID.cast("01C0M0Y7BG2NMB15VVVJH807F3")
  end,
  "dump/" => fn ->
    Ecto.ULID.dump("01C0M0Y7BG2NMB15VVVJH807F3")
  end,
  "load/1" => fn ->
    Ecto.ULID.load(
      <<1, 96, 40, 15, 29, 112, 21, 104, 176, 151, 123, 220, 162, 128, 29, 227>>
    )
  end
})
