(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (global $asciiA i32 (i32.const 97))

    (func $parseDigit (param $readPointer i32) (param $writePointer i32) (result i32 i32)
        (local $value i32)
        (local $byte i32)
        (loop $loop
            (local.set $byte
                (i32.sub (i32.load8_u (local.get $readPointer)) (global.get $asciiA))
            )
            (i32.and
                (i32.ge_s (local.get $byte) (i32.const 0))
                (i32.lt_s (local.get $byte) (i32.const 7))
            )
            if
                (local.set $readPointer (i32.add (local.get $readPointer) (i32.const 1)))
                (local.set $value (i32.or (local.get $value) (i32.shl
                    (i32.const 1)
                    (local.get $byte)
                )))
                br $loop
            end
        )
        (i32.store (local.get $writePointer) (local.get $value))
        local.get $readPointer
        (i32.add (local.get $writePointer) (i32.const 4))
    )

    (func $parseLine (param $readPointer i32) (param $writePointer i32) (result i32 i32)
        (local $counter i32)
        (loop $loop
            (call $parseDigit (local.get $readPointer) (local.get $writePointer))
            local.set $writePointer
            (local.set $readPointer (i32.add (i32.const 1)))
            (local.set $counter (i32.add (local.get $counter) (i32.const 1)))
            (i32.lt_u (local.get $counter) (i32.const 10))
            if br $loop end
        )
        (local.set $readPointer (i32.add (i32.const 2) (local.get $readPointer)))
        (local.set $counter (i32.const 0))
        (loop $loop
            (call $parseDigit (local.get $readPointer) (local.get $writePointer))
            local.set $writePointer
            (local.set $readPointer (i32.add (i32.const 1)))
            (local.set $counter (i32.add (local.get $counter) (i32.const 1)))
            (i32.lt_u (local.get $counter) (i32.const 4))
            if br $loop end
        )
        local.get $readPointer
        local.get $writePointer
    )

    (func $parseInput (param $readPointer i32) (param $inputLength i32) (result i32 i32)
        (local $returnPointer i32)
        (local $writePointer i32)
        (local $writeLength i32)
        (local.tee $writePointer (i32.add (local.get $readPointer) (local.get $inputLength)))
        local.set $returnPointer
        (loop $loop
            (i32.lt_u (local.get $readPointer) (local.get $returnPointer))
            if
                (call $parseLine (local.get $readPointer) (local.get $writePointer))
                local.set $writePointer
                local.set $readPointer
                (local.set $writeLength (i32.add (local.get $writeLength) (i32.const 1)))
                br $loop
            end
        )
        local.get $returnPointer
        local.get $writeLength
    )

    (func $part1 (param $dataPointer i32) (param $dataLength i32) (result i32)
        (local $total i32)
        (local $position i32)
        (local $thisCount i32)
        (local $n i32)
        (loop $outer
            (local.set $n (i32.const 0))
            (loop $inner
                (local.set $thisCount (i32.popcnt
                    (i32.load (i32.add (local.get $dataPointer) (i32.add
                        (i32.mul (local.get $position) (i32.const 56))
                        (i32.add (i32.const 40) (i32.mul (local.get $n) (i32.const 4)))
                    )))
                ))
                (i32.or
                    (i32.lt_u (local.get $thisCount) (i32.const 5))
                    (i32.eq (local.get $thisCount) (i32.const 7))
                )
                if (local.set $total (i32.add (local.get $total) (i32.const 1))) end
                (local.set $n (i32.add (local.get $n) (i32.const 1)))
                (i32.lt_u (local.get $n) (i32.const 4))
                if br $inner end
            )
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (i32.lt_u (local.get $position) (local.get $dataLength))
            if br $outer end
        )
        local.get $total
    )

    (func $part2 (param $scoresPointer i32) (param $scoresLength i32) (result i32)
        (i32.const 0)
    )

    (func (export "main") (param $inputPointer i32) (param $inputLength i32) (result i32 i32)
        (local $dataPointer i32)
        (local $dataLength i32)
        (call $parseInput (local.get $inputPointer) (local.get $inputLength))
        local.set $dataLength
        local.set $dataPointer
        (call $part1 (local.get $dataPointer) (local.get $dataLength))
        (call $part2 (local.get $dataPointer) (local.get $dataLength))
    )
)
