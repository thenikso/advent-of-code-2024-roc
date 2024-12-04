app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br" }

import pf.Stdout
import pf.File

main =
    input = File.readUtf8! "data/inputs/04.txt"
    Stdout.line! "part 1: $(Inspect.toStr (part1 input))" # 2543
    Stdout.line! "part 2: $(Inspect.toStr (part2 input))" #

example =
    """
    MMMSXXMASM
    MSAMXMSMSA
    AMXSXMAAMM
    MSAMASMSMX
    XMASAMXAMM
    XXAMMXXAMA
    SMSMSASXSS
    SAXAMASAAA
    MAMMMXMMMM
    MXMXAXMASX
    """

# Solutions

part1 = \input ->
    search = "XMAS" |> Str.toUtf8
    searchLen = search |> List.len
    puzzle = parsePuzzle input
    puzzle
    |> List.walkWithIndex 0 \count, line, y ->
        List.walkWithIndex line 0 \lineCount, char, x ->
            if char == 'X' then
                waveCoordinates (x, y) searchLen
                |> List.map \wave ->
                    List.keepOks wave \coord -> get2D puzzle coord
                |> List.keepIf \word -> word == search
                |> List.len
                |> Num.add lineCount
            else
                lineCount
        + count

expect
    actual = part1 example
    actual == 18

part2 = \input -> None

expect part2 example == None

# Utils

Matrix2D a : List (List a)
Coordinate : (U64, U64)

parsePuzzle : Str -> Matrix2D U8
parsePuzzle = \text ->
    text
    |> Str.splitOn "\n"
    |> List.map Str.toUtf8
    |> List.dropIf List.isEmpty

expect parsePuzzle "XMM\nAXX\n" == [[88, 77, 77], [65, 88, 88]]

# Given an initial `Coordinate` drop point, produces a "wave" in a
# 2D matrix, returning a list of all the `Coordinate`s in the "wave front"
# up to a given cut off.
waveCoordinates : Coordinate, U64 -> Matrix2D Coordinate
waveCoordinates = \dropPoint, cutOff ->
    List.range { start: At 0, end: Before cutOff }
    |> List.walk [[], [], [], [], [], [], [], []] \state, depth ->
        empty = []
        List.mapWithIndex state \wave, dir ->
            # direction start from right and moves clockwise
            when dir is
                0 ->
                    List.append wave (dropPoint.0 + depth, dropPoint.1)

                1 ->
                    List.append wave (dropPoint.0 + depth, dropPoint.1 + depth)

                2 ->
                    List.append wave (dropPoint.0, dropPoint.1 + depth)

                3 if dropPoint.0 >= depth ->
                    List.append wave (dropPoint.0 - depth, dropPoint.1 + depth)

                4 if dropPoint.0 >= depth ->
                    List.append wave (dropPoint.0 - depth, dropPoint.1)

                5 if dropPoint.0 >= depth && dropPoint.1 >= depth ->
                    List.append wave (dropPoint.0 - depth, dropPoint.1 - depth)

                6 if dropPoint.1 >= depth ->
                    List.append wave (dropPoint.0, dropPoint.1 - depth)

                7 if dropPoint.1 >= depth ->
                    List.append wave (dropPoint.0 + depth, dropPoint.1 - depth)

                _ -> empty
    # Note: the indentation in this one was one level deeper producing
    # a strange logic bug difficult to discover.
    |> List.dropIf List.isEmpty

expect
    actual = waveCoordinates (1, 1) 2
    actual == [[(1, 1), (2, 1)], [(1, 1), (2, 2)], [(1, 1), (1, 2)], [(1, 1), (0, 2)], [(1, 1), (0, 1)], [(1, 1), (0, 0)], [(1, 1), (1, 0)], [(1, 1), (2, 0)]]

expect
    actual = waveCoordinates (0, 0) 2
    actual == [[(0, 0), (1, 0)], [(0, 0), (1, 1)], [(0, 0), (0, 1)]]

expect
    actual = waveCoordinates (1, 9) 4
    actual
    == [
        [(1, 9), (2, 9), (3, 9), (4, 9)],
        [(1, 9), (2, 10), (3, 11), (4, 12)],
        [(1, 9), (1, 10), (1, 11), (1, 12)],
        [(1, 9), (1, 8), (1, 7), (1, 6)],
        [(1, 9), (2, 8), (3, 7), (4, 6)],
    ]

get2D : Matrix2D a, Coordinate -> Result a _
get2D = \matrix, (x, y) ->
    List.get matrix y
    |> Result.try \row ->
        List.get row x

expect
    actual = get2D [[0, 1], [2, 3]] (0, 1)
    actual == Ok 2
