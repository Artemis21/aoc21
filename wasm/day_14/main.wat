(module
    (func $parseRules
            (param $readPointer i32)
            (param $writePointer i32)
            (result i32)
        (local $length i32)
        (local $position i32)
        (local.set $length (i32.div_u
            (i32.sub (local.get $writePointer) (local.get $readPointer))
            (i32.const 8)
        ))
        (local.set $position (i32.const 0))
        (loop $loop
            (local.set $readPointer (i32.add
                (local.get $readPointer) (i32.mul (local.get $position) (i32.const 8))
            ))
            (local.set $writePointer (i32.add
                (local.get $writePointer) (i32.mul (local.get $position) (i32.const 11))
            ))
            (i32.store8 (local.get $writePointer) (i32.load8_u (local.get $readPointer)))
            (i32.store8
                (i32.add (local.get $writePointer) (i32.const 1))
                (i32.load8_u (i32.add (local.get $readPointer) (i32.const 1)))
            )
            (i32.store8
                (i32.add (local.get $writePointer) (i32.const 6))
                (i32.load8_u (i32.add (local.get $readPointer) (i32.const 2)))
            )
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $length)))
        )
        local.get $length
    )

    (func $parseInput (param $pointer i32) (param $length i32) (result i32 i32 i32 i32 i32)
        (local $initLength i32)
        (local $rulesPointer i32)
        (local $rulesLength i32)
        local.get $pointer
        (call $parseInit (local.get $pointer))
        local.tee $initLength
        (local.tee $rulesPointer (i32.add (local.get $pointer) (local.get $length)))
        (call $parseRules
            (i32.add (local.get $pointer) (i32.add (local.get $initLength) (i32.const 3)))
            (local.get $rulesPointer)
        )
        local.tee $rulesLength
        (i32.add (local.get $rulesPointer) (i32.mul (local.get $rulesLength) (i32.const 11)))
    )

    (func $initCounters
            (param $inputPointer i32)
            (param $inputLength i32)
            (result i32 i32 i32 i32)
        (local $initPointer i32)
        (local $initLength i32)
        (local $mainSpacePointer i32)
        (local $currentSpacePointer i32)
        (local $blankSpacePointer i32)
        (local $spaceSize i32)
        (local $rulesLength i32)
        (local $position i32)
        (call $parseInput (local.get $inputPointer) (local.get $inputLength))
        local.set $currentSpacePointer
        local.set $rulesLength
        local.set $mainSpacePointer
        local.set $initLength
        local.set $initPointer
        (local.set $spaceSize (i32.mul (local.get $rulesLength) (i32.const 11)))
        (local.set $blankSpacePointer (i32.add (local.get $currentSpacePointer) (local.get $spaceSize)))
        (memory.copy (local.get $currentSpacePointer) (local.get $mainSpacePointer) (local.get $spaceSize))
        (memory.copy (local.get $blankSpacePointer) (local.get $mainSpacePointer) (local.get $spaceSize))
        (loop $loop
            (call $addCounter
                (local.get $mainSpacePointer)
                (i32.add (local.get $initPointer) (local.get $position))
                (i32.add (local.get $initPointer) (i32.add (local.get $position) (i32.const 1)))
                (i32.const 1)
            )
            (local.set $position (i32.add (local.get $position) (i64.const 1)))
            (br_if $loop (i32.lt_u (local.get $position)
                (i32.sub (local.get $initLength) (i32.const 1))
            ))
        )
        local.get $mainSpacePointer
        local.get $currentSpacePointer
        local.get $blankSpacePointer
        local.get $rulesLength
        (i32.add (local.get $currentSpacePointer) (local.get $spaceSize))
    )

    (func $addCounter
            (param $rulesPointer i32)
            (param $firstPointer i32)
            (param $secondPointer i32)
            (param $amount i64)
        (local $countPointer i32)
        (local.set $countPointer (i32.add (i32.const 3) (call $locateRule
            (local.get $rulesPointer) (local.get $firstPointer) (local.get $secondPointer)
        )))
        (i64.store (local.get $countPointer) (i64.add
            (i64.load (local.get $countPointer))
            (local.get $amount)
        ))
    )

    (func $locateRule
            (param $rulesPointer i32)
            (param $firstPointer i32)
            (param $secondPointer i32)
        (local $first i32)
        (local $second i32)
        (local.set $first (i32.load8_u (local.get $firstPointer)))
        (local.set $second (i32.load8_u (local.get $secondPointer)))
        (loop $loop
            (i32.eq (local.get $first) (i32.load8_u (local.get $rulesPointer i32)))
            if
                (i32.eq (local.set $second)
                    (i32.load8_u (i32.add (local.get $rulesPointer) (i32.const 1)))
                )
                if local.get $rulesPointer return end
            end
            (local.set $rulesPointer (i32.add (local.get $rulesPointer) (i32.const 11)))
            br $loop
        )
    )

    (func $runIters
            (param $mainSpacePointer i32)
            (param $currentSpacePointer i32)
            (param $blankSpacePointer i32)
            (param $length i32)
            (param $iters i32)
        ;; Each iter:
        ;;  - Copy blankSpace to currentSpace
        ;;  - Process mainSpace into currentSpace
        ;;  - Copy currentSpace to mainSpace
    )

    (func $getCountRange
            (param $mainSpacePointer i32)
            (param $length i32)
            (param $writePointer i32)
            (result i64)
        ;; Combine pair counts from mainSpace in to letter count in writePointer.
        ;; Return the difference between the highest letter count and lowest letter count.
    )

    (func (export "main") (param $inputPointer i32) (param $inputLength i32) (result i64 i64)
        (local $mainSpacePointer i32)
        (local $currentSpacePointer i32)
        (local $blankSpacePointer i32)
        (local $rulesLength i32)
        (local $writePointer i32)
        (call $initCounters (local.get $inputPointer) (local.get $inputLength))
        local.set $writePointer
        local.set $rulesLength
        local.set $blankSpacePointer
        local.set $currentSpacePointer
        local.set $mainSpacePointer
        (call $runIters
            (local.get $mainSpacePointer)
            (local.get $currentSpacePointer)
            (local.get $blankSpacePointer)
            (local.get $rulesLength)
            (i32.const 10)
        )
        (call $getCountRange
            (local.get $mainSpacePointer) (local.get $rulesLength) (local.get $writePointer)
        )
        (call $runIters
            (local.get $mainSpacePointer)
            (local.get $currentSpacePointer)
            (local.get $blankSpacePointer)
            (local.get $rulesLength)
            (i32.const 30)
        )
        (call $getCountRange
            (local.get $mainSpacePointer) (local.get $rulesLength) (local.get $writePointer)
        )
    )
)
