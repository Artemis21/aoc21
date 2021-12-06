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

    (func $addCacheValue
            (param $cachePointer i32)
            (param $fish i32)
            (param $days i32)
            (param $value i64)
        (local $length i32)
        (local $storeAt i32)
        (local.set $length (i32.load (local.get $cachePointer)))
        (local.set $storeAt (i32.add
            (i32.add (local.get $cachePointer) (i32.const 1))
            (i32.mul (local.get $length) (i32.const 16))
        ))
        (i32.store (local.get $storeAt) (local.get $fish))
        (i32.store (i32.add (local.get $storeAt) (i32.const 4)) (local.get $days))
        (i64.store (i32.add (local.get $storeAt) (i32.const 8)) (local.get $value))
        (i32.store (local.get $cachePointer) (i32.add (local.get $length) (i32.const 1)))
    )

    (func $getCacheValue
            (param $cachePointer i32)
            (param $fish i32)
            (param $days i32)
            (result i64)
        (local $length i32)
        (local.set $length (i32.load (local.get $cachePointer)))
        (local.set $cachePointer (i32.add (local.get $cachePointer) (i32.const 1)))
        (loop $loop
            (i32.gt_u (local.get $length) (i32.const 0))
            if
                (i32.and
                    (i32.eq (i32.load (local.get $cachePointer)) (local.get $fish))
                    (i32.eq
                        (i32.load (i32.add (local.get $cachePointer) (i32.const 4)))
                        (local.get $days)
                    )
                )
                if
                    (i64.load (i32.add (local.get $cachePointer) (i32.const 8)))
                    return
                end
                (local.set $cachePointer (i32.add (local.get $cachePointer) (i32.const 16)))
                (local.set $length (i32.sub (local.get $length) (i32.const 1)))
                br $loop
            end
        )
        i64.const 0
    )

    (func $getFishAfterDays
            (param $cachePointer i32)
            (param $fish i32)
            (param $days i32)
            (result i64)
        (local $value i64)
        (local.set $days (i32.sub (local.get $days) (i32.add (local.get $fish) (i32.const 1))))
        (i32.lt_s (local.get $days) (i32.const 0))
        if i64.const 1 return end
        (call $getCacheValue (local.get $cachePointer) (local.get $fish) (local.get $days))
        local.tee $value
        (i64.ne (i64.const 0))
        if local.get $value return end
        (local.set $value (i64.add
            (call $getFishAfterDays (local.get $cachePointer) (i32.const 6) (local.get $days))
            (call $getFishAfterDays (local.get $cachePointer) (i32.const 8) (local.get $days))
        ))
        (call $addCacheValue
            (local.get $cachePointer) (local.get $fish) (local.get $days) (local.get $value)
        )
        local.get $value
    )

    (func $allFishAfterDays
            (param $dataPointer i32)
            (param $dataLength i32)
            (param $days i32)
            (result i64)
        (local $total i64)
        (local $position i32)
        (local $cachePointer i32)
        (local.set $cachePointer (i32.add
            (local.get $dataPointer)
            (i32.mul (local.get $dataLength) (i32.const 4))
        ))
        (loop $loop
            (local.set $total (i64.add (local.get $total) (call $getFishAfterDays
                (local.get $cachePointer)
                (i32.load (i32.add
                    (local.get $dataPointer)
                    (i32.mul (local.get $position) (i32.const 4))
                ))
                (local.get $days)
            )))
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (i32.lt_u (local.get $position) (local.get $dataLength))
            if br $loop end
        )
        local.get $total
    )

    (func $part1 (param $dataPointer i32) (param $dataLength i32) (result i64)
        (call $allFishAfterDays (local.get $dataPointer) (local.get $dataLength) (i32.const 80))
    )

    (func $part2 (param $dataPointer i32) (param $dataLength i32) (result i64)
        (call $allFishAfterDays (local.get $dataPointer) (local.get $dataLength) (i32.const 256))
    )

    (func (export "main") (param $inputPointer i32) (param $inputLength i32) (result i64 i64)
        (local $dataPointer i32)
        (local $dataLength i32)
        (call $parseInput (local.get $inputPointer) (local.get $inputLength))
        local.set $dataLength
        local.set $dataPointer
        (call $part1 (local.get $dataPointer) (local.get $dataLength))
        (call $part2 (local.get $dataPointer) (local.get $dataLength))
    )
)
