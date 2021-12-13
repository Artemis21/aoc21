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
            (local.set $pointer (i32.add (local.get $pointer) (i32.const 1)))
            (i32.and
                (i32.ge_s (local.get $byte) (i32.const 0))
                (i32.lt_s (local.get $byte) (i32.const 10))
            )
            if
                (local.set $value (i32.add
                    (i32.mul (local.get $value) (i32.const 10))
                    (local.get $byte)
                ))
                br $loop
            end
        )
        local.get $value
        local.get $pointer
    )

    (func $parseCoords (param $readPointer i32) (param $writePointer i32) (result i32 i32)
        (local $length i32)
        (local $x i32)
        (local $y i32)
        (loop $loop
            (i32.ne (i32.load8_u (local.get $readPointer)) (global.get $asciiNewline))
            if
                (call $parseInt (local.get $readPointer))
                local.set $readPointer
                local.set $x
                (call $parseInt (local.get $readPointer))
                local.set $readPointer
                local.set $y
                (call $writeCoord
                    (local.get $writePointer) (local.get $length) (local.get $x) (local.get $y)
                )
                local.set $length
                br $loop
            end
        )
        local.get $readPointer
        local.get $length
    )

    (func $parseAxis (param $pointer i32) (result i32 i32)
        (i32.eq (i32.load8_u (local.get $pointer)) (i32.const 120))  ;; ASCI "x"
        (i32.add (local.get $pointer) (i32.const 2))
    )

    (func $parseInstructions
            (param $readPointer i32)
            (param $endPointer i32)
            (param $writePointer i32)
            (result i32)
        (local $length i32)
        (local $axis i32)
        (local $n i32)
        (loop $loop
            (local.set $readPointer (i32.add (local.get $readPointer) (i32.const 11)))
            (call $parseAxis (local.get $readPointer))
            local.set $readPointer
            local.set $axis
            (i32.store8 (local.get $writePointer) (local.get $axis))
            (call $parseInt (local.get $readPointer))
            local.set $readPointer
            local.set $n
            (i32.store (i32.add (local.get $writePointer) (i32.const 1)) (local.get $n))
            (local.set $writePointer (i32.add (local.get $writePointer) (i32.const 5)))
            (local.set $length (i32.add (local.get $length) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $readPointer) (local.get $endPointer)))
        )
        local.get $length
    )

    (func $parseInput
            (param $inputPointer i32)
            (param $inputLength i32)
            (result i32 i32 i32 i32 i32)
        (local $coordsLength i32)
        (local $coordsPointer i32)
        (local $instrsLength i32)
        (local $instrsPointer i32)
        (local.set $coordsPointer (i32.add (local.get $inputPointer) (local.get $inputLength)))
        (call $parseCoords (local.get $inputPointer) (local.get $coordsPointer))
        local.set $coordsLength
        i32.const 1
        i32.add
        local.set $inputPointer
        (local.set $instrsPointer (i32.add
            (local.get $coordsPointer)
            (i32.mul (local.get $coordsLength) (i32.const 8))
        ))
        (call $parseInstructions
            (local.get $inputPointer) (local.get $coordsPointer) (local.get $instrsPointer)
        )
        local.set $instrsLength
        local.get $coordsPointer
        local.get $coordsLength
        local.get $instrsPointer
        local.get $instrsLength
        (i32.add (local.get $instrsPointer) (i32.mul (local.get $instrsLength) (i32.const 5)))
    )

    (func $ocrBitmapLookup (param $bitmap i32) (result i32)
        (i32.eq (local.get $bitmap) (i32.const 6922137)) if i32.const 65 return end
        (i32.eq (local.get $bitmap) (i32.const 15329694)) if i32.const 66 return end
        (i32.eq (local.get $bitmap) (i32.const 6916246)) if i32.const 67 return end
        (i32.eq (local.get $bitmap) (i32.const 16312463)) if i32.const 69 return end
        (i32.eq (local.get $bitmap) (i32.const 16312456)) if i32.const 70 return end
        (i32.eq (local.get $bitmap) (i32.const 6917015)) if i32.const 71 return end
        (i32.eq (local.get $bitmap) (i32.const 10090905)) if i32.const 72 return end
        (i32.eq (local.get $bitmap) (i32.const 7479847)) if i32.const 73 return end
        (i32.eq (local.get $bitmap) (i32.const 3215766)) if i32.const 74 return end
        (i32.eq (local.get $bitmap) (i32.const 10144425)) if i32.const 75 return end
        (i32.eq (local.get $bitmap) (i32.const 8947855)) if i32.const 76 return end
        (i32.eq (local.get $bitmap) (i32.const 6920598)) if i32.const 79 return end
        (i32.eq (local.get $bitmap) (i32.const 15310472)) if i32.const 80 return end
        (i32.eq (local.get $bitmap) (i32.const 15310505)) if i32.const 82 return end
        (i32.eq (local.get $bitmap) (i32.const 7898654)) if i32.const 83 return end
        (i32.eq (local.get $bitmap) (i32.const 10066326)) if i32.const 85 return end
        (i32.eq (local.get $bitmap) (i32.const 8933922)) if i32.const 89 return end
        (i32.eq (local.get $bitmap) (i32.const 15803535)) if i32.const 90 return end
        unreachable
    )

    (func $getLetterRow
            (param $pointer i32)
            (param $length i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (local $dx i32)
        (local $value i32)
        (loop $loop
            (local.set $value (i32.or (i32.shl (local.get $value) (i32.const 1))
                (i32.ne (i32.const -1) (call $coordIndex
                    (local.get $pointer) (local.get $length)
                    (i32.add (local.get $x) (local.get $dx)) (local.get $y)
                ))
            ))
            (local.set $dx (i32.add (local.get $dx) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $dx) (i32.const 4)))
        )
        local.get $value
    )

    (func $getLetter
            (param $coordsPointer i32)
            (param $coordsLength i32)
            (param $startX i32)
            (result i32)
        (local $y i32)
        (local $value i32)
        (loop $loop
            (local.set $value (i32.or (i32.shl (local.get $value) (i32.const 4)) (call $getLetterRow
                (local.get $coordsPointer) (local.get $coordsLength)
                (local.get $startX) (local.get $y)
            )))
            (local.set $y (i32.add (local.get $y) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $y) (i32.const 6)))
        )
        (call $ocrBitmapLookup (local.get $value))
    )

    (func $getLetters
            (param $coordsPointer i32)
            (param $coordsLength i32)
            (result i32 i32 i32 i32 i32 i32 i32 i32)
        (call $getLetter (local.get $coordsPointer) (local.get $coordsLength) (i32.const 0))
        (call $getLetter (local.get $coordsPointer) (local.get $coordsLength) (i32.const 5))
        (call $getLetter (local.get $coordsPointer) (local.get $coordsLength) (i32.const 10))
        (call $getLetter (local.get $coordsPointer) (local.get $coordsLength) (i32.const 15))
        (call $getLetter (local.get $coordsPointer) (local.get $coordsLength) (i32.const 20))
        (call $getLetter (local.get $coordsPointer) (local.get $coordsLength) (i32.const 25))
        (call $getLetter (local.get $coordsPointer) (local.get $coordsLength) (i32.const 30))
        (call $getLetter (local.get $coordsPointer) (local.get $coordsLength) (i32.const 35))
    )

    (func $readCoord (param $pointer i32) (param $position i32) (result i32 i32)
        (i32.load (i32.add (local.get $pointer) (i32.mul (local.get $position) (i32.const 8))))
        (i32.load (i32.add (local.get $pointer) (i32.add
            (i32.mul (local.get $position) (i32.const 8))
            (i32.const 4)
        )))
    )

    (func $coordIndex
            (param $pointer i32)
            (param $length i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (local $index i32)
        (local $yEqual i32)
        (loop $loop
            (call $readCoord (local.get $pointer) (local.get $index))
            local.get $y
            i32.eq
            local.set $yEqual
            local.get $x
            i32.eq
            local.get $yEqual
            i32.and
            if local.get $index return end
            (local.set $index (i32.add (local.get $index) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $index) (local.get $length)))
        )
        i32.const -1
    )

    (func $writeCoord
            (param $pointer i32)
            (param $length i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (i32.ne (i32.const -1) (call $coordIndex
            (local.get $pointer) (local.get $length)
            (local.get $x) (local.get $y)
        ))
        if local.get $length return end
        (i32.store
            (i32.add (local.get $pointer) (i32.mul (local.get $length) (i32.const 8)))
            (local.get $x)
        )
        (i32.store
            (i32.add (local.get $pointer) (i32.add
                (i32.mul (local.get $length) (i32.const 8))
                (i32.const 4)
            ))
            (local.get $y)
        )
        (i32.add (local.get $length) (i32.const 1))
    )

    (func $foldCoord
            (param $x i32)
            (param $y i32)
            (param $instrsPointer i32)
            (param $instrsLength i32)
            (result i32 i32)
        (local $position i32)
        (local $n i32)
        (loop $loop
            (local.set $n (i32.load (i32.add (local.get $instrsPointer) (i32.add
                (i32.mul (local.get $position) (i32.const 5))
                (i32.const 1)
            ))))
            (i32.load8_u (i32.add
                (local.get $instrsPointer)
                (i32.mul (local.get $position) (i32.const 5))
            ))
            if
                (i32.gt_u (local.get $x) (local.get $n))
                if
                    (local.set $x (i32.sub (i32.mul (local.get $n) (i32.const 2)) (local.get $x)))
                end
            else
                (i32.gt_u (local.get $y) (local.get $n))
                if
                    (local.set $y (i32.sub (i32.mul (local.get $n) (i32.const 2)) (local.get $y)))
                end
            end
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $instrsLength)))
        )
        local.get $x
        local.get $y
    )

    (func $foldCoords
            (param $coordsPointer i32)
            (param $coordsLength i32)
            (param $instrsPointer i32)
            (param $instrsLength i32)
            (param $writePointer i32)
            (result i32)
        (local $writeLength i32)
        (local $position i32)
        (local $currentX i32)
        (local $currentY i32)
        (loop $loop
            (call $readCoord (local.get $coordsPointer) (local.get $position))
            local.set $currentY
            local.set $currentX
            (call $foldCoord
                (local.get $currentX) (local.get $currentY)
                (local.get $instrsPointer) (local.get $instrsLength)
            )
            local.set $currentY
            local.set $currentX
            (call $writeCoord
                (local.get $writePointer) (local.get $writeLength)
                (local.get $currentX) (local.get $currentY)
            )
            local.set $writeLength
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $coordsLength)))
        )
        local.get $writeLength
    )

    (func $part1
            (param $coordsPointer i32)
            (param $coordsLength i32)
            (param $instrsPointer i32)
            (param $instrsLength i32)
            (param $writePointer i32)
            (result i32)
        (call $foldCoords
            (local.get $coordsPointer) (local.get $coordsLength)
            (local.get $instrsPointer) (i32.const 1)
            (local.get $writePointer)
        )
    )

    (func $part2
            (param $coordsPointer i32)
            (param $coordsLength i32)
            (param $instrsPointer i32)
            (param $instrsLength i32)
            (param $writePointer i32)
            (result i32 i32 i32 i32 i32 i32 i32 i32)
        (call $foldCoords
            (local.get $coordsPointer) (local.get $coordsLength)
            (local.get $instrsPointer) (local.get $instrsLength)
            (local.get $writePointer)
        )
        local.set $coordsLength
        (call $getLetters (local.get $writePointer) (local.get $coordsLength))
    )

    (func (export "main")
            (param $inputPointer i32)
            (param $inputLength i32)
            (result i32 i32 i32 i32 i32 i32 i32 i32 i32)
        (local $coordsPointer i32)
        (local $coordsLength i32)
        (local $instrsPointer i32)
        (local $instrsLength i32)
        (local $writePointer i32)
        (call $parseInput (local.get $inputPointer) (local.get $inputLength))
        local.set $writePointer
        local.set $instrsLength
        local.set $instrsPointer
        local.set $coordsLength
        local.set $coordsPointer
        (call $part1
            (local.get $coordsPointer) (local.get $coordsLength)
            (local.get $instrsPointer) (local.get $instrsLength)
            (local.get $writePointer)
        )
        (call $part2
            (local.get $coordsPointer) (local.get $coordsLength)
            (local.get $instrsPointer) (local.get $instrsLength)
            (local.get $writePointer)
        )
    )
)
