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

day = "07"

main =
    AoC.solve! day 1 part1 # 3598800864292
    AoC.solve! day 2 part2 # 340362529351427

example =
    """
    190: 10 19
    3267: 81 40 27
    83: 17 5
    156: 15 6
    7290: 6 8 6 15
    161011: 16 10 13
    192: 17 8 14
    21037: 9 7 18 13
    292: 11 6 16 20
    """

# Solutions

part1 = \input ->
    puzzle = parsePuzzle? input
    valids =
        puzzle
        |> List.keepIf \(target, nums) ->
            len = List.len nums - 1
            ops = cartesianProduct [Add, Mul] len
            valid = List.walkUntil ops Bool.false \_, op ->
                res = applyOps nums op \a, o, b ->
                    n =
                        when o is
                            Add -> a + b
                            Mul -> a * b
                    if n > target then
                        Err Invalid
                    else
                        Ok n
                when res is
                    Ok n ->
                        if n == target then
                            Break Bool.true
                        else
                            Continue Bool.false

                    Err _ -> Continue Bool.false
            valid

    valids
    |> List.map \(target, _) -> target
    |> List.sum
    |> Ok

expect
    actual = part1 example
    actual == Ok 3749

# Using a different approach for part 2 after seeing other solutions
part2 = \input ->
    parsePuzzle? input
    |> List.keepIf \(target, nums) ->
        when nums is
            [first, .. as rest] ->
                isValidCalibration first rest target [
                    \a, b -> a + b,
                    \a, b -> a * b,
                    \a, b ->
                        ord = numOrder b
                        a * 10 * ord + b
                ]

            _ -> Bool.false
    |> List.map \(target, _) -> target
    |> List.sum
    |> Ok

expect
    actual = part2 example
    actual == Ok 11387

# Utils

Puzzle : List (U64, List U64)

parsePuzzle : Str -> Result Puzzle _
parsePuzzle = \text ->
    text
    |> Str.trimEnd
    |> Str.splitOn "\n"
    |> List.mapTry \line ->
        { before, after } = Str.splitFirst? line ": "
        value = Str.toU64? before
        nums = after |> Str.splitOn " " |> List.mapTry? Str.toU64
        Ok (value, nums)

expect
    actual = parsePuzzle
        """
        1: 2 3
        4: 5 6 7
        """
    actual == Ok [(1, [2, 3]), (4, [5, 6, 7])]

cartesianProduct : List a, U64 -> List (List a)
cartesianProduct = \items, k ->
    List.range { start: At 1, end: Before k }
    |> List.map \_ -> items
    |> List.walk (List.map items \i -> [i]) \acc, curr ->
        List.map acc \x ->
            List.map curr \y ->
                List.append x y
        |> List.join

expect
    actual = cartesianProduct ['A', 'B', 'C'] 2
    actual
    == [
        ['A', 'A'],
        ['A', 'B'],
        ['A', 'C'],
        ['B', 'A'],
        ['B', 'B'],
        ['B', 'C'],
        ['C', 'A'],
        ['C', 'B'],
        ['C', 'C'],
    ]

applyOps : List U64, List a, (U64, a, U64 -> Result U64 [Invalid]) -> Result U64 [Invalid]
applyOps = \nums, ops, apply ->
    if List.len nums != List.len ops + 1 then
        Err Invalid
    else
        List.walkWithIndexUntil ops (List.get nums 0 |> Result.mapErr \_ -> Invalid) \state, op, i ->
            when state is
                Err _ -> Break (Err Invalid)
                Ok a ->
                    when List.get nums (i + 1) is
                        Err _ -> Break (Err Invalid)
                        Ok b ->
                            Continue (apply a op b)

expect
    actual = applyOps [1, 2, 3] [Add, Add] \a, _op, b -> Ok (a + b)
    actual == Ok 6

isValidCalibration : U64, List U64, U64, List (U64, U64 -> U64) -> Bool
isValidCalibration = \current, nums, target, ops ->
    if current > target then
        Bool.false
    else
        List.walkUntil ops Bool.false \_, op ->
            when nums is
                [] -> Break (target == current)
                [first, .. as rest] ->
                    res = isValidCalibration
                        (op current first)
                        rest
                        target
                        ops
                    if res then
                        Break res
                    else
                        Continue res

expect
    actual = isValidCalibration 1 [2, 3] 9 [\a, b -> a + b, \a, b -> a * b]
    actual == Bool.true

numOrder = \num ->
    ord = \n, acc ->
        next = n // 10
        if next == 0 then
        acc
        else
            ord next (acc * 10)
    ord num 1

expect numOrder 123 == 100
