(module
    (import "aoc" "getInputCount" (func $getInputCount (result i32)))
    (import "aoc" "getInputValue" (func $getInputValue (result i32)))
    (import "aoc" "giveSolution" (func $giveSolution (param i32 i32)))

    (memory 1)
    (global $inputPointer i32 (i32.const 0))

    (func $storeInputs (param $inputCount i32) (param $nextInputPointer i32)
        local.get $inputCount
        if
            (i32.store (local.get $nextInputPointer) (call $getInputValue))
            (call $storeInputs
                (i32.sub (local.get $inputCount) (i32.const 1))
                (i32.add (local.get $nextInputPointer) (i32.const 4))
            )
        end
    )

    (func $part1 (param $inputCount i32) (result i32)
        (local $last i32)
        (local $count i32)
        (local $remaining i32)
        (local $nextInputPointer i32)
        (local.tee $nextInputPointer (global.get $inputPointer))
        (local.set $last (i32.load))
        (local.set $remaining (local.get $inputCount))
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

    (func $part2 (param $inputCount i32) (result i32)
        (local $count i32)
        (local $remaining i32)
        (local $nextInputPointer i32)
        (local.set $nextInputPointer (global.get $inputPointer))
        (local.set $remaining
            (i32.sub (local.get $inputCount) (i32.const 3))
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
