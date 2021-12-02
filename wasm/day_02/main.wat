(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (func $isNewline (param $char i32) (result i32)
        (i32.eq (i32.const 10) (local.get $char))
    )

    (func $isDigit (param $char i32) (result i32)
        (i32.and
            (i32.ge_u (local.get $char) (i32.const 48))
            (i32.le_u (local.get $char) (i32.const 57))
        )
    )

    (func $digitToInt (param $char i32) (result i32)
        (i32.sub (local.get $char) (i32.const 48))
    )

    (func $parseInstructionByte (param $char i32) (result i32)
        (i32.eq (local.get $char) (i32.const 102))
        if
            (return (i32.const 1))
        else
            (i32.eq (local.get $char) (i32.const 117))
            if
                (return (i32.const 2))
            else
                (return (i32.const 3))
            end
        end
        i32.const 0
    )

    (func $parseInput (param $inputPointer i32) (param $inputLength i32) (result i32 i32)
        (local $readPointer i32)
        (local $writePointer i32)
        (local $writeLength i32)
        (local $returnPointer i32)
        (local $currentByte i32)
        (local $currentValue i32)
        (local $currentInstruction i32)
        (local $instructionParsed i32)
        (local.set $writeLength (i32.const 0))
        (local.set $instructionParsed (i32.const 0))
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
                (i32.store (local.get $writePointer) (local.get $currentInstruction))
                (i32.store
                    (i32.add (local.get $writePointer) (i32.const 4)) (local.get $currentValue)
                )
                (local.set $writePointer
                    (i32.add (local.get $writePointer) (i32.const 8))
                )
                (local.set $writeLength
                    (i32.add (local.get $writeLength) (i32.const 1))
                )
                (local.set $instructionParsed (i32.const 0))
            else
                local.get $instructionParsed
                if
                    (call $isDigit (local.get $currentByte))
                    if
                        (local.set $currentValue (call $digitToInt (local.get $currentByte)))
                    end
                else
                    (local.set $currentInstruction
                        (call $parseInstructionByte (local.get $currentByte))
                    )
                    (local.set $instructionParsed (i32.const 1))
                end
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
        (local $depth i32)
        (local $horizontal i32)
        (local $remaining i32)
        (local $nextInputPointer i32)
        (local $instruction i32)
        (local $value i32)
        (local.set $nextInputPointer (local.get $dataPointer))
        (local.set $remaining (local.get $dataLength))
        (local.set $depth (i32.const 0))
        (local.set $horizontal (i32.const 0))
        (loop $loop
            (local.set $value
                (i32.load (i32.add (local.get $nextInputPointer) (i32.const 4)))
            )
            (local.tee $instruction (i32.load (local.get $nextInputPointer)))
            (i32.eq (i32.const 1))
            if
                (local.set $horizontal
                    (i32.add (local.get $horizontal) (local.get $value))
                )
            else
                (i32.eq (i32.const 2) (local.get $instruction))
                if
                    (local.set $value (i32.mul (local.get $value) (i32.const -1)))
                end
                (local.set $depth (i32.add (local.get $depth) (local.get $value)))
            end
            (local.set $nextInputPointer
                (i32.add (local.get $nextInputPointer) (i32.const 8))
            )
            (i32.sub (local.get $remaining) (i32.const 1))
            local.tee $remaining
            if br $loop end
        )
        (i32.mul (local.get $depth) (local.get $horizontal))
    )

    (func $part2 (param $dataPointer i32) (param $dataLength i32) (result i32)
        (local $aim i32)
        (local $depth i32)
        (local $horizontal i32)
        (local $remaining i32)
        (local $nextInputPointer i32)
        (local $instruction i32)
        (local $value i32)
        (local.set $nextInputPointer (local.get $dataPointer))
        (local.set $remaining (local.get $dataLength))
        (local.set $depth (i32.const 0))
        (local.set $horizontal (i32.const 0))
        (loop $loop
            (local.set $value
                (i32.load (i32.add (local.get $nextInputPointer) (i32.const 4)))
            )
            (local.tee $instruction (i32.load (local.get $nextInputPointer)))
            (i32.eq (i32.const 1))
            if
                (local.set $horizontal
                    (i32.add (local.get $horizontal) (local.get $value))
                )
                (local.set $depth
                    (i32.add
                        (local.get $depth)
                        (i32.mul (local.get $aim) (local.get $value))
                    )
                )
            else
                (i32.eq (i32.const 2) (local.get $instruction))
                if
                    (local.set $value (i32.mul (local.get $value) (i32.const -1)))
                end
                (local.set $aim (i32.add (local.get $aim) (local.get $value)))
            end
            (local.set $nextInputPointer
                (i32.add (local.get $nextInputPointer) (i32.const 8))
            )
            (i32.sub (local.get $remaining) (i32.const 1))
            local.tee $remaining
            if br $loop end
        )
        (i32.mul (local.get $depth) (local.get $horizontal))
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
