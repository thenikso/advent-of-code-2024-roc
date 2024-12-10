app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br",
    aoc: "./package/main.roc",
    array2d: "https://github.com/mulias/roc-array2d/releases/download/v0.3.1/2Jqajvxn36vRryyQBSluU6Fo6vVI5yNSYmcJcyaKp0Y.tar.br",
}

import pf.Stdout
import pf.File
import pf.Utc
import aoc.AoC {
    readfile: File.readUtf8,
    stdout: Stdout.write,
    time: \{} -> Utc.now {} |> Task.map Utc.toMillisSinceEpoch,
}
import array2d.Array2D exposing [Array2D]
import array2d.Index2D exposing [Index2D]

day = "10"

main =
    AoC.solve! day 1 part1 # 698
    AoC.solve! day 2 part2 #

example =
    """
    89010123
    78121874
    87430965
    96549874
    45678903
    32019012
    01329801
    10456732
    """

# Solutions

part1 = \input ->
    puzzle = parsePuzzle input
    puzzle
    |> findTrailheads
    |> List.walk 0 \sum, head ->
        sum + (trailScore puzzle head)
    |> Ok

expect part1 example == Ok 36

part2 = \input -> None

expect part2 example == None

# Utils

Puzzle : Array2D U8

parsePuzzle : Str -> Puzzle
parsePuzzle = \text ->
    text
    |> Str.trimEnd
    |> Str.splitOn "\n"
    |> List.map \line ->
        line
        |> Str.toUtf8
        |> List.map \c -> c - '0'
    |> Array2D.fromLists FitShortest

findTrailheads : Puzzle -> List Index2D
findTrailheads = \puzzle ->
    Array2D.walk puzzle (List.withCapacity 100) { direction: Forwards } \acc, height, index ->
        if height == 0 then
            List.append acc index
        else
            acc

expect
    actual = example |> parsePuzzle |> findTrailheads
    actual
    == [
        { col: 2, row: 0 },
        { col: 4, row: 0 },
        { col: 4, row: 2 },
        { col: 6, row: 4 },
        { col: 2, row: 5 },
        { col: 5, row: 5 },
        { col: 0, row: 6 },
        { col: 6, row: 6 },
        { col: 1, row: 7 },
    ]

crossCoords : Index2D -> List Index2D
crossCoords = \i ->
    res =
        List.withCapacity 4
        |> List.append { i & col: i.col + 1 }
        |> List.append { i & row: i.row + 1 }
    res1 =
        if i.col > 0 then
            List.append res { i & col: i.col - 1 }
        else
            res
    res2 =
        if i.row > 0 then
            List.append res1 { i & row: i.row - 1 }
        else
            res1
    res2

expect
    actual = crossCoords { col: 2, row: 0 }
    actual == [{ col: 3, row: 0 }, { col: 2, row: 1 }, { col: 1, row: 0 }]

trailScore : Puzzle, Index2D -> U64
trailScore = \puzzle, head ->
    List.range { start: After 0, end: At 9 }
    |> List.walkUntil [head] \trails, targetHeight ->
        if List.len trails == 0 then
            Break trails
        else
            nextHeads =
                trails
                |> List.map \h ->
                    h
                    |> crossCoords
                    |> List.keepIf \i ->
                        Array2D.get puzzle i == Ok targetHeight
                |> List.join
            Continue nextHeads
    |> Set.fromList
    |> Set.len

expect
    example1 =
        """
        0123
        1234
        8765
        9876
        """
    actual = example1 |> parsePuzzle |> trailScore { col: 0, row: 0 }
    actual == 1
expect example |> parsePuzzle |> trailScore { col: 2, row: 0 } == 5
