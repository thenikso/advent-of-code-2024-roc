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
    AoC.solve! day 2 part2 #

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

part2 = \input -> None

expect part2 example == None

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
    List.walkWithIndexUntil disk 0 \sum, block, index ->
        when block is
            File id -> Continue (sum + (index * id))
            Empty -> Break sum

expect
    actual = "12345" |> parsePuzzle |> diskCompact |> diskChecksum
    actual == 60
