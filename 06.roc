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

day = "06"

main =
    AoC.solve! day 1 part1 # 4789
    AoC.solve! day 2 part2 #

example =
    """
    ....#.....
    .........#
    ..........
    ..#.......
    .......#..
    ..........
    .#..^.....
    ........#.
    #.........
    ......#...
    """

# Solutions

part1 = \input ->
    puzzle = parsePuzzle? input
    guard = findGuard? puzzle
    { rows, cols } = Array2D.shape puzzle
    visited = Set.withCapacity (rows * cols)
    keepWalking = \(state, g) ->
        when walkToObstacle puzzle state g is
            Ok res -> keepWalking res
            Err (Exits last) -> Set.len last

    Ok (keepWalking (visited, guard))

expect
    actual = part1 example
    actual == Ok 41

part2 = \input -> None

expect part2 example == None

# Utils

Direction : [Up, Left, Right, Down]
Position : [Empty, Obstruct, Guard Direction]
Puzzle : Array2D Position

parsePuzzle : Str -> Result Puzzle [InvalidChar U8]
parsePuzzle = \text ->
    lists =
        text
        |> Str.trimEnd
        |> Str.splitOn "\n"
        |> List.mapTry \line ->
            line
            |> Str.toUtf8
            |> List.mapTry \char ->
                when char is
                    '.' -> Ok (Empty)
                    '#' -> Ok (Obstruct)
                    '^' -> Ok (Guard Up)
                    '>' -> Ok (Guard Right)
                    '<' -> Ok (Guard Left)
                    'V' -> Ok (Guard Down)
                    c -> Err (InvalidChar c)
        |> try
    Ok (Array2D.fromLists lists FitShortest)

testPuzzle = parsePuzzle
    """
    .#
    ^.
    """

expect
    when testPuzzle is
        Err _ -> Bool.false
        Ok actual ->
            Array2D.get actual { row: 0, col: 0 }
            == Ok Empty
            &&
            Array2D.get actual { row: 0, col: 1 }
            == Ok Obstruct
            &&
            Array2D.get actual { row: 1, col: 0 }
            == Ok (Guard Up)
            &&
            Array2D.get actual { row: 1, col: 1 }
            == Ok Empty

GuardLocation : { position : Index2D, direction : Direction }

findGuard : Puzzle -> Result GuardLocation [NotFound]
findGuard = \puzzle ->
    Array2D.walkUntil puzzle (Err NotFound) { direction: Forwards } \state, loc, index ->
        when loc is
            Guard dir -> Break (Ok { position: index, direction: dir })
            _ -> Continue state

expect
    when testPuzzle is
        Err _ -> Bool.false
        Ok puzzle ->
            actual = findGuard puzzle
            actual == Ok { position: { row: 1, col: 0 }, direction: Up }

walkToObstacle : Puzzle, Set Index2D, GuardLocation -> Result (Set Index2D, GuardLocation) [Exits (Set Index2D)]
walkToObstacle = \puzzle, visited, guard ->
    guardExited : Index2D -> Bool
    guardExited = \index ->
        if guard.direction == Up || guard.direction == Down then
            guard.position.col != index.col
        else
            guard.position.row != index.row

    Array2D.walkUntil
        puzzle
        (Ok (visited, guard))
        {
            direction: if guard.direction == Up || guard.direction == Left then Backwards else Forwards,
            orientation: if guard.direction == Up || guard.direction == Down then Cols else Rows,
            start: guard.position,
        }
        \state, loc, index ->
            when state is
                Err _ -> Break state
                Ok s ->
                    if guardExited index then
                        Break (Err (Exits s.0))
                    else
                        when loc is
                            Obstruct ->
                                Break
                                    (
                                        Ok (
                                            s.0,
                                            {
                                                position: s.1.position,
                                                direction:
                                                when s.1.direction is
                                                    Up -> Right
                                                    Right -> Down
                                                    Down -> Left
                                                    Left -> Up,
                                            },
                                        )
                                    )

                            _ ->
                                Continue
                                    (
                                        Ok (
                                            Set.insert s.0 index,
                                            { position: index, direction: s.1.direction },
                                        )
                                    )

expect
    actual =
        parsePuzzle example
        |> Result.try \puzzle ->
            findGuard puzzle
            |> Result.try \guard ->
                (visited, pos) = walkToObstacle? puzzle (Set.empty {}) guard
                Ok (Set.len visited, pos)

    actual
    == Ok (
        6,
        { position: { row: 1, col: 4 }, direction: Right },
    )

expect
    actual =
        parsePuzzle example
        |> Result.try \puzzle ->
            (visited, pos) = walkToObstacle?
                puzzle
                (Set.empty {})
                { position: { row: 4, col: 1 }, direction: Up }
            Ok (Set.len visited, pos)
        |> Result.mapErr \err ->
            when err is
                Exits set -> Set.len set
                _ -> 0

    actual == Err 5
