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
    AoC.solve! day 1 part1 #
    AoC.solve! day 2 part2 #

example =
    "2333133121414131402"

# Solutions

part1 = \input ->
    input
    |> parsePuzzle
    |> compactDisk
    |> diskChecksum
    |> Ok

expect part1 example == Ok 1928

part2 = \input -> None

expect part2 example == None

# Utils

File : { index : U64, size : U64, freeTrail : U64 }
Puzzle : List File

parsePuzzle : Str -> Puzzle
parsePuzzle = \text ->
    disk =
        text
        |> Str.trimEnd
        |> Str.toUtf8
        |> List.append '0'
    disk
    |> List.walk
        {
            result: List.withCapacity (List.len disk // 2),
            fileIndex: 0,
            fileSize: 0,
        }
        \state, blocks ->
            size = blocks - '0' |> Num.toU64
            if state.fileSize == 0 then
                { state & fileSize: size }
            else
                {
                    result: List.append state.result {
                        index: state.fileIndex,
                        size: state.fileSize,
                        freeTrail: size,
                    },
                    fileIndex: state.fileIndex + 1,
                    fileSize: 0,
                }
    |> .result

expect
    actual = parsePuzzle "12345"
    actual
    == [
        { index: 0, size: 1, freeTrail: 2 },
        { index: 1, size: 3, freeTrail: 4 },
        { index: 2, size: 5, freeTrail: 0 },
    ]

compactDisk : Puzzle -> Puzzle
compactDisk = \puzzle ->
    puzzle
    |> List.walkBackwardsUntil
        (
            {
                result: List.withCapacity (List.len puzzle),
                index: List.len puzzle - 1,
                forwardIndex: 0,
                spaceToFill: 0,
            }
        )
        \state, file ->
            # Get new space to fill
            (spaceToFill1, result1, forwardIndex1) =
                if state.spaceToFill > 0 then
                    (state.spaceToFill, state.result, state.forwardIndex)
                else
                    claimFreeSpace puzzle state.forwardIndex state.result
            # Fill all space with current file
            # and continue getting more space if file is bigger than available space
            (spaceToFill2, result2, forwardIndex2) =
                consumeFreeSpace puzzle forwardIndex1 result1 file spaceToFill1
            # Next backward file
            newState = {
                result: result2,
                index: state.index - 1,
                forwardIndex: forwardIndex2,
                spaceToFill: spaceToFill2,
            }
            if forwardIndex2 == state.index then
                Break newState
            else
                Continue newState
    |> .result

claimFreeSpace = \puzzle, forwardIndex, result ->
    List.walkFromUntil
        puzzle
        forwardIndex
        (0, result, forwardIndex)
        \(_, res, index), forwardFile ->
            nextRes = List.append res { forwardFile & freeTrail: 0 }
            if forwardFile.freeTrail > 0 then
                Break (forwardFile.freeTrail, nextRes, index + 1)
            else
                Continue (0, nextRes, index + 1)

consumeFreeSpace = \puzzle, forwardIndex, result, file, spaceToFill ->
    fillFile = { file & freeTrail: 0, size: Num.min spaceToFill file.size }
    result1 = List.append result fillFile
    if (file.size - fillFile.size) > 0 then
        dbg (file.size - fillFile.size)
        (newFree, result2, forwardIndex2) = claimFreeSpace puzzle forwardIndex result1
        remainingFile = { file & freeTrail: 0, size: file.size - fillFile.size }
        consumeFreeSpace puzzle forwardIndex2 result2 remainingFile newFree
    else
        remainingSpace = if spaceToFill > fillFile.size then spaceToFill - fillFile.size else 0
        (remainingSpace, result1, forwardIndex)

expect
    actual = compactDisk (parsePuzzle "12345")
    actual
    == [
        { index: 0, size: 1, freeTrail: 0 },
        { index: 2, size: 2, freeTrail: 0 },
        { index: 1, size: 3, freeTrail: 0 },
        { index: 2, size: 3, freeTrail: 0 },
    ]

diskChecksum : Puzzle -> U64
diskChecksum = \puzzle ->
    List.walk
        puzzle
        { blockPosition: 0, checksum: 0 }
        \{ blockPosition, checksum }, { index: fileIndex, size: fileSize } ->
            endBlockPosition = blockPosition + fileSize
            partial =
                List.range { start: At blockPosition, end: Before endBlockPosition }
                |> List.walk 0 \sum, pos -> sum + (pos * fileIndex)
            {
                blockPosition: endBlockPosition,
                checksum: checksum + partial,
            }
    |> .checksum

expect
    actual = diskChecksum (compactDisk (parsePuzzle "12345"))
    actual == 60
