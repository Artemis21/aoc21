(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (global $asciiZero i32 (i32.const 48))

    (func $parseInput (param $pointer i32)
        (local $row i32)
        (local $column i32)
        (loop $rowLoop
            (local.set $column (i32.const 0))
            (loop $columnLoop
                (i32.store8
                    (i32.add (local.get $pointer) (i32.add
                        (i32.mul (local.get $row) (i32.const 10))
                        (local.get $column)
                    ))
                    (i32.sub
                        (i32.load8_u
                            (i32.add (local.get $pointer) (i32.add
                                (i32.mul (local.get $row) (i32.const 11))
                                (local.get $column)
                            ))
                        )
                        (global.get $asciiZero)
                    )
                )
                (local.set $column (i32.add (local.get $column) (i32.const 1)))
                (br_if $columnLoop (i32.lt_u (local.get $column) (i32.const 10)))
            )
            (local.set $row (i32.add (local.get $row) (i32.const 1)))
            (br_if $rowLoop (i32.lt_u (local.get $row) (i32.const 10)))
        )
    )

    (func $getCell (param $pointer i32) (param $idx i32) (result i32)
        (i32.load8_u (i32.add (local.get $pointer) (local.get $idx)))
    )

    (func $setCell (param $pointer i32) (param $idx i32) (param $value i32)
        (i32.store8 (i32.add (local.get $pointer) (local.get $idx)) (local.get $value))
    )

    (func $incrementCell (param $pointer i32) (param $idx i32)
        (call $setCell (local.get $pointer) (local.get $idx) (i32.add
            (call $getCell (local.get $pointer) (local.get $idx))
            (i32.const 1)
        ))
    )

    (func $deltaValid (param $new i32) (param $old i32) (result i32)
        (local $deltaX i32)
        (local.set $deltaX (i32.sub
            (i32.rem_u (local.get $new) (i32.const 10))
            (i32.rem_u (local.get $old) (i32.const 10))
        ))
        (i32.and
            (i32.and
                (i32.le_s (i32.const 0) (local.get $new))
                (i32.lt_s (local.get $new) (i32.const 100))
            )
            (i32.and
                (i32.le_s (i32.const -1) (local.get $deltaX))
                (i32.le_s (local.get $deltaX) (i32.const 1))
            )
        )
    )

    (func $updateNeighbour
            (param $pointer i32)
            (param $idx i32)
            (param $neighbour i32)
            (result i32)
        (call $deltaValid (local.get $neighbour) (local.get $idx))
        if
            (call $getCell (local.get $pointer) (local.get $neighbour))
            if
                (call $incrementCell (local.get $pointer) (local.get $neighbour))
                (call $updateCell (local.get $pointer) (local.get $neighbour))
                return
            end
        end
        i32.const 0
    )

    (func $updateNeighbours (param $pointer i32) (param $idx i32) (result i32)
        (i32.add
            (i32.add
                (i32.add
                    (call $updateNeighbour
                        (local.get $pointer) (local.get $idx)
                        (i32.add (local.get $idx) (i32.const -11))
                    )
                    (call $updateNeighbour
                        (local.get $pointer) (local.get $idx)
                        (i32.add (local.get $idx) (i32.const -10))
                    )
                )
                (i32.add
                    (call $updateNeighbour
                        (local.get $pointer) (local.get $idx)
                        (i32.add (local.get $idx) (i32.const -9))
                    )
                    (call $updateNeighbour
                        (local.get $pointer) (local.get $idx)
                        (i32.add (local.get $idx) (i32.const -1))
                    )
                )
            )
            (i32.add
                (i32.add
                    (call $updateNeighbour
                        (local.get $pointer) (local.get $idx)
                        (i32.add (local.get $idx) (i32.const 1))
                    )
                    (call $updateNeighbour
                        (local.get $pointer) (local.get $idx)
                        (i32.add (local.get $idx) (i32.const 9))
                    )
                )
                (i32.add
                    (call $updateNeighbour
                        (local.get $pointer) (local.get $idx)
                        (i32.add (local.get $idx) (i32.const 10))
                    )
                    (call $updateNeighbour
                        (local.get $pointer) (local.get $idx)
                        (i32.add (local.get $idx) (i32.const 11))
                    )
                )
            )
        )
    )

    (func $updateCell (param $pointer i32) (param $idx i32) (result i32)
        (i32.lt_u (call $getCell (local.get $pointer) (local.get $idx)) (i32.const 10))
        if i32.const 0 return end
        (call $setCell (local.get $pointer) (local.get $idx) (i32.const 0))
        (i32.add (i32.const 1) (call $updateNeighbours (local.get $pointer) (local.get $idx)))
    )

    (func $updateGrid (param $pointer i32) (result i32)
        (local $idx i32)
        (local $explosions i32)
        (loop $loop
            (call $incrementCell (local.get $pointer) (local.get $idx))
            (local.set $idx (i32.add (local.get $idx) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $idx) (i32.const 100)))
        )
        (local.set $idx (i32.const 0))
        (loop $loop
            (local.set $explosions (i32.add
                (call $updateCell (local.get $pointer) (local.get $idx))
                (local.get $explosions)
            ))
            (local.set $idx (i32.add (local.get $idx) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $idx) (i32.const 100)))
        )
        local.get $explosions
    )

    (func $part1 (param $pointer i32) (result i32)
        (local $total i32)
        (local $n i32)
        (loop $loop
            (local.set $total (i32.add (local.get $total) (call $updateGrid (local.get $pointer))))
            (local.set $n (i32.add (local.get $n) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $n) (i32.const 100)))
        )
        local.get $total
    )

    (func $part2 (param $pointer i32) (result i32)
        (local $n i32)
        (loop $loop
            (local.set $n (i32.add (local.get $n) (i32.const 1)))
            (br_if $loop (i32.ne (call $updateGrid (local.get $pointer)) (i32.const 100)))
        )
        local.get $n
    )

    (func (export "main") (param $pointer i32) (param $length i32) (result i32 i32)
        (call $parseInput (local.get $pointer))
        (memory.copy
            (i32.add (local.get $pointer) (i32.const 100))
            (local.get $pointer)
            (i32.const 100)
        )
        (call $part1 (local.get $pointer))
        (call $part2 (i32.add (local.get $pointer) (i32.const 100)))
    )
)
