(module
    (memory $memory 1)
    (export "memory" (memory $memory))

    (global $asciiDash i32 (i32.const 45))
    (global $asciiNewline i32 (i32.const 10))
    (global $asciiLowerA i32 (i32.const 97))

    (global $startNodeRaw i32 (i32.const 0x74617274))  ;; "tart"
    (global $endNodeRaw i32 (i32.const 0x00656e64))   ;; "end"
    (global $startNodeName i32 (i32.const 0xffff))
    (global $endNodeName i32 (i32.const 0xfffe))

    (global $smallCaveFlag i32 (i32.const 0x010000))
    ;; A shame to hardcode this, but allocation is hard. Max in my input was 5.
    (global $maxCaveConnections i32 (i32.const 14))
    (global $graphNodeSize i32 (i32.const 64)) ;; 4 * (maxCaveConnections + 2)

    (func $parseNode (param $pointer i32) (result i32 i32)
        (local $isSmall i32)
        (local $name i32)
        (local $byte i32)
        (loop $loop
            (local.set $byte (i32.load8_u (local.get $pointer)))
            (i32.and
                (i32.ne (local.get $byte) (global.get $asciiNewline))
                (i32.ne (local.get $byte) (global.get $asciiDash))
            )
            if
                (local.set $isSmall (i32.ge_u (local.get $byte) (global.get $asciiLowerA)))
                (local.set $name (i32.or
                    (i32.shl (local.get $name) (i32.const 8))
                    (local.get $byte)
                ))
                (local.set $pointer (i32.add (local.get $pointer) (i32.const 1)))
                br $loop
            end
        )
        (i32.eq (local.get $name) (global.get $startNodeRaw)) if
            (local.set $name (global.get $startNodeName))
        else (i32.eq (local.get $name) (global.get $endNodeRaw)) if
            (local.set $name (global.get $endNodeName))
        else local.get $isSmall if
            (local.set $name (i32.or (local.get $name) (global.get $smallCaveFlag)))
        end end end
        local.get $pointer
        local.get $name
    )

    (func $arrayPush (param $pointer i32) (param $elem i32)
        (local $length i32)
        (local.set $length (i32.add (i32.load (local.get $pointer)) (i32.const 1)))
        (i32.store (local.get $pointer) (local.get $length))
        (i32.store
            (i32.add (local.get $pointer) (i32.mul (local.get $length) (i32.const 4)))
            (local.get $elem)
        )
    )

    (func $arrayPop (param $pointer i32)
        (i32.store (local.get $pointer) (i32.sub (i32.load (local.get $pointer)) (i32.const 1)))
    )

    (func $arrayContains (param $pointer i32) (param $elem i32) (result i32)
        (local $length i32)
        (local $position i32)
        (local.set $length (i32.load (local.get $pointer)))
        (loop $loop
            (i32.eq (local.get $elem) (i32.load
                (i32.add (local.get $pointer) (i32.mul (local.get $position) (i32.const 4)))
            ))
            if i32.const 1 return end
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.le_u (local.get $position) (local.get $length)))
        )
        i32.const 0
    )

    (func $locateCave (param $graphPointer i32) (param $length i32) (param $node i32) (result i32)
        (local $position i32)
        (local $elemPointer i32)
        (loop $loop
            (local.tee $elemPointer (i32.add
                (local.get $graphPointer)
                (i32.mul (local.get $position) (global.get $graphNodeSize))
            ))
            i32.load
            local.get $node
            i32.eq
            if (i32.add (local.get $elemPointer) (i32.const 4)) return end
            (local.set $position (i32.add (local.get $position) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $position) (local.get $length)))
        )
        i32.const -1
    )

    (func $addEdge
            (param $graphPointer i32)
            (param $graphLength i32)
            (param $from i32)
            (param $to i32)
            (result i32)
        (local $elemPointer i32)
        (local.set $elemPointer (call $locateCave
            (local.get $graphPointer) (local.get $graphLength) (local.get $from)
        ))
        (i32.eq (local.get $elemPointer) (i32.const -1))
        if
            (local.set $elemPointer (i32.add (local.get $graphPointer) (i32.mul
                (local.get $graphLength) (global.get $graphNodeSize)
            )))
            (local.set $graphLength (i32.add (local.get $graphLength) (i32.const 1)))
            (i32.store (local.get $elemPointer) (local.get $from))
            (local.set $elemPointer (i32.add (local.get $elemPointer) (i32.const 4)))
        end
        (call $arrayPush (local.get $elemPointer) (local.get $to))
        local.get $graphLength
    )

    (func $parseInput (param $pointer i32) (param $length i32) (result i32 i32)
        (local $graphPointer i32)
        (local $graphLength i32)
        (local $first i32)
        (local $second i32)
        (local.set $graphPointer (i32.add (local.get $pointer) (local.get $length)))
        (loop $loop
            local.get $pointer
            call $parseNode
            local.set $first
            i32.const 1
            i32.add
            call $parseNode
            local.set $second
            i32.const 1
            i32.add
            local.set $pointer
            (local.set $graphLength (call $addEdge
                (local.get $graphPointer) (local.get $graphLength)
                (local.get $first) (local.get $second)
            ))
            (local.set $graphLength (call $addEdge
                (local.get $graphPointer) (local.get $graphLength)
                (local.get $second) (local.get $first)
            ))
            (br_if $loop (i32.lt_u (local.get $pointer) (local.get $graphPointer)))
        )
        local.get $graphPointer
        local.get $graphLength
    )

    (func $traverseGraph
            (param $graphPointer i32)
            (param $graphLength i32)
            (param $cave i32)
            (param $smallCavesPointer i32)
            (param $revisitSmallCaves i32)
            (result i32)
        (local $isSmall i32)
        (local $count i32)
        (local $idx i32)
        (local $connectionsPointer i32)
        (local $connectionsLength i32)
        (local $nextCave i32)
        (local $shouldVisit i32)
        (local $continueSmallCaves i32)
        (i32.eq (local.get $cave) (global.get $endNodeName))
        if i32.const 1 return end
        (local.tee $isSmall (i32.and (local.get $cave) (global.get $smallCaveFlag)))
        if (call $arrayPush (local.get $smallCavesPointer) (local.get $cave)) end
        (local.set $connectionsPointer (call $locateCave
            (local.get $graphPointer) (local.get $graphLength) (local.get $cave)
        ))
        (local.set $connectionsLength (i32.load (local.get $connectionsPointer)))
        (loop $loop
            (local.set $nextCave (i32.load (i32.add (local.get $connectionsPointer) (i32.mul
                (i32.add (local.get $idx) (i32.const 1))
                (i32.const 4)
            ))))
            (local.set $shouldVisit (i32.const 1))
            (call $arrayContains (local.get $smallCavesPointer) (local.get $nextCave))
            if
                local.get $revisitSmallCaves
                if (local.set $continueSmallCaves (i32.const 0))
                else (local.set $shouldVisit (i32.const 0))
                end
            else
                (i32.eq (local.get $nextCave) (global.get $startNodeName))
                if (local.set $shouldVisit (i32.const 0))
                else (local.set $continueSmallCaves (local.get $revisitSmallCaves))
                end
            end
            local.get $shouldVisit
            if
                (local.set $count (i32.add (local.get $count) (call $traverseGraph
                    (local.get $graphPointer) (local.get $graphLength)
                    (local.get $nextCave) (local.get $smallCavesPointer)
                    (local.get $continueSmallCaves)
                )))
            end
            (local.set $idx (i32.add (local.get $idx) (i32.const 1)))
            (br_if $loop (i32.lt_u (local.get $idx) (local.get $connectionsLength)))
        )
        local.get $isSmall
        if (call $arrayPop (local.get $smallCavesPointer)) end
        local.get $count
    )

    (func $part1
            (param $graphPointer i32)
            (param $graphLength i32)
            (param $writePointer i32)
            (result i32)
        (i32.store (local.get $writePointer) (i32.const 0))
        (call $traverseGraph
            (local.get $graphPointer) (local.get $graphLength)
            (global.get $startNodeName) (local.get $writePointer) (i32.const 0)
        )
    )

    (func $part2
            (param $graphPointer i32)
            (param $graphLength i32)
            (param $writePointer i32)
            (result i32)
        (i32.store (local.get $writePointer) (i32.const 0))
        (call $traverseGraph
            (local.get $graphPointer) (local.get $graphLength)
            (global.get $startNodeName) (local.get $writePointer) (i32.const 1)
        )
    )

    (func (export "main") (param $pointer i32) (param $length i32) (result i32 i32)
        (local $graphPointer i32)
        (local $graphLength i32)
        (local $writePointer i32)
        (call $parseInput (local.get $pointer) (local.get $length))
        local.set $graphLength
        local.set $graphPointer
        (local.set $writePointer (i32.add (local.get $graphPointer (i32.mul
            (local.get $graphLength) (global.get $graphNodeSize)
        ))))
        (call $part1 (local.get $graphPointer) (local.get $graphLength) (local.get $writePointer))
        (call $part2 (local.get $graphPointer) (local.get $graphLength) (local.get $writePointer))
    )
)
