(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (global $asciiNewline i32 (i32.const 10))
    (global $asciiZero i32 (i32.const 48))

    (func $parseInput (param $pointer i32) (param $length i32) (result i32 i32)
        (local $position i32)
        (local $writePointer i32)
        (local $width i32)
        (local $height i32)
        (local $byte i32)
        (local.set $writePointer (local.get $pointer))
        (loop $loop
            (local.set $byte (i32.load8_u (i32.add (get_local $pointer) (get_local $position))))
            (i32.ne (local.get $byte) (global.get $asciiNewline))
            if
                (i32.store8
                    (local.get $writePointer)
                    (i32.sub (local.get $byte) (global.get $asciiZero))
                )
                (i32.eq (local.get $height) (i32.const 0))
                if (local.set $width (i32.add (local.get $width) (i32.const 1))) end
                (local.set $writePointer (i32.add (local.get $writePointer) (i32.const 1)))
            else
                (local.set $height (i32.add (local.get $height) (i32.const 1)))
            end
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (i32.lt_u (local.get $position) (local.get $length))
            if br $loop end
        )
        local.get $width
        local.get $height
    )

    (func $getCell
            (param $pointer i32)
            (param $width i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (i32.load8_u (i32.add (local.get $pointer) (i32.add
            (i32.mul (local.get $y) (local.get $width))
            (local.get $x)
        )))
    )

    (func $setCell
            (param $pointer i32)
            (param $width i32)
            (param $x i32)
            (param $y i32)
            (param $value i32)
        (i32.store8
            (i32.add (local.get $pointer) (i32.add
                (i32.mul (local.get $y) (local.get $width))
                (local.get $x)
            ))
            (local.get $value)
        )
    )

    (func $getAbove
            (param $pointer i32)
            (param $width i32)
            (param $height i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (i32.gt_u (local.get $y) (i32.const 0))
        if (call $getCell
            (local.get $pointer) (local.get $width)
            (local.get $x) (i32.sub (local.get $y) (i32.const 1))
        ) return end
        i32.const 9
    )

    (func $getBelow
            (param $pointer i32)
            (param $width i32)
            (param $height i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (i32.lt_u (local.get $y) (i32.sub (local.get $height) (i32.const 1)))
        if (call $getCell
            (local.get $pointer) (local.get $width)
            (local.get $x) (i32.add (local.get $y) (i32.const 1))
        ) return end
        i32.const 9
    )

    (func $getLeft
            (param $pointer i32)
            (param $width i32)
            (param $height i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (i32.gt_u (local.get $x) (i32.const 0))
        if (call $getCell
            (local.get $pointer) (local.get $width)
            (i32.sub (local.get $x) (i32.const 1)) (local.get $y)
        ) return end
        i32.const 9
    )

    (func $getRight
            (param $pointer i32)
            (param $width i32)
            (param $height i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (i32.lt_u (local.get $x) (i32.sub (local.get $width) (i32.const 1)))
        if (call $getCell
            (local.get $pointer) (local.get $width)
            (i32.add (local.get $x) (i32.const 1)) (local.get $y)
        ) return end
        i32.const 9
    )

    (func $isLowPoint
            (param $pointer i32)
            (param $width i32)
            (param $height i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (local $value i32)
        (local.set $value (call $getCell
            (local.get $pointer) (local.get $width) (local.get $x) (local.get $y))
        )
        (i32.and
            (i32.and
                (i32.lt_u (local.get $value)
                    (call $getAbove
                        (local.get $pointer)
                        (local.get $width) (local.get $height)
                        (local.get $x) (local.get $y)
                    )
                )
                (i32.lt_u (local.get $value)
                    (call $getBelow
                        (local.get $pointer)
                        (local.get $width) (local.get $height)
                        (local.get $x) (local.get $y)
                    )
                )
            )
            (i32.and
                (i32.lt_u (local.get $value)
                    (call $getLeft
                        (local.get $pointer)
                        (local.get $width) (local.get $height)
                        (local.get $x) (local.get $y)
                    )
                )
                (i32.lt_u (local.get $value)
                    (call $getRight
                        (local.get $pointer)
                        (local.get $width) (local.get $height)
                        (local.get $x) (local.get $y)
                    )
                )
            )
        )
        if (local.get $value) return end
        i32.const -1
    )

    (func $part1 (param $pointer i32) (param $width i32) (param $height i32) (result i32)
        (local $total i32)
        (local $y i32)
        (local $x i32)
        (loop $rowLoop
            (local.set $x (i32.const 0))
            (loop $columnLoop
                (local.set $total (i32.add
                    (local.get $total)
                    (i32.add (i32.const 1)
                        (call $isLowPoint
                            (local.get $pointer)
                            (local.get $width) (local.get $height)
                            (local.get $x) (local.get $y)
                        )
                    )
                ))
                (local.set $x (i32.add (local.get $x) (i32.const 1)))
                (i32.lt_u (local.get $x) (local.get $width))
                if br $columnLoop end
            )
            (local.set $y (i32.add (local.get $y) (i32.const 1)))
            (i32.lt_u (local.get $y) (local.get $height))
            if br $rowLoop end
        )
        local.get $total
    )

    (func $joinCellToBasin
            (param $pointer i32)
            (param $width i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (local $before i32)
        (local.tee $before (call $getCell
            (local.get $pointer) (local.get $width)
            (local.get $x) (local.get $y)
        ))
        (i32.eq (i32.const 0))
        if
            (call $setCell
                (local.get $pointer) (local.get $width)
                (local.get $x) (local.get $y)
                (i32.const 1)
            )
            i32.const 1
            return
        end
        i32.const 0
    )

    (func $updateBasinStateCell
            (param $mapPointer i32)
            (param $statePointer i32)
            (param $width i32)
            (param $height i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (local $stateValue i32)
        (local $changed i32)
        (local.tee $stateValue (call $getCell
            (local.get $statePointer) (local.get $width) (local.get $x) (local.get $y)
        ))
        (i32.ne (i32.const 1))
        if (i32.const 0) return end
        (call $setCell
            (local.get $statePointer) (local.get $width)
            (local.get $x) (local.get $y)
            (i32.const 2)
        )
        (i32.ne
            (call $getAbove
                (local.get $mapPointer)
                (local.get $width) (local.get $height)
                (local.get $x) (local.get $y)
            )
            (i32.const 9)
        )
        if
            (local.set $changed (call $joinCellToBasin
                (local.get $statePointer)
                (local.get $width)
                (local.get $x)
                (i32.sub (local.get $y) (i32.const 1))
            ))
        end
        (i32.ne
            (call $getBelow
                (local.get $mapPointer)
                (local.get $width) (local.get $height)
                (local.get $x) (local.get $y)
            )
            (i32.const 9)
        )
        if
            (local.set $changed (i32.or (local.get $changed) (call $joinCellToBasin
                (local.get $statePointer) (local.get $width)
                (local.get $x) (i32.add (local.get $y) (i32.const 1))
            )))
        end
        (i32.ne
            (call $getLeft
                (local.get $mapPointer)
                (local.get $width) (local.get $height)
                (local.get $x) (local.get $y)
            )
            (i32.const 9)
        )
        if
            (local.set $changed (i32.or (local.get $changed) (call $joinCellToBasin
                (local.get $statePointer) (local.get $width)
                (i32.sub (local.get $x) (i32.const 1)) (local.get $y)
            )))
        end
        (i32.ne
            (call $getRight
                (local.get $mapPointer)
                (local.get $width) (local.get $height)
                (local.get $x) (local.get $y)
            )
            (i32.const 9)
        )
        if
            (local.set $changed (i32.or (local.get $changed) (call $joinCellToBasin
                (local.get $statePointer) (local.get $width)
                (i32.add (local.get $x) (i32.const 1)) (local.get $y)
            )))
        end
        local.get $changed
    )

    (func $updateBasinState
            (param $mapPointer i32)
            (param $statePointer i32)
            (param $width i32)
            (param $height i32)
            (result i32)
        (local $changed i32)
        (local $y i32)
        (local $x i32)
        (local $current i32)
        (loop $rowLoop
            (local.set $x (i32.const 0))
            (loop $columnLoop
                (call $updateBasinStateCell
                    (local.get $mapPointer)
                    (local.get $statePointer)
                    (local.get $width) (local.get $height)
                    (local.get $x) (local.get $y)
                )
                if (local.set $changed (i32.const 1)) end
                (local.set $x (i32.add (local.get $x) (i32.const 1)))
                (i32.lt_u (local.get $x) (local.get $width))
                if br $columnLoop end
            )
            (local.set $y (i32.add (local.get $y) (i32.const 1)))
            (i32.lt_u (local.get $y) (local.get $height))
            if br $rowLoop end
        )
        local.get $changed
    )

    (func $getBasinSize
            (param $pointer i32)
            (param $width i32)
            (param $height i32)
            (param $x i32)
            (param $y i32)
            (result i32)
        (local $statePointer i32)
        (local $stateSize i32)
        (local $total i32)
        (local.set $stateSize (i32.mul (local.get $width) (local.get $height)))
        (local.set $statePointer (i32.add (local.get $pointer) (local.get $stateSize)))
        (memory.fill (local.get $statePointer) (i32.const 0) (local.get $stateSize))
        (call $setCell
            (local.get $statePointer) (local.get $width)
            (local.get $x) (local.get $y)
            (i32.const 1)
        )
        (loop $loop
            (call $updateBasinState
                (local.get $pointer) (local.get $statePointer)
                (local.get $width) (local.get $height)
            )
            if br $loop end
        )
        (loop $loop
            (local.set $stateSize (i32.sub (local.get $stateSize) (i32.const 1)))
            (i32.load8_u (i32.add (local.get $statePointer) (local.get $stateSize)))
            if (local.set $total (i32.add (local.get $total) (i32.const 1))) end
            (i32.ge_s (local.get $stateSize) (i32.const 0))
            if br $loop end
        )
        (i32.sub (local.get $total) (i32.const 1)) ;; Why sub 1? No-one knows.
    )

    (func $part2 (param $pointer i32) (param $width i32) (param $height i32) (result i32)
        (local $maxSize i32)
        (local $secondMaxSize i32)
        (local $thirdMaxSize i32)
        (local $y i32)
        (local $x i32)
        (local $current i32)
        (local $isLowest i32)
        (loop $rowLoop
            (local.set $x (i32.const 0))
            (loop $columnLoop
                (i32.ne (i32.const -1)
                    (call $isLowPoint
                        (local.get $pointer)
                        (local.get $width) (local.get $height)
                        (local.get $x) (local.get $y)
                    )
                )
                if
                    (local.set $current (call $getBasinSize
                        (local.get $pointer)
                        (local.get $width) (local.get $height)
                        (local.get $x) (local.get $y)
                    ))
                    (i32.gt_u (local.get $current) (local.get $thirdMaxSize))
                    if
                        (i32.gt_u (local.get $current) (local.get $secondMaxSize))
                        if
                            (i32.gt_u (local.get $current) (local.get $maxSize))
                            if
                                (local.set $thirdMaxSize (local.get $secondMaxSize))
                                (local.set $secondMaxSize (local.get $maxSize))
                                (local.set $maxSize (local.get $current))
                            else
                                (local.set $thirdMaxSize (local.get $secondMaxSize))
                                (local.set $secondMaxSize (local.get $current))
                            end
                        else
                            (local.set $thirdMaxSize (local.get $current))
                        end
                    end
                end
                (local.set $x (i32.add (local.get $x) (i32.const 1)))
                (i32.lt_u (local.get $x) (local.get $width))
                if br $columnLoop end
            )
            (local.set $y (i32.add (local.get $y) (i32.const 1)))
            (i32.lt_u (local.get $y) (local.get $height))
            if br $rowLoop end
        )
        (i32.mul
            (i32.mul (local.get $maxSize) (local.get $secondMaxSize))
            (local.get $thirdMaxSize)
        )
    )

    (func (export "main") (param $pointer i32) (param $length i32) (result i32 i32)
        (local $width i32)
        (local $height i32)
        (call $parseInput (local.get $pointer) (local.get $length))
        local.set $height
        local.set $width
        (call $part1 (local.get $pointer) (local.get $width) (local.get $height))
        (call $part2 (local.get $pointer) (local.get $width) (local.get $height))
    )
)
