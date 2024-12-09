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
    AoC.solve! day 2 part2 # 1277

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
        calculateAntinodes antennas puzzleShape makeOppositeAntinodes
        |> Set.union set
    |> Set.len
    |> Ok

expect part1 example == Ok 14

part2 = \input ->
    puzzle = parsePuzzle input
    puzzleShape = Array2D.shape puzzle
    antinodes =
        puzzle
        |> findAntennas
        |> Dict.walk (Set.empty {}) \set, _, antennas ->
            calculateAntinodes antennas puzzleShape \acc, (rows, cols), (ar, ac), (br, bc) ->
                rdiff = Num.absDiff br ar
                cdiff = ac - bc
                up =
                    List.map2
                        (List.range { start: At ar, end: At 0, step: -rdiff })
                        (
                            List.range {
                                start: At ac,
                                end: if cdiff <= 0 then At 0 else Before cols,
                                step: cdiff,
                            }
                        )
                        \r, c ->
                            fixr = if rdiff == 0 then ar else r
                            fixc = if cdiff == 0 then ac else c
                            toIndex2D fixr fixc
                acc1 = List.walk up acc Set.insert
                down =
                    List.map2
                        (List.range { start: At ar, end: Before rows, step: rdiff })
                        (
                            List.range {
                                start: At ac,
                                end: if cdiff > 0 then At 0 else Before cols,
                                step: -cdiff,
                            }
                        )
                        \r, c ->
                            fixr = if rdiff == 0 then ar else r
                            fixc = if cdiff == 0 then ac else c
                            toIndex2D fixr fixc
                List.walk down acc1 Set.insert
            |> Set.union set
    # solution = Set.walk antinodes puzzle \acc, antinode ->
    #    Array2D.update acc antinode \node ->
    #        when node is
    #            Empty -> Antinode
    #            a -> a
    # dbg (Str.concat "\n" (printPuzzle solution))
    Ok (Set.len antinodes)

expect
    actual = part2 example
    actual == Ok 34

# Utils

Node : [Empty, Antenna U8, Antinode]
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
                '#' -> Antinode
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
                Antinode -> res
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

calculateAntinodes : List Index2D, Shape2D, (Set Index2D, (I32, I32), (I32, I32), (I32, I32) -> Set Index2D) -> Set Index2D
calculateAntinodes = \antennas, mapShape, makeAntinodes ->
    shape = (Num.toI32 mapShape.rows, Num.toI32 mapShape.cols)
    List.walk
        antennas
        (
            List.dropFirst antennas 1,
            Set.withCapacity (List.len antennas * 2),
        )
        \(others, set), aIndex ->
            a = (Num.toI32 aIndex.row, Num.toI32 aIndex.col)
            updatedSet = List.walk others set \partial, bIndex ->
                b = (Num.toI32 bIndex.row, Num.toI32 bIndex.col)
                makeAntinodes partial shape a b
            (List.dropFirst others 1, updatedSet)
    |> .1

toIndex2D : I32, I32 -> Index2D
toIndex2D = \r, c ->
    { row: Num.toU64 r, col: Num.toU64 c }

makeOppositeAntinodes = \acc, (rows, cols), (ar, ac), (br, bc) ->
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
    acc1 =
        if aac >= 0 && aac < cols && aar >= 0 && aar < rows then
            Set.insert acc (toIndex2D aar aac)
        else
            acc
    if bac >= 0 && bac < cols && bar >= 0 && bar < rows then
        Set.insert acc1 (toIndex2D bar bac)
    else
        acc1

expect
    actual = calculateAntinodes [{ row: 3, col: 4 }, { row: 5, col: 5 }] { rows: 10, cols: 10 } makeOppositeAntinodes
    actual == Set.fromList [{ row: 1, col: 3 }, { row: 7, col: 6 }]

printPuzzle : Puzzle -> Str
printPuzzle = \puzzle ->
    shape = Array2D.shape puzzle
    Array2D.walk puzzle "" { direction: Forwards } \acc, node, index ->
        res =
            when node is
                Empty -> Str.concat acc "."
                Antinode -> Str.concat acc "#"
                Antenna f ->
                    when Str.fromUtf8 [f] is
                        Ok s -> Str.concat acc s
                        Err _ -> Str.concat acc "?"
        if index.col + 1 == shape.cols && index.row + 1 != shape.rows then
            Str.concat res "\n"
        else
            res

expect
    actual = printPuzzle (parsePuzzle example)
    actual == example
