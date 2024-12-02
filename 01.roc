app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br" }

import pf.Stdout
# import pf.File
import "data/inputs/01.txt" as input : Str

main =
    # input =
    #    File.readUtf8 "data/inputs/01.txt" # |> Task.onErr \_ -> Task.ok "ciao" # task errors can be recovered like this with a default value
    #    |> Task.await! Task.ok # this is equivalent of using ! on the last task
    Stdout.line! "part 1: $(Inspect.toStr (part1 input))" # 2430334
    Stdout.line! "part 2: $(Inspect.toStr (part2 input))" # 28786472

example =
    """
    3   4
    4   3
    2   5
    1   3
    3   9
    3   3
    """

# Solutions

part1 = \text ->
    text
    |> inputToLists
    |> distances
    |> List.walk 0 Num.add

expect part1 example == 11

part2 = \text ->
    (left, right) = inputToLists text
    similarities (left, right)
    |> List.map2 left \s, l -> s * l
    |> List.sum

expect part2 example == 31

# Utils

inputToLists = \text ->
    text
    |> Str.splitOn "\n"
    |> List.map \l -> l
        |> Str.splitOn "   "
        |> List.keepOks Str.toU64
    |> transpose2

expect inputToLists example == ([3, 4, 2, 1, 3, 3], [4, 3, 5, 3, 9, 3])

distances = \(left, right) ->
    List.map2
        (List.sortAsc left)
        (List.sortAsc right)
        \l, r -> Num.absDiff l r

expect distances (inputToLists example) == [2, 1, 0, 1, 2, 5]

transpose2 : List (List a) -> (List a, List a)
transpose2 = \lists ->
    lists
    |> List.walk ([], []) \state, list ->
        when list is
            [first, last] -> (List.append state.0 first, List.append state.1 last)
            _ -> state

expect transpose2 [[1, 2], [3, 4]] == ([1, 3], [2, 4])

similarities = \(left, right) ->
    left
    |> List.walk [] \state, l ->
        List.append state (List.countIf right \r -> r == l)
    |> List.map Num.toU64
expect
    actual = similarities (inputToLists example)
    actual == [3, 1, 0, 0, 3, 3]
