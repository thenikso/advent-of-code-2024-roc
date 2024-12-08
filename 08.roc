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
import array2d.Shape2D exposing [Shape2D]

day = "08"

main =
    AoC.solve! day 1 part1 # 394
    AoC.solve! day 2 part2 #

example =
    """
    ............
    ........0...
    .....0......
    .......0....
    ....0.......
    ......A.....
    ............
    ............
    ........A...
    .........A..
    ............
    ............
    """

# Solutions

part1 = \input ->
    puzzle = parsePuzzle input
    puzzleShape = Array2D.shape puzzle
    puzzle
    |> findAntennas
    |> Dict.walk (Set.empty {}) \set, _, antennas ->
        calculateAntinodes antennas puzzleShape
        |> Set.union set
    |> Set.len
    |> Ok

expect part1 example == Ok 14

part2 = \input -> None

expect part2 example == None

# Utils

Node : [Empty, Antenna U8]
Puzzle : Array2D Node

parsePuzzle : Str -> Puzzle
parsePuzzle = \text ->
    text
    |> Str.trimEnd
    |> Str.splitOn "\n"
    |> List.map \line ->
        line
        |> Str.toUtf8
        |> List.map \c ->
            when c is
                '.' -> Empty
                f -> Antenna f
    |> Array2D.fromLists FitShortest

expect parsePuzzle example |> Array2D.get { row: 1, col: 8 } == Ok (Antenna '0')

findAntennas : Puzzle -> Dict U8 (List Index2D)
findAntennas = \puzzle ->
    Array2D.walk
        puzzle
        (Dict.withCapacity 100)
        { direction: Forwards }
        \res, node, index ->
            when node is
                Empty -> res
                Antenna f ->
                    Dict.update res f \maybeList ->
                        when maybeList is
                            Err _ -> Ok [index]
                            Ok list -> Ok (List.append list index)

expect
    puzzle = parsePuzzle
        """
        ..0
        0A.
        """
    actual = findAntennas puzzle
    actual
    == Dict.fromList [
        ('0', [{ row: 0, col: 2 }, { row: 1, col: 0 }]),
        ('A', [{ row: 1, col: 1 }]),
    ]

calculateAntinodes : List Index2D, Shape2D -> Set Index2D
calculateAntinodes = \antennas, mapShape ->
    rows = Num.toI32 mapShape.rows
    cols = Num.toI32 mapShape.cols
    List.walk
        antennas
        (
            List.dropFirst antennas 1,
            Set.withCapacity (List.len antennas * 2),
        )
        \(others, set), a ->
            ac = Num.toI32 a.col
            ar = Num.toI32 a.row
            updatedSet = List.walk others set \partial, b ->
                bc = Num.toI32 b.col
                br = Num.toI32 b.row
                (aac, bac) =
                    if ac <= bc then
                        cd = bc - ac
                        (ac - cd, bc + cd)
                    else
                        cd = ac - bc
                        (ac + cd, bc - cd)
                (aar, bar) =
                    if ar <= br then
                        rd = br - ar
                        (ar - rd, br + rd)
                    else
                        rd = ar - br
                        (ar + rd, br - rd)
                s1 =
                    if aac >= 0 && aac < cols && aar >= 0 && aar < rows then
                        Set.insert partial { row: Num.toU64 aar, col: Num.toU64 aac }
                    else
                        partial
                if bac >= 0 && bac < cols && bar >= 0 && bar < rows then
                    Set.insert s1 { row: Num.toU64 bar, col: Num.toU64 bac }
                else
                    s1
            (List.dropFirst others 1, updatedSet)
    |> .1

expect
    actual = calculateAntinodes [{ row: 3, col: 4 }, { row: 5, col: 5 }] { rows: 10, cols: 10 }
    actual == Set.fromList [{ row: 1, col: 3 }, { row: 7, col: 6 }]
