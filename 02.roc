app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br" }

import pf.Stdout
import pf.File

main =
    input = File.readUtf8! "data/inputs/02.txt"
    Stdout.line! "part 1: $(Inspect.toStr (part1 input))" # 578 (had to exclude diff == 0), 565 (had to trim last empty line of file), 564 !
    Stdout.line! "part 2: $(Inspect.toStr (part2 input))" # 587 (low; trying to dumpen errors at 0 index), 590 (low; also try to dampen at index + 1), 604 !

example =
    """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    """

# Solutions

part1 = \input ->
    input
    |> parsePuzzle
    |> List.dropIf \list -> isReportSafe list != Safe
    |> List.len

expect part1 example == 2

part2 = \input ->
    input
    |> parsePuzzle
    |> List.dropIf \list ->
        when isReportSafe list is
            Safe -> Bool.false
            UnsafeAt index ->
                if isReportSafe (List.dropAt list (index - 1)) == Safe || isReportSafe (List.dropAt list index) == Safe || isReportSafe (List.dropAt list 0) == Safe then
                    Bool.false
                else
                    Bool.true
    |> List.len

expect part2 example == 4

# Utils

parsePuzzle = \text ->
    text
    |> Str.splitOn "\n"
    |> List.map \line ->
        line
        |> Str.splitOn " "
        |> List.keepOks Str.toI32
    |> List.dropIf List.isEmpty

expect parsePuzzle example |> List.first == Ok ([7, 6, 4, 2, 1])

isReportSafe : List (Num *) -> [Safe, UnsafeAt U64]
isReportSafe = \report ->
    report
    |> List.walkWithIndexUntil
        {
            prevLevel: None,
            diffNegative: None,
            safe: Safe,
        }
        \state, level, index ->
            when state.prevLevel is
                None -> Continue { state & prevLevel: Some level }
                Some otherLevel ->
                    diff = level - otherLevel
                    if Num.abs diff > 3 || diff == 0 then
                        Break { state & safe: UnsafeAt index }
                    else
                        negative = Num.isNegative diff
                        when state.diffNegative is
                            None -> Continue { state & diffNegative: Some negative, prevLevel: Some level }
                            Some decreasing ->
                                if decreasing != negative then
                                    Break { state & safe: UnsafeAt index }
                                else
                                    Continue { state & prevLevel: Some level }
    |> .safe

expect isReportSafe [7, 6, 4, 2, 1] == Safe
expect isReportSafe [1, 2, 7, 8, 9] == UnsafeAt 2
expect isReportSafe [1, 3, 6, 7, 6] == UnsafeAt 4
expect isReportSafe [1, 2, 3, 4, 4] == UnsafeAt 4
expect isReportSafe [1, 3, 2, 4, 5] == UnsafeAt 2
expect isReportSafe [8, 6, 4, 4, 1] == UnsafeAt 3
expect isReportSafe [7, 2, 3, 4, 5] == UnsafeAt 1
# expect isReportSafe [3, 4, 3, 2, 1] == UnsafeAt 0
expect isReportSafe [1, 2, 3, 4, 9] == UnsafeAt 4
