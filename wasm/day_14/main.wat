(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (global $asciiNewline i32 (i32.const 10))
    (global $asciiUpperA i32 (i32.const 65))

    ;; Pairs: (before, after, insert, count, nextCount)
    ;; Where before & after are the pair to match, insert is the letter to
    ;; insert, count is the number of times the pair occurs currently, and
    ;; nextCount is the number of times it will occur next iteration (so far).
    ;; Each letter (before, after, insert) is stored as a byte, and each
    ;; count as a u64. Therefore, each entry is 19 bytes long. The pairs are
    ;; a simple series of entries. The number of entries in the pairs is stored
    ;; in the stack.

    ;; Get a pointer to an entry by its pair, or -1 if not found.
    (func $pairs:locateEntry
            (param $pointer i32)
            (param $length i32)
            (param $before i32)
            (param $after i32)
            (result i32)
        (local $position i32)
        (local $pairPointer i32)
        (loop $loop
            (local.set $pairPointer (i32.add (local.get $pointer) (i32.mul
                (local.get $position) (i32.const 19)
            )))
            (i32.eq (local.get $before) (i32.load8_u (local.get $pairPointer)))
            if
                (i32.eq (local.get $after)
                    (i32.load8_u (i32.add (local.get $pairPointer) (i32.const 1)))
                )
                if
                    local.get $pairPointer
                    return
                end
            end
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $length)))
        )
        i32.const -1
    )

    ;; Add a new entry to the pairs with count 0.
    (func $pairs:addEntry
            (param $pointer i32)
            (param $length i32)
            (param $before i32)
            (param $after i32)
            (param $insert i32)
            (result i32) ;; Returns new length.
        (local $pairPointer i32)
        (local.set $pairPointer (i32.add (local.get $pointer) (i32.mul
            (local.get $length) (i32.const 19)
        )))
        (i32.store8 (local.get $pairPointer) (local.get $before))
        (i32.store8 (i32.add (local.get $pairPointer) (i32.const 1)) (local.get $after))
        (i32.store8 (i32.add (local.get $pairPointer) (i32.const 2)) (local.get $insert))
        (i64.store (i32.add (local.get $pairPointer) (i32.const 3)) (i64.const 0))
        (i64.store (i32.add (local.get $pairPointer) (i32.const 11)) (i64.const 0))
        (i32.add (local.get $length) (i32.const 1))
    )

    ;; Find an pairs entry by pair, and increase nextCount by a given amount.
    (func $pairs:incrEntry
            (param $pointer i32)
            (param $length i32)
            (param $before i32)
            (param $after i32)
            (param $count i64)
        (local $pairPointer i32)
        (i32.eq (i32.const -1) (local.tee $pairPointer (call $pairs:locateEntry
            (local.get $pointer) (local.get $length) (local.get $before) (local.get $after)
        )))
        if unreachable end
        (i64.store
            (i32.add (local.get $pairPointer) (i32.const 11))
            (i64.add (local.get $count) (i64.load
                (i32.add (local.get $pairPointer) (i32.const 11))
            ))
        )
    )

    ;; Get the before, after, insert and count of an entry by index.
    (func $pairs:readEntry
            (param $pointer i32)
            (param $length i32)
            (param $position i32)
            (result i32 i32 i32 i64)
        (local $pairPointer i32)
        (local.set $pairPointer (i32.add (local.get $pointer) (i32.mul
            (local.get $position) (i32.const 19)
        )))
        (i32.load8_u (local.get $pairPointer))
        (i32.load8_u (i32.add (i32.const 1) (local.get $pairPointer)))
        (i32.load8_u (i32.add (i32.const 2) (local.get $pairPointer)))
        (i64.load (i32.add (i32.const 3) (local.get $pairPointer)))
    )

    ;; Replace all counts with nextCounts, and reset nextCounts to zero.
    (func $pairs:newIter (param $pointer i32) (param $length i32)
        (local $position i32)
        (local $pairPointer i32)
        (loop $loop
            (local.set $pairPointer (i32.add (local.get $pointer) (i32.mul
                (local.get $position) (i32.const 19)
            )))
            (i64.store (i32.add (local.get $pairPointer) (i32.const 3)) (i64.load
                (i32.add (local.get $pairPointer) (i32.const 11))
            ))
            (i64.store (i32.add (local.get $pairPointer) (i32.const 11)) (i64.const 0))
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $length)))
        )
    )

    ;; Populate a pairs instance with all pairs in a given sequence.
    (func $pairs:populate
            (param $pointer i32)
            (param $length i32)
            (param $seqPointer i32)
            (param $seqLength i32)
        (local $position i32)
        (loop $loop
            (call $pairs:incrEntry
                (local.get $pointer) (local.get $length)
                (i32.load8_u (i32.add (local.get $seqPointer) (local.get $position)))
                (i32.load8_u (i32.add
                    (local.get $seqPointer) (i32.add (i32.const 1) (local.get $position))
                ))
                (i64.const 1)
            )
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u
                (local.get $position) (i32.sub (local.get $seqLength) (i32.const 1))
            ))
        )
    )

    ;; Letters: A series of 26 u64s, each sequentially representing the number
    ;; of occurrences of a letter of the alphabet - 26 * 8 = 208 bytes.

    ;; Create empty letters.
    (func $letters:init (param $pointer i32)
        (memory.fill (local.get $pointer) (i32.const 0) (i32.const 208))
    )

    ;; Increase the count of a certain letter.
    (func $letters:incrLetter (param $pointer i32) (param $letter i32) (param $count i64)
        (local $letterPointer i32)
        (local.set $letterPointer (i32.add (local.get $pointer) (i32.mul (i32.const 8) (i32.sub
            (local.get $letter) (global.get $asciiUpperA)
        ))))
        (i64.store (local.get $letterPointer) (i64.add
            (i64.load (local.get $letterPointer)) (local.get $count)
        ))
    )

    ;; Fill letters, counting the before and after letters of each entry in a
    ;; pairs instance.
    (func $letters:fromPairs
            (param $pointer i32)
            (param $pairsPointer i32)
            (param $pairsLength i32)
        (local $position i32)
        (local $pairPointer i32)
        (loop $loop
            (local.set $pairPointer (i32.add (local.get $pairsPointer) (i32.mul
                (local.get $position) (i32.const 19)
            )))
            (call $letters:incrLetter
                (local.get $pointer)
                (i32.load8_u (local.get $pairPointer))
                (i64.load (i32.add (local.get $pairPointer) (i32.const 3)))
            )
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $pairsLength)))
        )
    )

    ;; Get the difference between the minimum and maximum letter count.
    (func $letters:getRange (param $pointer i32) (result i64)
        (local $min i64)
        (local $max i64)
        (local $count i64)
        (local $position i32)
        (local.set $min (i64.const -1))  ;; Interpreted as unsigned, so max value.
        (loop $loop
            (local.set $count (i64.load (local.get $pointer)))
            (i64.gt_u (local.get $count) (local.get $max))
            if (local.set $max (local.get $count)) end
            (i32.and
                (i64.ne (i64.const 0) (local.get $count))
                (i64.lt_u (local.get $count) (local.get $min))
            )
            if (local.set $min (local.get $count)) end
            (local.set $pointer (i32.add (local.get $pointer) (i32.const 8)))
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (i32.const 26)))
        )
        (i64.sub (local.get $max) (local.get $min))
    )

    ;; Get the length of the initial sequence given a pointer to the start.
    ;; Also returns the final letter.
    (func $parseInit (param $pointer i32) (result i32 i32)
        (local $length i32)
        (loop $loop
            (local.set $length (i32.add (local.get $length ) (i32.const 1)))
            (br_if $loop (i32.ne
                (i32.load8_u (i32.add (local.get $pointer) (local.get $length)))
                (global.get $asciiNewline)
            ))
        )
        local.get $length
        (i32.load8_u (i32.add (local.get $pointer) (i32.sub (local.get $length) (i32.const 1))))
    )

    ;; Parse each of the expansion rules into a pairs instance.
    (func $parseRules (param $readPointer i32) (param $writePointer i32) (result i32)
        (local $length i32)
        (loop $loop
            (local.set $length (call $pairs:addEntry
                (local.get $writePointer)
                (local.get $length)
                (i32.load8_u (local.get $readPointer))
                (i32.load8_u (i32.add (local.get $readPointer) (i32.const 1)))
                (i32.load8_u (i32.add (local.get $readPointer) (i32.const 6)))
            ))
            (local.set $readPointer (i32.add (local.get $readPointer) (i32.const 8)))
            (br_if $loop (i32.lt_u (local.get $readPointer) (local.get $writePointer)))
        )
        local.get $length
    )

    ;; Parse the input into a populated pairs instance.
    ;; Also returns the last letter of the initial sequence.
    (func $parseInput (param $inputPointer i32) (param $inputLength i32) (result i32 i32 i32)
        (local $initLength i32)
        (local $pairsPointer i32)
        (local $pairsLength i32)
        (local $lastLetter i32)
        (call $parseInit (local.get $inputPointer))
        local.set $lastLetter
        local.set $initLength
        (local.set $pairsPointer (i32.add (local.get $inputPointer) (local.get $inputLength)))
        (local.set $pairsLength (call $parseRules
            (i32.add (local.get $inputPointer) (i32.add (local.get $initLength) (i32.const 2)))
            (local.get $pairsPointer)
        ))
        (call $pairs:populate
            (local.get $pairsPointer) (local.get $pairsLength)
            (local.get $inputPointer) (local.get $initLength)
        )
        local.get $pairsPointer
        local.get $pairsLength
        local.get $lastLetter
    )

    ;; Replace a given pair with the two pairs it creates
    (func $expandPair
            (param $pairsPointer i32)
            (param $pairsLength i32)
            (param $position i32)
        (local $before i32)
        (local $after i32)
        (local $insert i32)
        (local $count i64)
        (call $pairs:readEntry
            (local.get $pairsPointer) (local.get $pairsLength) (local.get $position)
        )
        local.set $count
        local.set $insert
        local.set $after
        local.set $before
        (call $pairs:incrEntry
            (local.get $pairsPointer) (local.get $pairsLength)
            (local.get $before) (local.get $insert) (local.get $count)
        )
        (call $pairs:incrEntry
            (local.get $pairsPointer) (local.get $pairsLength)
            (local.get $insert) (local.get $after) (local.get $count)
        )
    )

    ;; Run a given number of expansion iterations on a pairs instance.
    (func $runIters (param $pairsPointer i32) (param $pairsLength i32) (param $iters i32)
        (local $position i32)
        (loop $iterLoop
            (local.set $position (i32.const 0))
            (loop $pairLoop
                (call $expandPair
                    (local.get $pairsPointer)
                    (local.get $pairsLength)
                    (local.get $position)
                )
                (local.set $position (i32.add (local.get $position) (i32.const 1)))
                (br_if $pairLoop (i32.lt_u (local.get $position) (local.get $pairsLength)))
            )
            (call $pairs:newIter (local.get $pairsPointer) (local.get $pairsLength))
            (local.set $iters (i32.sub (local.get $iters) (i32.const 1)))
            (br_if $iterLoop (i32.gt_s (local.get $iters) (i32.const 0)))
        )
    )

    ;; Create a letters instance from a pairs instance and return the count
    ;; range for the letters instance.
    (func $getCountRange
            (param $pairsPointer i32)
            (param $pairsLength i32)
            (param $lastLetter i32)
            (result i64)
        (local $lettersPointer i32)
        (local.set $lettersPointer (i32.add (local.get $pairsPointer) (i32.mul
            (local.get $pairsLength) (i32.const 19)
        )))
        (call $letters:init (local.get $lettersPointer))
        (call $letters:fromPairs
            (local.get $lettersPointer) (local.get $pairsPointer) (local.get $pairsLength)
        )
        (call $letters:incrLetter
            (local.get $lettersPointer) (local.get $lastLetter) (i64.const 1)
        )
        (call $letters:getRange (local.get $lettersPointer))
    )

    ;; Get the puzzle solutions for part 1 and 2 together.
    (func (export "main") (param $inputPointer i32) (param $inputLength i32) (result i64 i64)
        (local $pairsPointer i32)
        (local $pairsLength i32)
        (local $lastLetter i32)
        (call $parseInput (local.get $inputPointer) (local.get $inputLength))
        local.set $lastLetter
        local.set $pairsLength
        local.set $pairsPointer
        (call $runIters (local.get $pairsPointer) (local.get $pairsLength) (i32.const 11))
        (call $getCountRange
            (local.get $pairsPointer) (local.get $pairsLength) (local.get $lastLetter)
        )
        (call $runIters (local.get $pairsPointer) (local.get $pairsLength) (i32.const 30))
        (call $getCountRange
            (local.get $pairsPointer) (local.get $pairsLength) (local.get $lastLetter)
        )
    )
)
