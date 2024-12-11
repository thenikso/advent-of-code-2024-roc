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

day = "11"

main =
    AoC.solve! day 1 part1 # 203953
    AoC.solve! day 2 part2 #

example =
    "125 17"

# Solutions

part1 = \input ->
    input
    |> parsePuzzle?
    |> blinkN 25
    |> List.len
    |> Ok

expect part1 example == Ok 55312

part2 = \input -> None

expect part2 example == None

# Utils

Puzzle : List U64

parsePuzzle : Str -> Result Puzzle _
parsePuzzle = \text ->
    text
    |> Str.trimEnd
    |> Str.splitOn " "
    |> List.mapTry Str.toU64

expect
    actual = example |> parsePuzzle
    actual == Ok [125, 17]

digitsLen : Int * -> U64
digitsLen = \num ->
    rec = \acc, n ->
        next = n // 10
        if next == 0 then acc else rec (acc + 1) next
    rec 1 num

expect digitsLen 1234 == 4

blinkOnce : Puzzle -> Puzzle
blinkOnce = \puzzle ->
    List.walk
        puzzle
        (List.withCapacity (List.len puzzle * 2)) # lol
        \acc, stone ->
            if stone == 0 then
                List.append acc 1
            else
                dc = digitsLen stone
                if dc % 2 == 0 then
                    order = Num.powInt 10 (dc // 2)
                    a = stone // order
                    acc1 = List.append acc a
                    b = stone - (a * order)
                    List.append acc1 b
                else
                    List.append acc (stone * 2024)

expect blinkOnce [125, 17] == [253000, 1, 7]

blinkN = \puzzle, n ->
    if n == 0 then
        puzzle
    else
        blinkN (blinkOnce puzzle) (n - 1)

expect blinkN [125, 17] 3 == [512072, 1, 20, 24, 28676032]
