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
    AoC.solve! day 2 part2 # 7074031030636 too hight;

example =
    "2333133121414131402"

# Solutions

part1 = \input ->
    input
    |> parsePuzzle
    |> compactDisk
    |> diskChecksum
    |> Ok

expect
    actual = part1 example
    actual == Ok 1928

part2 = \input ->
    disk =
        input
        |> parsePuzzle
        |> packDisk
    #dbg (printDisk disk)
    disk
    |> diskChecksum
    |> Ok

expect
    actual = part2 example
    actual == Ok 2858

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
                backwardIndex: List.len puzzle - 1,
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
                consumeFreeSpace puzzle forwardIndex1 state.backwardIndex result1 file spaceToFill1
            # Next backward file
            newState = {
                result: result2,
                backwardIndex: state.backwardIndex - 1,
                forwardIndex: forwardIndex2,
                spaceToFill: spaceToFill2,
            }
            if forwardIndex2 >= state.backwardIndex then
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

consumeFreeSpace = \puzzle, forwardIndex, backwardIndex, result, file, spaceToFill ->
    fillFile =
        if forwardIndex == backwardIndex then
            { file & freeTrail: 0 }
        else
            { file & freeTrail: 0, size: Num.min spaceToFill file.size }
    result1 = List.append result fillFile
    if (file.size - fillFile.size) > 0 then
        (newFree, result2, forwardIndex2) = claimFreeSpace puzzle forwardIndex result1
        remainingFile = { file & freeTrail: 0, size: file.size - fillFile.size }
        consumeFreeSpace puzzle forwardIndex2 backwardIndex result2 remainingFile newFree
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
        \{ blockPosition, checksum }, { index: fileIndex, size: fileSize, freeTrail } ->
            endBlockPosition = blockPosition + fileSize
            partial =
                List.range { start: At blockPosition, end: Before endBlockPosition }
                |> List.walk 0 \sum, pos -> sum + (pos * fileIndex)
            {
                blockPosition: endBlockPosition + freeTrail,
                checksum: checksum + partial,
            }
    |> .checksum

expect
    actual = diskChecksum (compactDisk (parsePuzzle "12345"))
    actual == 60

strConcatN = \str, sub, n ->
    if n == 0 then
        str
    else
        strConcatN (Str.concat str sub) sub (n - 1)

printDisk : Puzzle -> Str
printDisk = \disk ->
    List.walk disk "" \acc, { index, size, freeTrail } ->
        strConcatN acc (Num.toStr index) size
        |> strConcatN "." freeTrail

expect printDisk (parsePuzzle "12345") == "0..111....22222"

packDisk = \disk ->
    diskLen = List.len disk
    disk
    |> List.walkBackwardsUntil
        {
            backwardIndex: diskLen - 1,
            result: disk,
        }
        \state, file ->
            if state.backwardIndex < 2 then
                Break state
            else
                split = listSplitBy state.result \forwardFile, index ->
                    index <= state.backwardIndex && forwardFile.freeTrail >= file.size
                when split.value is
                    Err _ -> Continue { state & backwardIndex: state.backwardIndex - 1 }
                    Ok ff ->
                        others = List.walkWithIndex split.others [] \acc, o, i ->
                            if o.index != file.index then
                                List.append acc o
                            else
                                when List.get acc (i - 1) is
                                    Ok p ->
                                        List.dropLast acc 1
                                        |> List.append { p & freeTrail: p.freeTrail + o.size + o.freeTrail }

                                    Err _ -> acc
                        Continue {
                            backwardIndex: state.backwardIndex - 1,
                            result: (
                                split.before
                                |> List.append { ff & freeTrail: 0 }
                                |> List.append { file & freeTrail: ff.freeTrail - file.size }
                                |> List.concat others
                            ),
                        }
    |> .result

    # TODO prova ricorsivo

expect
    actual = "14332" |> parsePuzzle |> packDisk |> printDisk
    actual == "022..111....."

listSplitBy : List a, (a, U64 -> Bool) -> { before : List a, value : Result a [NotFound], others : List a }
listSplitBy = \list, check ->
    (before, value, dropN) =
        List.walkWithIndexUntil list ([], Err NotFound, 0) \(bef, val, _), item, index ->
            if check item index then
                Break (bef, Ok item, index + 1)
            else
                Continue (List.append bef item, val, index + 1)
    {
        before,
        value,
        others: List.dropFirst list dropN,
    }

expect
    (listSplitBy [1, 2, 3, 4] \n, _ -> n == 3)
    == {
        before: [1, 2],
        value: Ok 3,
        others: [4],
    }
