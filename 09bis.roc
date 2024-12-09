app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br",
    aoc: "./package/main.roc",
}

import pf.Stdout
import pf.File
import pf.Utc
import aoc.AoC {
    readfile: File.readUtf8,
    stdout: Stdout.write,
    time: \{} -> Utc.now {} |> Task.map Utc.toMillisSinceEpoch,
}

day = "09"

main =
    AoC.solve! day 1 part1 # 6344673854800
    AoC.solve! day 2 part2 # 6360363199987

example =
    "2333133121414131402"

# Solutions

part1 = \input ->
    input
    |> parsePuzzle
    |> diskCompact
    |> diskChecksum
    |> Ok

expect part1 example == Ok 1928

part2 = \input ->
    input
    |> parsePuzzle
    |> defragmentDisk
    |> diskChecksum
    |> Ok

expect part2 example == Ok 2858

# Utils

Block : [Empty, File U64]
Puzzle : List Block

printPuzzle = \puzzle ->
    List.walk puzzle "" \acc, block ->
        when block is
            File i -> Str.concat acc (Num.toStr i)
            Empty -> Str.concat acc "."

parsePuzzle = \text ->
    text
    |> Str.trimEnd
    |> Str.toUtf8
    |> List.append '0'
    |> List.walk
        {
            fileIndex: 0,
            fileSize: 0,
            result: List.withCapacity 1000,
        }
        \state, char ->
            size = char - '0' |> Num.toU64
            if state.fileSize > 0 then
                result1 = diskInsert state.result (File state.fileIndex) state.fileSize
                result2 = diskInsert result1 Empty size
                {
                    fileIndex: state.fileIndex + 1,
                    fileSize: 0,
                    result: result2,
                }
            else
                { state & fileSize: size }
    |> .result

expect
    actual = parsePuzzle "12345" |> printPuzzle
    actual == "0..111....22222"

diskInsert : Puzzle, Block, U64 -> Puzzle
diskInsert = \disk, block, n ->
    if n == 0 then
        disk
    else
        diskInsert (List.append disk block) block (n - 1)

diskCompact : Puzzle -> Puzzle
diskCompact = \disk ->
    diskSize = List.len disk
    List.walkBackwardsUntil
        disk
        {
            backwardIndex: diskSize - 1,
            forwardIndex: 0,
            result: disk,
        }
        \state, block ->
            if block == Empty then
                Continue { state & backwardIndex: state.backwardIndex - 1 }
            else
                nextForwardIndex =
                    List.walkFromUntil
                        disk
                        state.forwardIndex
                        state.forwardIndex
                        \index, b ->
                            when b is
                                Empty -> Break index
                                _ -> Continue (index + 1)
                if nextForwardIndex >= state.backwardIndex then
                    Break state
                else
                    result = List.swap state.result nextForwardIndex state.backwardIndex
                    Continue {
                        backwardIndex: state.backwardIndex - 1,
                        forwardIndex: nextForwardIndex + 1,
                        result,
                    }
    |> .result

expect
    actual = "12345" |> parsePuzzle |> diskCompact |> printPuzzle
    actual == "022111222......"

diskChecksum : Puzzle -> U64
diskChecksum = \disk ->
    List.walkWithIndex disk 0 \sum, block, index ->
        when block is
            File id -> (sum + (index * id))
            Empty -> sum

expect
    actual = "12345" |> parsePuzzle |> diskCompact |> diskChecksum
    actual == 60

defragmentDisk : Puzzle -> Puzzle
defragmentDisk = \disk ->
    defragmentRecursive disk (List.len disk - 1)

expect
    actual = example |> parsePuzzle |> defragmentDisk |> printPuzzle
    actual == "00992111777.44.333....5555.6666.....8888.."

defragmentRecursive = \disk, backwardIndex ->
    if backwardIndex < 2 then
        disk
    else
        when findFileRangeBackwardFrom disk backwardIndex is
            Err _ -> disk
            Ok file ->
                newDisk =
                    when findFreeSpace disk file.size 0 file.start is
                        Err _ -> disk
                        Ok free ->
                            { start: At 0, end: Before file.size }
                            |> List.range
                            |> List.walk disk \state, offset ->
                                List.swap state (file.start + offset) (free.start + offset)
                if file.start < 1 then
                    disk
                else
                    defragmentRecursive newDisk (file.start - 1)

findFileRangeBackwardFrom : Puzzle, U64 -> Result { fileId : U64, start : U64, end : U64, size : U64 } [NotFound]
findFileRangeBackwardFrom = \disk, backwardLimit ->
    result =
        List.walkBackwardsUntil
            disk
            { index: (List.len disk - 1), endIndex: 0, file: Empty }
            \state, block ->
                if state.index > backwardLimit then
                    Continue { state & index: state.index - 1 }
                else
                    when block is
                        Empty ->
                            if state.file != Empty then
                                Break { state & index: state.index + 1 }
                            else
                                Continue { state & index: state.index - 1 }

                        File id ->
                            when state.file is
                                Empty ->
                                    Continue { index: state.index - 1, endIndex: state.index + 1, file: File id }

                                File otherId ->
                                    if id == otherId then
                                        Continue { state & index: state.index - 1 }
                                    else
                                        Break { state & index: state.index + 1 }
    when result.file is
        Empty -> Err NotFound
        File fileId ->
            Ok {
                fileId,
                start: result.index,
                end: result.endIndex,
                size: result.endIndex - result.index,
            }

expect
    # 00...111...2...333.44.5555.6666.777.888899
    actual = example |> parsePuzzle |> findFileRangeBackwardFrom 41
    actual == Ok { fileId: 9, start: 40, end: 42, size: 2 }

expect
    actual = example |> parsePuzzle |> findFileRangeBackwardFrom 39
    actual == Ok { fileId: 8, start: 36, end: 40, size: 4 }

findFreeSpace = \disk, minSize, limitStart, limitEnd ->
    result =
        List.walkFromUntil
            disk
            limitStart
            { startIndex: 0, endIndex: limitStart, emptyFound: Bool.false }
            \state, block ->
                if state.endIndex > limitEnd then
                    Break state
                else
                    when block is
                        File _ ->
                            if state.emptyFound then
                                Break { state & endIndex: state.endIndex + 1 }
                            else
                                Continue { state & endIndex: state.endIndex + 1 }

                        Empty ->
                            if state.emptyFound then
                                Continue { state & endIndex: state.endIndex + 1 }
                            else
                                Continue { state & emptyFound: Bool.true, startIndex: state.endIndex }
    if result.emptyFound then
        size = result.endIndex - result.startIndex
        if size < minSize then
            if result.endIndex >= limitEnd then
                Err NotFound
            else
                findFreeSpace disk minSize result.endIndex limitEnd
        else
            Ok {
                start: result.startIndex,
                end: result.endIndex,
                size,
            }
    else
        Err NotFound

expect
    actual = example |> parsePuzzle |> findFreeSpace 1 0 20
    actual == Ok { start: 2, end: 5, size: 3 }
