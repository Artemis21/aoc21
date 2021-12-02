(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (func $isNewline (param $char i32) (result i32)
        (i32.eq (i32.const 10) (local.get $char))
    )

    (func $digitToInt (param $char i32) (result i32)
        (i32.sub (local.get $char) (i32.const 48))
    )

    (func $parseInput (param $inputPointer i32) (param $inputLength i32) (result i32 i32)
        (local $readPointer i32)
        (local $writePointer i32)
        (local $writeLength i32)
        (local $returnPointer i32)
        (local $currentByte i32)
        (local $currentValue i32)
        (local.set $writeLength (i32.const 0))
        (local.set $currentValue (i32.const 0))
        (local.set $readPointer (local.get $inputPointer))
        (local.tee $writePointer
            (i32.add (local.get $readPointer) (local.get $inputLength))
        )
        local.set $returnPointer
        (loop $loop
            (i32.load8_u (local.get $readPointer))
            local.tee $currentByte
            call $isNewline
            if
                (i32.store (local.get $writePointer) (local.get $currentValue))
                (local.set $writePointer
                    (i32.add (local.get $writePointer) (i32.const 4))
                )
                (local.set $writeLength
                    (i32.add (local.get $writeLength) (i32.const 1))
                )
                (local.set $currentValue (i32.const 0))
            else
                (local.set $currentValue
                    (i32.add
                        (i32.mul (local.get $currentValue) (i32.const 10))
                        (call $digitToInt (local.get $currentByte))
                    )
                )
            end
            (local.tee $readPointer (i32.add (local.get $readPointer) (i32.const 1)))
            local.get $returnPointer
            i32.lt_u
            if br $loop end
        )
        local.get $returnPointer
        local.get $writeLength
    )

    (func $part1 (param $dataPointer i32) (param $dataLength i32) (result i32)
        (local $last i32)
        (local $count i32)
        (local $remaining i32)
        (local $nextInputPointer i32)
        (local.tee $nextInputPointer (local.get $dataPointer))
        (local.set $last (i32.load))
        (local.set $remaining (local.get $dataLength))
        (loop $loop
            local.get $last
            (i32.add (local.get $nextInputPointer) (i32.const 4))
            local.tee $nextInputPointer
            i32.load
            local.tee $last
            i32.lt_u
            if
                (local.set $count
                    (i32.add (local.get $count) (i32.const 1))
                )
            end
            (i32.sub (local.get $remaining) (i32.const 1))
            local.tee $remaining
            if br $loop end
        )
        local.get $count
    )

    (func $part2 (param $dataPointer i32) (param $dataLength i32) (result i32)
        (local $count i32)
        (local $remaining i32)
        (local $nextInputPointer i32)
        (local.set $nextInputPointer (local.get $dataPointer))
        (local.set $remaining
            (i32.sub (local.get $dataLength) (i32.const 3))
        )
        (loop $loop
            (i32.lt_u
                (i32.load (local.get $nextInputPointer))
                (i32.load
                    (i32.add (local.get $nextInputPointer) (i32.const 12))
                )
            )
            if
                (local.set $count
                    (i32.add (local.get $count) (i32.const 1))
                )
            end
            (local.set $nextInputPointer
                (i32.add (local.get $nextInputPointer) (i32.const 4))
            )
            (i32.sub (local.get $remaining) (i32.const 1))
            local.tee $remaining
            if br $loop end
        )
        local.get $count
    )

    (func (export "main") (param $inputPointer i32) (param $inputLength i32) (result i32 i32)
        (local $dataPointer i32)
        (local $dataLength i32)
        (call $parseInput (local.get $inputPointer) (local.get $inputLength))
        local.set $dataLength
        local.set $dataPointer
        (call $part1 (local.get $dataPointer) (local.get $inputLength))
        (call $part2 (local.get $dataPointer) (local.get $inputLength))
    )
)
