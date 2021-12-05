(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (global $gridSize i32 (i32.const 5))
    (global $boardLength i32 (i32.const 100))  ;; gridSize * gridSize * 4
    (global $maxInt i32 (i32.const 2147483647))
    (global $asciiSpace i32 (i32.const 32))
    (global $asciiZero i32 (i32.const 48))
    (global $asciiNewline i32 (i32.const 10))

    (func $skipSpaces (param $pointer i32) (result i32)
        (loop $loop
            (i32.eq (i32.load8_u (local.get $pointer)) (global.get $asciiSpace))
            if
                (local.set $pointer (i32.add (local.get $pointer) (i32.const 1)))
                br $loop
            end
        )
        local.get $pointer
    )

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

    (func $parseRolls (param $pointer i32) (param $writePointer i32) (result i32 i32)
        (local $length i32)
        (local $current i32)
        (loop $loop
            (call $parseInt (local.get $pointer))
            local.set $current
            local.set $pointer
            (i32.store
                (i32.add (local.get $writePointer) (i32.mul (local.get $length) (i32.const 4)))
                local.get $current
            )
            (i32.ne (i32.load8_u (local.get $pointer)) (global.get $asciiNewline))
            (local.set $pointer (i32.add (local.get $pointer) (i32.const 1)))
            (local.set $length (i32.add (local.get $length) (i32.const 1)))
            if br $loop end
        )
        local.get $pointer
        local.get $length
    )

    (func $parseBoard (param $pointer i32) (param $writePointer i32) (result i32)
        (local $row i32)
        (local $column i32)
        (local $current i32)
        (loop $rowLoop
            (local.set $column (i32.const 0))
            (loop $columnLoop
                (local.set $pointer (call $skipSpaces (local.get $pointer)))
                (call $parseInt (local.get $pointer))
                local.set $current
                local.set $pointer
                (i32.store
                    (i32.add (local.get $writePointer) (i32.mul (i32.const 4) (i32.add
                        (i32.mul (local.get $row) (global.get $gridSize))
                        (local.get $column)
                    )))
                    local.get $current
                )
                (local.set $column (i32.add (local.get $column) (i32.const 1)))
                (br_if $columnLoop (i32.lt_u (local.get $column) (global.get $gridSize)))
            )
            (local.set $pointer (i32.add (local.get $pointer) (i32.const 1)))
            (local.set $row (i32.add (local.get $row) (i32.const 1)))
            (br_if $rowLoop (i32.lt_u (local.get $row) (global.get $gridSize)))
        )
        local.get $pointer
    )

    (func $parseInput (param $readPointer i32) (param $inputLength i32) (result i32 i32 i32 i32)
        (local $writePointer i32)
        (local $rollPointer i32)
        (local $rollLength i32)
        (local $boardsPointer i32)
        (local $boardsLength i32)
        (local.tee $writePointer (i32.add (local.get $readPointer) (local.get $inputLength)))
        local.set $rollPointer
        (call $parseRolls (local.get $readPointer) (local.get $rollPointer))
        local.set $rollLength
        local.set $readPointer
        (local.tee $writePointer (i32.add
            (local.get $rollPointer)
            (i32.mul (local.get $rollLength) (i32.const 4))
        ))
        local.set $boardsPointer
        (loop $loop
            (local.set $readPointer (i32.add (local.get $readPointer) (i32.const 1)))
            (i32.lt_u (local.get $readPointer) (local.get $rollPointer))
            if
                (local.set $readPointer
                    (call $parseBoard (local.get $readPointer) (local.get $writePointer))
                )
                (local.set $boardsLength (i32.add (local.get $boardsLength) (i32.const 1)))
                (local.set $writePointer
                    (i32.add (local.get $writePointer) (global.get $boardLength))
                )
                br $loop
            end
        )
        local.get $rollPointer
        local.get $rollLength
        local.get $boardsPointer
        local.get $boardsLength
    )

    (func $getRollTurn (param $rollPointer i32) (param $roll i32) (result i32)
        (local $turn i32)
        (loop $loop
            (i32.ne (local.get $roll) (i32.load
                (i32.add (local.get $rollPointer) (i32.mul (local.get $turn) (i32.const 4)))
            ))
            if
                (local.set $turn (i32.add (local.get $turn) (i32.const 1)))
                br $loop
            end
        )
        local.get $turn
    )

    (func $getLineCompletionTurn
            (param $linePointer i32)
            (param $lineJump i32)
            (param $rollPointer i32)
            (result i32)
        (local $turn i32)
        (local $position i32)
        (local $current i32)
        (loop $loop
            (local.set $current (call $getRollTurn (local.get $rollPointer) (i32.load (i32.add
                (local.get $linePointer)
                (i32.mul (local.get $position) (local.get $lineJump))
            ))))
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (i32.gt_s (local.get $current) (local.get $turn))
            if (local.set $turn (local.get $current)) end
            (br_if $loop (i32.lt_u (local.get $position) (global.get $gridSize)))
        )
        local.get $turn
    )

    (func $getBoardCompletionTurn (param $boardPointer i32) (param $rollPointer i32) (result i32)
        (local $turn i32)
        (local $currentTurn i32)
        (local $n i32)
        (local.set $turn (global.get $maxInt))
        (loop $loop
            (local.set $currentTurn
                (call $getLineCompletionTurn
                    (i32.add
                        (local.get $boardPointer)
                        (i32.mul (i32.mul (local.get $n) (global.get $gridSize)) (i32.const 4))
                    )
                    (i32.const 4)
                    (local.get $rollPointer)
                )
            )
            (i32.lt_u (local.get $currentTurn) (local.get $turn))
            if (local.set $turn (local.get $currentTurn)) end
            (local.set $currentTurn
                (call $getLineCompletionTurn
                    (i32.add (local.get $boardPointer) (i32.mul (local.get $n) (i32.const 4)))
                    (i32.mul (global.get $gridSize) (i32.const 4))
                    (local.get $rollPointer)
                )
            )
            (i32.lt_u (local.get $currentTurn) (local.get $turn))
            if (local.set $turn (local.get $currentTurn)) end
            (local.set $n (i32.add (local.get $n) (i32.const 1)))
            (i32.lt_u (local.get $n) (global.get $gridSize))
            if br $loop end
        )
        local.get $turn
    )

    (func $getBoardScore
            (param $boardPointer i32)
            (param $turn i32)
            (param $rollPointer i32)
            (result i32)
        (local $score i32)
        (local $current i32)
        (local $position i32)
        (local $length i32)
        (local.set $length (i32.mul (global.get $gridSize) (global.get $gridSize)))
        (loop $loop
            (local.set $current (i32.load (i32.add
                (local.get $boardPointer)
                (i32.mul (local.get $position) (i32.const 4))
            )))
            (i32.gt_u
                (call $getRollTurn (local.get $rollPointer) (local.get $current))
                (local.get $turn)
            )
            if (local.set $score (i32.add (local.get $score) (local.get $current))) end
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $length)))
        )
        (i32.mul (local.get $score) (i32.load (i32.add (local.get $rollPointer) (i32.mul
            (local.get $turn) (i32.const 4))
        )))
    )

    (func $getBoardScores (param $inputPointer i32) (param $inputLength i32) (result i32 i32)
        (local $rollPointer i32)
        (local $rollLength i32)
        (local $boardsPointer i32)
        (local $boardsLength i32)
        (local $scoresPointer i32)
        (local $boardWinTurn i32)
        (local $writePointer i32)
        (call $parseInput (local.get $inputPointer) (local.get $inputLength))
        local.set $boardsLength
        local.set $boardsPointer
        local.set $rollLength
        local.set $rollPointer
        (local.tee $scoresPointer (i32.add
            (local.get $boardsPointer)
            (i32.mul (local.get $boardsLength) (global.get $boardLength))
        ))
        local.set $writePointer
        (loop $loop
            (local.set $boardWinTurn
                (call $getBoardCompletionTurn (local.get $boardsPointer) (local.get $rollPointer))
            )
            (i32.store (local.get $writePointer) (local.get $boardWinTurn))
            (i32.store
                (i32.add (local.get $writePointer) (i32.const 4))
                (call $getBoardScore
                    (local.get $boardsPointer)
                    (local.get $boardWinTurn)
                    (local.get $rollPointer)
                )
            )
            (local.set $writePointer (i32.add (local.get $writePointer) (i32.const 8)))
            (local.set $boardsPointer (i32.add
                (local.get $boardsPointer)
                (global.get $boardLength)
            ))
            (br_if $loop (i32.lt_u (local.get $boardsPointer) (local.get $scoresPointer)))
        )
        local.get $scoresPointer
        local.get $boardsLength
    )

    (func $findScore
            (param $scoresPointer i32)
            (param $scoresLength i32)
            (param $findLast i32)
            (result i32)
        (local $score i32)
        (local $turn i32)
        (local $position i32)
        (local $currentTurn i32)
        (i32.eq (local.get $findLast) (i32.const 0))
        if (local.set $turn (global.get $maxInt)) end
        (loop $loop
            (local.set $currentTurn (i32.load (i32.add
                (local.get $scoresPointer)
                (i32.mul (local.get $position) (i32.const 8))
            )))
            (i32.xor
                (local.get $findLast)
                (i32.lt_u (local.get $currentTurn) (local.get $turn))
            )
            if
                (local.set $turn (local.get $currentTurn))
                (local.set $score (i32.load (i32.add (i32.const 4) (i32.add
                    (local.get $scoresPointer)
                    (i32.mul (local.get $position) (i32.const 8))
                ))))
            end
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (i32.lt_u (local.get $position) (local.get $scoresLength))
            if br $loop end
        )
        local.get $score
    )

    (func $part1 (param $scoresPointer i32) (param $scoresLength i32) (result i32)
        (call $findScore
            (local.get $scoresPointer)
            (local.get $scoresLength)
            (i32.const 0)
        )
    )

    (func $part2 (param $scoresPointer i32) (param $scoresLength i32) (result i32)
        (call $findScore
            (local.get $scoresPointer)
            (local.get $scoresLength)
            (i32.const 1)
        )
    )

    (func (export "main") (param $inputPointer i32) (param $inputLength i32) (result i32 i32)
        (local $scoresPointer i32)
        (local $scoresLength i32)
        (call $getBoardScores (local.get $inputPointer) (local.get $inputLength))
        local.set $scoresLength
        local.set $scoresPointer
        (call $part1 (local.get $scoresPointer) (local.get $scoresLength))
        (call $part2 (local.get $scoresPointer) (local.get $scoresLength))
    )
)
