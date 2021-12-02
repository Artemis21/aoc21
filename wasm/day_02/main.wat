(module
    (import "aoc" "getInputCount" (func $getInputCount (result i32)))
    (import "aoc" "getInputValue" (func $getInputValue (result i32 i32)))
    (import "aoc" "giveSolution" (func $giveSolution (param i32 i32)))

    (memory 1)
    (global $inputPointer i32 (i32.const 0))

    (func $storeInputs (param $inputCount i32) (param $nextInputPointer i32)
        (local $instruction i32)
        (local $instructionValue i32)
        local.get $inputCount
        if
            call $getInputValue
            local.set $instructionValue
            local.set $instruction
            (i32.store (local.get $nextInputPointer) (local.get $instruction))
            (i32.store
                (i32.add (local.get $nextInputPointer) (i32.const 4))
                (local.get $instructionValue)
            )
            (call $storeInputs
                (i32.sub (local.get $inputCount) (i32.const 1))
                (i32.add (local.get $nextInputPointer) (i32.const 8))
            )
        end
    )

    (func $part1 (param $inputCount i32) (result i32)
        (local $depth i32)
        (local $horizontal i32)
        (local $remaining i32)
        (local $nextInputPointer i32)
        (local $instruction i32)
        (local $value i32)
        (local.set $nextInputPointer (global.get $inputPointer))
        (local.set $remaining (local.get $inputCount))
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

    (func $part2 (param $inputCount i32) (result i32)
        (local $aim i32)
        (local $depth i32)
        (local $horizontal i32)
        (local $remaining i32)
        (local $nextInputPointer i32)
        (local $instruction i32)
        (local $value i32)
        (local.set $nextInputPointer (global.get $inputPointer))
        (local.set $remaining (local.get $inputCount))
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

    (func (export "main")
        (local $inputCount i32)
        call $getInputCount
        local.tee $inputCount
        global.get $inputPointer
        call $storeInputs
        (call $giveSolution
            (i32.const 1)
            (call $part1 (local.get $inputCount))
        )
        (call $giveSolution
            (i32.const 2)
            (call $part2 (local.get $inputCount))
        )
    )
)
