(module

    (import "log" "printi" (func $printi (param i32)))
    (import "log" "printf" (func $printf (param f32)))
    (import "log" "printarr2d" (func $printarr2d (param i32 i32 i32)))
    (memory $memory 1)
    (export "memory" (memory $memory))

    (global $asciiNewline i32 (i32.const 10))
    (global $asciiOne i32 (i32.const 49))

    (func $parseInput (param $inputPointer i32) (param $inputLength i32) (result i32 i32 i32)
        (local $readPointer i32)
        (local $writePointer i32)
        (local $writeLength i32)
        (local $writeValueLength i32)
        (local $valueLengthObtained i32)
        (local $returnPointer i32)
        (local $currentByte i32)
        (local.set $writeLength (i32.const 0))
        (local.set $writeValueLength (i32.const 0))
        (local.set $valueLengthObtained (i32.const 0))
        (local.set $readPointer (local.get $inputPointer))
        (local.tee $writePointer
            (i32.add (local.get $readPointer) (local.get $inputLength))
        )
        local.set $returnPointer
        (loop $loop
            (local.set $currentByte (i32.load8_u (local.get $readPointer)))
            (i32.eq (global.get $asciiNewline) (local.get $currentByte))
            if
                (local.set $writeLength (i32.add (local.get $writeLength) (i32.const 1)))
                (local.set $valueLengthObtained (i32.const 1))
            else
                (i32.store
                    (local.get $writePointer)
                    (i32.eq (global.get $asciiOne) (local.get $currentByte))
                )
                (local.set $writePointer (i32.add (local.get $writePointer) (i32.const 4)))
                (i32.eq (local.get $valueLengthObtained) (i32.const 0))
                if
                    (local.set $writeValueLength
                        (i32.add (local.get $writeValueLength) (i32.const 1))
                    )
                end
            end
            (local.tee $readPointer (i32.add (local.get $readPointer) (i32.const 1)))
            local.get $returnPointer
            i32.lt_u
            if br $loop end
        )
        local.get $returnPointer
        local.get $writeLength
        local.get $writeValueLength
    )

    (func $getMostFrequent
            (param $arrayPointer i32)
            (param $arrayLength i32)
            (param $arrayItemLength i32)
            (param $position i32)
            (result i32)
        (local $sum f32)
        (local $currentPointer i32)
        (local $end i32)
        (local.set $currentPointer (i32.add
            (local.get $arrayPointer)
            (i32.mul (local.get $position) (i32.const 4)))
        )
        (local.set $sum (f32.const 0))
        (local.set $end (i32.add
            (local.get $arrayPointer)
            (i32.mul (i32.mul (local.get $arrayLength) (local.get $arrayItemLength)) (i32.const 4))
        ))
        (loop $loop
            (local.set $sum (f32.add
                (local.get $sum)
                (f32.convert_i32_u (i32.load (local.get $currentPointer)))
            ))
            (local.set $currentPointer
                (i32.add
                    (local.get $currentPointer)
                    (i32.mul (local.get $arrayItemLength) (i32.const 4))
                )
            )
            (i32.lt_u (local.get $currentPointer) (local.get $end))
            if br $loop end
        )
        (f32.gt (local.get $sum) (f32.div
            (f32.convert_i32_u (local.get $arrayLength))
            (f32.const 2)
        ))
    )

    (func $part1 (param $dataPointer i32) (param $dataLength i32) (param $valueLength i32) (result i32)
        (local $gamma i32)
        (local $gammaPosition i32)
        (local $lengthMask i32)
        (local.set $gammaPosition (i32.const 0))
        (loop $loop
            (local.set $gamma
                (i32.add
                    (i32.shl (local.get $gamma) (i32.const 1))
                    (call $getMostFrequent
                        (local.get $dataPointer)
                        (local.get $dataLength)
                        (local.get $valueLength)
                        (local.get $gammaPosition)
                    )
                )
            )
            (local.set $gammaPosition (i32.add (local.get $gammaPosition) (i32.const 1)))
            (i32.lt_u (local.get $gammaPosition) (local.get $valueLength))
            if br $loop end
        )
        (local.set $lengthMask
            (i32.sub (i32.shl (i32.const 1) (local.get $valueLength)) (i32.const 1))
        )
        (i32.mul
            (local.get $gamma)
            (i32.and (local.get $lengthMask) (i32.xor (local.get $gamma) (local.get $lengthMask)))
        )
    )

    (func $bitArrayToInt (param $arrayPointer i32) (param $arrayLength i32) (result i32)
        (local $value i32)
        (local $position i32)
        (local.set $value (i32.const 0))
        (local.set $position (i32.const 0))
        (loop $loop
            (local.set $value (i32.add
                (i32.shl (local.get $value) (i32.const 1))
                (i32.load (i32.add
                    (local.get $arrayPointer)
                    (i32.mul (local.get $position) (i32.const 4))
                ))
            ))
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (i32.lt_u (local.get $position) (local.get $arrayLength))
            if br $loop end
        )
        local.get $value
    )

    (func $copyArray (param $from i32) (param $to i32) (param $length i32)
        (local $position i32)
        (loop $loop
            (i32.store
                (i32.add (local.get $to) (i32.mul (local.get $position) (i32.const 4)))
                (i32.load (i32.add (local.get $from) (i32.mul (local.get $position) (i32.const 4))))
            )
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (i32.lt_u (local.get $position) (local.get $length))
            if br $loop end
        )
    )

    (func $selectBits
            (param $readPointer i32)
            (param $readLength i32)
            (param $readItemLength i32)
            (param $writePointer i32)
            (param $position i32)
            (param $mostFrequent i32)
            (result i32)
        (local $select i32)
        (local $readPosition i32)
        (local $writePosition i32)
        (local $currentPointer i32)
        (local.set $select
            (i32.xor
                (call $getMostFrequent
                    (local.get $readPointer)
                    (local.get $readLength)
                    (local.get $readItemLength)
                    (local.get $position))
                (local.get $mostFrequent)
            )
        )
        (local.set $readPosition (i32.const 0))
        (local.set $writePosition (i32.const 0))
        (loop $loop
            (local.set $currentPointer (i32.add
                (local.get $readPointer)
                (i32.mul
                    (i32.mul (local.get $readPosition) (local.get $readItemLength))
                    (i32.const 4)
                )
            ))
            (i32.eq
                (i32.load (i32.add
                    (local.get $currentPointer)
                    (i32.mul (local.get $position) (i32.const 4))
                ))
                (local.get $select)
            )
            if
                (call $copyArray
                    (local.get $currentPointer)
                    (i32.add
                        (local.get $writePointer)
                        (i32.mul
                            (i32.mul (local.get $writePosition) (local.get $readItemLength))
                            (i32.const 4)
                        )
                    )
                    (local.get $readItemLength)
                )
                (local.set $writePosition (i32.add (local.get $writePosition) (i32.const 1)))
            end
            (local.set $readPosition (i32.add (local.get $readPosition) (i32.const 1)))
            (i32.lt_u (local.get $readPosition) (local.get $readLength))
            if br $loop end
        )
        local.get $writePosition
    )

    (func $halfPart2
            (param $dataPointer i32)
            (param $dataLength i32)
            (param $valueLength i32)
            (param $mostFrequent i32)
            (result i32)
        (local $valuesPointer i32)
        (local $valuesLength i32)
        (local $position i32)
        (local $valueReadPointer i32)
        (local.set $valuesPointer (i32.add
            (local.get $dataPointer)
            (i32.mul (i32.mul (local.get $dataLength) (local.get $valueLength)) (i32.const 4))
        ))
        (local.set $valuesLength (call $selectBits
            (local.get $dataPointer)
            (local.get $dataLength)
            (local.get $valueLength)
            (local.get $valuesPointer)
            (i32.const 0)
            (local.get $mostFrequent)
        ))
        (local.set $position (i32.const 1))
        (loop $loop
            (local.set $valuesLength (call $selectBits
                (local.get $valuesPointer)
                (local.get $valuesLength)
                (local.get $valueLength)
                (local.get $valuesPointer)
                (local.get $position)
                (local.get $mostFrequent)
            ))
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (i32.gt_u (local.get $valuesLength) (i32.const 1))
            if br $loop end
        )
        (call $bitArrayToInt (local.get $valuesPointer) (local.get $valueLength))
    )

    (func $part2 (param $dataPointer i32) (param $dataLength i32) (param $valueLength i32) (result i32)
        (i32.mul
            (call $halfPart2
                (local.get $dataPointer)
                (local.get $dataLength)
                (local.get $valueLength)
                (i32.const 0)
            )
            (call $halfPart2
                (local.get $dataPointer)
                (local.get $dataLength)
                (local.get $valueLength)
                (i32.const 1)
            )
        )
    )

    (func (export "main") (param $inputPointer i32) (param $inputLength i32) (result i32 i32)
        (local $dataPointer i32)
        (local $dataLength i32)
        (local $dataValueLength i32)
        (call $parseInput (local.get $inputPointer) (local.get $inputLength))
        local.set $dataValueLength
        local.set $dataLength
        local.set $dataPointer
        (call $part1 (local.get $dataPointer) (local.get $dataLength) (local.get $dataValueLength))
        (call $part2 (local.get $dataPointer) (local.get $dataLength) (local.get $dataValueLength))
    )
)
