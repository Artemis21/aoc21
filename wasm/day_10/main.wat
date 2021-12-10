(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (global $asciiNewline i32 (i32.const 10))
    (global $asciiOpenRound i32 (i32.const 40))
    (global $asciiCloseRound i32 (i32.const 41))
    (global $asciiOpenSquare i32 (i32.const 91))
    (global $asciiCloseSquare i32 (i32.const 93))
    (global $asciiOpenCurly i32 (i32.const 123))
    (global $asciiCloseCurly i32 (i32.const 125))
    (global $asciiOpenAngle i32 (i32.const 60))
    (global $asciiCloseAngle i32 (i32.const 62))

    (func $pushStack (param $stackPointer i32) (param $value i32) (result i32)
        (i32.store8 (local.get $stackPointer) (local.get $value))
        (i32.add (local.get $stackPointer) (i32.const 1))
    )

    (func $popStack (param $stackPointer i32) (result i32 i32)
        (local.set $stackPointer (i32.sub (local.get $stackPointer) (i32.const 1)))
        (i32.load8_u (local.get $stackPointer))
        local.get $stackPointer
    )

    (func $skipToNewline (param $pointer i32) (result i32)
        (loop $loop
            (i32.ne (i32.load8_u (local.get $pointer)) (global.get $asciiNewline))
            (local.set $pointer (i32.add (local.get $pointer) (i32.const 1)))
            if br $loop end
        )
        local.get $pointer
    )

    (func $parseToStack (param $readPointer i32) (param $stackPointer i32) (result i32 i32 i32)
        (local $byte i32)
        (loop $loop
            (local.set $byte (i32.load8_u (local.get $readPointer)))
            (local.set $readPointer (i32.add (local.get $readPointer) (i32.const 1)))
            (i32.ne (local.get $byte) (global.get $asciiNewline))
            if
                (i32.eq (local.get $byte) (global.get $asciiOpenRound))
                if (local.set $stackPointer (call $pushStack
                    (local.get $stackPointer) (global.get $asciiCloseRound)
                )) else
                (i32.eq (local.get $byte) (global.get $asciiOpenSquare))
                if (local.set $stackPointer (call $pushStack
                    (local.get $stackPointer) (global.get $asciiCloseSquare)
                )) else
                (i32.eq (local.get $byte) (global.get $asciiOpenCurly))
                if (local.set $stackPointer (call $pushStack
                    (local.get $stackPointer) (global.get $asciiCloseCurly)
                )) else
                (i32.eq (local.get $byte) (global.get $asciiOpenAngle))
                if (local.set $stackPointer (call $pushStack
                    (local.get $stackPointer) (global.get $asciiCloseAngle)
                )) else
                    (call $popStack (local.get $stackPointer))
                    local.set $stackPointer
                    (i32.ne (local.get $byte))
                    if
                        (call $skipToNewline (local.get $readPointer))
                        local.get $stackPointer
                        local.get $byte
                        return
                    end
                end end end end
                br $loop
            end
        )
        local.get $readPointer
        local.get $stackPointer
        i32.const 0
    )

    (func $part1 (param $inputPointer i32) (param $inputLength i32) (result i32)
        (local $stackPointer i32)
        (local $invalid i32)
        (local $value i32)
        (local $total i32)
        (local.set $stackPointer (i32.add (local.get $inputPointer) (local.get $inputLength)))
        (loop $loop
            (call $parseToStack (local.get $inputPointer) (local.get $stackPointer))
            local.tee $invalid
            if
                (local.set $value (i32.const 0))
                (i32.eq (local.get $invalid) (global.get $asciiCloseRound))
                if (local.set $value (i32.const 3)) else
                (i32.eq (local.get $invalid) (global.get $asciiCloseSquare))
                if (local.set $value (i32.const 57)) else
                (i32.eq (local.get $invalid) (global.get $asciiCloseCurly))
                if (local.set $value (i32.const 1197)) else
                (i32.eq (local.get $invalid) (global.get $asciiCloseAngle))
                if (local.set $value (i32.const 25137))
                end end end end
                (local.set $total (i32.add (local.get $total) (local.get $value)))
            end
            drop
            local.set $inputPointer
            (i32.lt_u (local.get $inputPointer) (local.get $stackPointer))
            if br $loop end
        )
        local.get $total
    )

    (func $scoreStack (param $stackStart i32) (param $stackEnd i32) (result i64)
        (local $score i64)
        (local $current i32)
        (local $value i64)
        (loop $loop
            (local.set $score (i64.mul (local.get $score) (i64.const 5)))
            (call $popStack (local.get $stackEnd))
            local.set $stackEnd
            local.set $current
            (i32.eq (local.get $current) (global.get $asciiCloseRound))
            if (local.set $value (i64.const 1)) else
            (i32.eq (local.get $current) (global.get $asciiCloseSquare))
            if (local.set $value (i64.const 2)) else
            (i32.eq (local.get $current) (global.get $asciiCloseCurly))
            if (local.set $value (i64.const 3)) else
            (i32.eq (local.get $current) (global.get $asciiCloseAngle))
            if (local.set $value (i64.const 4))
            end end end end
            (local.set $score (i64.add (local.get $score) (local.get $value)))
            (i32.gt_u (local.get $stackEnd) (local.get $stackStart))
            if br $loop end
        )
        local.get $score
    )

    (func $getMedian (param $readPointer i32) (param $readLength i32) (result i64)
        (local $pivot i64)
        (local $position i32)
        (local $current i64)
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
            (i32.mul (local.get $readLength) (i32.const 8))
        ))
        (local.set $upperPointer (i32.add
            (local.get $lowerPointer)
            (i32.mul (local.get $readLength) (i32.const 8))
        ))
        (loop $outer
            (i32.eq (local.get $readLength) (i32.const 1))
            if (i64.load (local.get $readPointer)) return end
            (local.set $lowerLength (i32.const 0))
            (local.set $upperLength (i32.const 0))
            (local.set $position (i32.const 0))
            (local.set $pivotEqualCount (i32.const 0))
            (local.set $pivot (i64.load (i32.add (local.get $readPointer) (i32.mul
                (i32.rem_u (local.get $pivotIndex) (local.get $readLength))
                (i32.const 8)
            ))))
            (loop $inner
                (local.set $current (i64.load (i32.add
                    (local.get $readPointer)
                    (i32.mul (local.get $position) (i32.const 8))
                )))
                (i64.le_s (local.get $current) (local.get $pivot))
                if
                    (i64.store
                        (i32.add
                            (local.get $lowerPointer)
                            (i32.mul (local.get $lowerLength) (i32.const 8))
                        )
                        (local.get $current)
                    )
                    (local.set $lowerLength (i32.add (local.get $lowerLength) (i32.const 1)))
                    (i64.eq (local.get $current) (local.get $pivot))
                    if
                        (local.set $pivotEqualCount
                            (i32.add (local.get $pivotEqualCount) (i32.const 1))
                        )
                    end
                else
                    (i64.store
                        (i32.add
                            (local.get $upperPointer)
                            (i32.mul (local.get $upperLength) (i32.const 8))
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

    (func $part2 (param $inputPointer i32) (param $inputLength i32) (result i64)
        (local $scoresPointer i32)
        (local $scoresLength i32)
        (local $stackPointer i32)
        (local $stackEnd i32)
        (local $invalid i32)
        (local.set $scoresPointer (i32.add (local.get $inputPointer) (local.get $inputLength)))
        (loop $loop
            (local.set $stackPointer (i32.add
                (local.get $scoresPointer) (i32.mul (local.get $inputLength) (i32.const 8))
            ))
            (call $parseToStack (local.get $inputPointer) (local.get $stackPointer))
            local.set $invalid
            local.set $stackEnd
            local.set $inputPointer
            (i32.eqz (local.get $invalid))
            if
                (i64.store
                    (i32.add
                        (local.get $scoresPointer)
                        (i32.mul (local.get $scoresLength) (i32.const 8))
                    )
                    (call $scoreStack (local.get $stackPointer) (local.get $stackEnd))
                )
                (local.set $scoresLength (i32.add (local.get $scoresLength) (i32.const 1)))
            end
            (i32.lt_u (local.get $inputPointer) (local.get $scoresPointer))
            if br $loop end
        )
        (call $getMedian (local.get $scoresPointer) (local.get $scoresLength))
    )

    (func (export "main") (param $pointer i32) (param $length i32) (result i32 i64)
        (call $part1 (local.get $pointer) (local.get $length))
        (call $part2 (local.get $pointer) (local.get $length))
    )
)
