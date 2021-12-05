(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (global $asciiZero i32 (i32.const 48))
    (global $asciiNewline i32 (i32.const 10))
    (global $gridSize i32 (i32.const 1000))

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

    (func $parseLine (param $readPointer i32) (param $writePointer i32) (result i32)
        (local $value i32)
        (call $parseInt (local.get $readPointer))
        local.set $value
        (local.set $readPointer (i32.add (i32.const 1)))
        (i32.store (local.get $writePointer) (local.get $value))
        (call $parseInt (local.get $readPointer))
        local.set $value
        (local.set $readPointer (i32.add (i32.const 4)))
        (i32.store (i32.add (local.get $writePointer) (i32.const 4)) (local.get $value))
        (call $parseInt (local.get $readPointer))
        local.set $value
        (local.set $readPointer (i32.add (i32.const 1)))
        (i32.store (i32.add (local.get $writePointer) (i32.const 8)) (local.get $value))
        (call $parseInt (local.get $readPointer))
        local.set $value
        (local.set $readPointer (i32.add (i32.const 1)))
        (i32.store (i32.add (local.get $writePointer) (i32.const 12)) (local.get $value))
        local.get $readPointer
    )

    (func $parseInput (param $inputPointer i32) (param $inputLength i32) (result i32 i32)
        (local $writePointer i32)
        (local $writeLength i32)
        (local.set $writePointer (i32.add (local.get $inputPointer) (local.get $inputLength)))
        (loop $loop
            (local.set $inputPointer (call $parseLine (local.get $inputPointer) (i32.add
                (local.get $writePointer)
                (i32.mul (local.get $writeLength) (i32.const 16))
            )))
            (i32.le_u (local.get $inputPointer) (local.get $writePointer))
            if
                (local.set $writeLength (i32.add (local.get $writeLength) (i32.const 1)))
                br $loop
            end
        )
        local.get $writePointer
        local.get $writeLength
    )

    (func $plotLine (param $gridPointer i32) (param $linePointer i32) (param $skipIfDiagonal i32)
        (local $x1 i32)
        (local $y1 i32)
        (local $x2 i32)
        (local $y2 i32)
        (local $dx i32)
        (local $dy i32)
        (local $address i32)
        (local.set $x1 (i32.load (local.get $linePointer)))
        (local.set $y1 (i32.load (i32.add (local.get $linePointer) (i32.const 4))))
        (local.set $x2 (i32.load (i32.add (local.get $linePointer) (i32.const 8))))
        (local.set $y2 (i32.load (i32.add (local.get $linePointer) (i32.const 12))))
        (i32.and (local.get $skipIfDiagonal) (i32.and
            (i32.ne (local.get $x1) (local.get $x2))
            (i32.ne (local.get $y1) (local.get $y2))
        ))
        if return end
        (i32.eq (local.get $x1) (local.get $x2)) if
            (local.set $dx (i32.const 0))
        else (i32.lt_u (local.get $x1) (local.get $x2)) if
            (local.set $dx (i32.const 1))
        else
            (local.set $dx (i32.const -1))
        end end
        (i32.eq (local.get $y1) (local.get $y2)) if
            (local.set $dy (i32.const 0))
        else (i32.lt_u (local.get $y1) (local.get $y2)) if
            (local.set $dy (i32.const 1))
        else
            (local.set $dy (i32.const -1))
        end end
        (loop $loop
            (local.set $address
                (i32.add (local.get $gridPointer) (i32.add
                    (i32.mul (i32.mul (local.get $y1) (global.get $gridSize)) (i32.const 4))
                    (i32.mul (local.get $x1) (i32.const 4))
                ))
            )
            (i32.store (local.get $address) (i32.add (i32.load (local.get $address)) (i32.const 1)))
            (i32.or
                (i32.ne (local.get $x1) (local.get $x2))
                (i32.ne (local.get $y1) (local.get $y2))
            )
            if
                (local.set $x1 (i32.add (local.get $x1) (local.get $dx)))
                (local.set $y1 (i32.add (local.get $y1) (local.get $dy)))
                br $loop
            end
        )
    )

    (func $countOverlaps (param $gridPointer i32) (result i32)
        (local $position i32)
        (local $overlaps i32)
        (loop $loop
            (local.set $overlaps (i32.add (local.get $overlaps) (i32.ge_u
                (i32.load (i32.add
                    (local.get $gridPointer)
                    (i32.mul (local.get $position) (i32.const 4))
                ))
                (i32.const 2)
            )))
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u
                (local.get $position)
                (i32.mul (global.get $gridSize) (global.get $gridSize))
            ))
        )
        local.get $overlaps
    )

    (func $findOverlaps
            (param $dataPointer i32)
            (param $dataLength i32)
            (param $skipDiagonals i32)
            (result i32)
        (local $gridPointer i32)
        (local $position i32)
        (local.set $gridPointer (i32.add
            (local.get $dataPointer)
            (i32.mul (local.get $dataLength) (i32.const 16))
        ))
        (memory.fill
            (local.get $gridPointer)
            (i32.const 0)
            (i32.mul (i32.mul (global.get $gridSize) (global.get $gridSize)) (i32.const 4))
        )
        (loop $loop
            (call $plotLine
                (local.get $gridPointer)
                (i32.add
                    (local.get $dataPointer)
                    (i32.mul (local.get $position) (i32.const 16))
                )
                (local.get $skipDiagonals)
            )
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $dataLength)))
        )
        (call $countOverlaps (local.get $gridPointer))
    )

    (func $part1 (param $dataPointer i32) (param $dataLength i32) (result i32)
        (call $findOverlaps (local.get $dataPointer) (local.get $dataLength) (i32.const 1))
    )

    (func $part2 (param $dataPointer i32) (param $dataLength i32) (result i32)
        (call $findOverlaps (local.get $dataPointer) (local.get $dataLength) (i32.const 0))
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
