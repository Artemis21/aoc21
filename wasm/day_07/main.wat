(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (global $asciiZero i32 (i32.const 48))
    (global $asciiNewline i32 (i32.const 10))

    (func $parseInt (param $pointer i32) (result i32 i32)
        (local $value i32)
        (local $byte i32)
        (loop $loop
            (local.set $byte
                (i32.sub (i32.load8_u (local.get $pointer)) (global.get $asciiZero))
            )
            (i32.and
                (i32.ge_s (local.get $byte) (i32.const 0))
                (i32.lt_s (local.get $byte) (i32.const 10))
            )
            if
                (local.set $pointer (i32.add (local.get $pointer) (i32.const 1)))
                (local.set $value (i32.add
                    (i32.mul (local.get $value) (i32.const 10))
                    (local.get $byte)
                ))
                br $loop
            end
        )
        local.get $pointer
        local.get $value
    )

    (func $parseInput (param $inputPointer i32) (param $inputLength i32) (result i32 i32)
        (local $current i32)
        (local $writePointer i32)
        (local $writeLength i32)
        (local.set $writePointer (i32.add (local.get $inputPointer) (local.get $inputLength)))
        (loop $loop
            (call $parseInt (local.get $inputPointer))
            local.set $current
            local.set $inputPointer
            (i32.store
                (i32.add
                    (local.get $writePointer)
                    (i32.mul (local.get $writeLength) (i32.const 4))
                )
                (local.get $current)
            )
            (i32.ne (i32.load8_u (local.get $inputPointer)) (global.get $asciiNewline))
            (local.set $inputPointer (i32.add (local.get $inputPointer) (i32.const 1)))
            (local.set $writeLength (i32.add (local.get $writeLength) (i32.const 1)))
            if br $loop end
        )
        local.get $writePointer
        local.get $writeLength
    )

    (func $getMedian (param $readPointer i32) (param $readLength i32) (result i32)
        (local $pivot i32)
        (local $position i32)
        (local $current i32)
        (local $lowerPointer i32)
        (local $lowerLength i32)
        (local $upperPointer i32)
        (local $upperLength i32)
        (local $pivotEqualCount i32)
        (local $k i32)
        (local $pivotIndex i32)
        (local.set $k (i32.div_u (local.get $readLength) (i32.const 2)))
        (local.set $lowerPointer (i32.add
            (local.get $readPointer)
            (i32.mul (local.get $readLength) (i32.const 4))
        ))
        (local.set $upperPointer (i32.add
            (local.get $lowerPointer)
            (i32.mul (local.get $readLength) (i32.const 4))
        ))
        (loop $outer
            (i32.eq (local.get $readLength) (i32.const 1))
            if (i32.load (local.get $readPointer)) return end
            (local.set $lowerLength (i32.const 0))
            (local.set $upperLength (i32.const 0))
            (local.set $position (i32.const 0))
            (local.set $pivotEqualCount (i32.const 0))
            (local.set $pivot (i32.load (i32.add (local.get $readPointer) (i32.mul
                (i32.rem_u (local.get $pivotIndex) (local.get $readLength))
                (i32.const 4)
            ))))
            (loop $inner
                (local.set $current (i32.load (i32.add
                    (local.get $readPointer)
                    (i32.mul (local.get $position) (i32.const 4))
                )))
                (i32.le_s (local.get $current) (local.get $pivot))
                if
                    (i32.store
                        (i32.add
                            (local.get $lowerPointer)
                            (i32.mul (local.get $lowerLength) (i32.const 4))
                        )
                        (local.get $current)
                    )
                    (local.set $lowerLength (i32.add (local.get $lowerLength) (i32.const 1)))
                    (i32.eq (local.get $current) (local.get $pivot))
                    if
                        (local.set $pivotEqualCount
                            (i32.add (local.get $pivotEqualCount) (i32.const 1))
                        )
                    end
                else
                    (i32.store
                        (i32.add
                            (local.get $upperPointer)
                            (i32.mul (local.get $upperLength) (i32.const 4))
                        )
                        (local.get $current)
                    )
                    (local.set $upperLength (i32.add (local.get $upperLength) (i32.const 1)))
                end
                (local.set $position (i32.add (local.get $position) (i32.const 1)))
                (br_if $inner (i32.lt_u (local.get $position) (local.get $readLength)))
            )
            (local.set $pivotIndex (i32.add (local.get $pivotIndex) (i32.const 1)))
            (i32.gt_u (local.get $lowerLength) (local.get $k))
            if
                (i32.eq (local.get $pivotEqualCount) (local.get $lowerLength))
                if (local.get $pivot) return end
                (local.set $readPointer (local.get $lowerPointer))
                (local.set $readLength (local.get $lowerLength))
            else
                (local.set $readPointer (local.get $upperPointer))
                (local.set $readLength (local.get $upperLength))
                (local.set $k (i32.sub (local.get $k) (local.get $lowerLength)))
            end
            br $outer
        )
        unreachable
    )

    (func $getMean (param $dataPointer i32) (param $dataLength i32) (result i32)
        (local $sum i32)
        (local $position i32)
        (loop $loop
            (local.set $sum (i32.add (local.get $sum) (i32.load (i32.add
                (local.get $dataPointer)
                (i32.mul (local.get $position) (i32.const 4))
            ))))
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $dataLength)))
        )
        (i32.div_u (local.get $sum) (local.get $dataLength))
    )

    (func $part1 (param $dataPointer i32) (param $dataLength i32) (result i32)
        (local $target i32)
        (local $total i32)
        (local $position i32)
        (local $current i32)
        (local.set $target (call $getMedian (local.get $dataPointer) (local.get $dataLength)))
        (loop $loop
            (local.set $current (i32.load (i32.add
                (local.get $dataPointer)
                (i32.mul (local.get $position) (i32.const 4))
            )))
            (local.set $current (i32.sub (local.get $current) (local.get $target)))
            (i32.lt_s (local.get $current) (i32.const 0))
            if (local.set $total (i32.sub (local.get $total) (local.get $current)))
            else (local.set $total (i32.add (local.get $total) (local.get $current)))
            end
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $dataLength)))
        )
        local.get $total
    )

    (func $part2 (param $dataPointer i32) (param $dataLength i32) (result i32)
        (local $target i32)
        (local $total i32)
        (local $position i32)
        (local $current i32)
        (local.set $target (call $getMean (local.get $dataPointer) (local.get $dataLength)))
        (loop $loop
            (local.set $current (i32.load (i32.add
                (local.get $dataPointer)
                (i32.mul (local.get $position) (i32.const 4))
            )))
            (local.set $current (i32.sub (local.get $current) (local.get $target)))
            (i32.lt_s (local.get $current) (i32.const 0))
            if (local.set $current (i32.sub (i32.const 0) (local.get $current))) end
            (local.set $total (i32.add (local.get $total) (i32.div_u
                (i32.add
                    (i32.mul (local.get $current) (local.get $current))
                    (local.get $current)
                )
                (i32.const 2)
            )))
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $dataLength)))
        )
        local.get $total
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
