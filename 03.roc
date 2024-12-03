app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.9.0/w8YKp2YAgQt5REYk912HfKAHBjcXsrnvtjI0CBzoAT4.tar.br",
}

import pf.Stdout
import pf.File
import parser.Parser exposing [Parser, const, keep, skip, many, chompUntil, alt]
import parser.String exposing [parseStr, string, digits, codeunit, anyThing, anyCodeunit]

main =
    input = File.readUtf8! "data/inputs/03.txt"
    Stdout.line! "part 1: $(Inspect.toStr (part1 input))" # 178794710
    Stdout.line! "part 2: $(Inspect.toStr (part2 input))" #

example =
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

# Solutions

part1 = \input ->
    parsePuzzle input
    |> List.map \inst ->
        when inst is
            Mul (a, b) -> a * b
            _ -> 0
    |> List.sum

expect part1 example == 161

part2 = \input -> None

expect part2 example == None

# Utils

Instruction : [Invalid, Mul (U64, U64)]

parsePuzzle : Str -> List Instruction
parsePuzzle = \text ->
    mul : Parser _ Instruction
    mul =
        const (\a -> \b -> Mul (a, b))
        |> skip (chompUntil 'm')
        |> skip (string "mul(")
        |> keep digits
        |> skip (codeunit ',')
        |> keep digits
        |> skip (codeunit ')')

    notMul : Parser _ Instruction
    notMul =
        const Invalid
        |> skip (anyCodeunit)

    prog : Parser _ (List Instruction)
    prog =
        alt mul notMul
        |> many
        |> skip anyThing

    when parseStr prog text is
        Ok r -> List.keepIf r \i -> i != Invalid
        Err _ -> []

expect
    actual = parsePuzzle example
    actual == [Mul (2, 4), Mul (5, 5), Mul (11, 8), Mul (8, 5)]
