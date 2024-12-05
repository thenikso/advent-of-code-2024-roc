app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br" }

import pf.Stdout
import pf.File

main =
    input = File.readUtf8! "data/inputs/05.txt"
    Stdout.line! "part 1: $(Inspect.toStr (part1 input))" # 7198
    Stdout.line! "part 2: $(Inspect.toStr (part2 input))" # 4230

example =
    """
    47|53
    97|13
    97|61
    97|47
    75|29
    61|13
    75|53
    29|13
    97|29
    53|29
    61|53
    97|53
    61|29
    47|13
    75|47
    97|75
    47|61
    75|61
    47|29
    75|13
    53|13

    75,47,61,53,29
    97,61,53,29,13
    75,29,13
    75,97,47,61,53
    61,13,29
    97,13,75,29,47
    """

# Solutions

part1 = \input ->
    { rules, updates } = parsePuzzle? input
    updates
    |> List.keepOks \update -> correctUpdateMiddleValue update rules
    |> List.walk 0 \a, b -> a + b
    |> Ok

expect part1 example == Ok 143

part2 = \input ->
    { rules, updates } = parsePuzzle? input

    solveUntilCorrect = \update ->
        when correctUpdateMiddleValue update rules is
            Ok v -> v
            Err [] -> 0 # not sure why these are produced
            Err corrected -> solveUntilCorrect corrected

    updates
    |> List.walk 0 \sum, update ->
        when correctUpdateMiddleValue update rules is
            Ok _ -> sum
            Err corrected -> sum + (solveUntilCorrect corrected)
    |> Ok

expect part2 example == Ok 123

# Utils

Rules : Dict U64 (List U64)
Update : List U64

parsePuzzle : Str -> Result { rules : Rules, updates : List Update } [InvalidPuzzle]
parsePuzzle = \text ->
    (rulesLines, updatesLines) =
        (
            when Str.splitOn text "\n\n" is
                [a, b] ->
                    Ok (
                        Str.splitOn a "\n",
                        Str.splitOn b "\n",
                    )

                _ -> Err InvalidPuzzle
        )?

    rules =
        (
            rulesLines
                |> List.walkTry (Dict.withCapacity (List.len rulesLines)) \dict, line ->
                    (before, after) =
                        (
                            when Str.splitOn line "|" is
                                [a, b] ->
                                    Result.map2 (Str.toU64 a) (Str.toU64 b) \x, y -> (x, y)
                                    |> Result.mapErr \_ -> InvalidPuzzle

                                _ -> Err InvalidPuzzle
                        )?

                    Ok
                        (
                            Dict.update dict before \elem ->
                                when elem is
                                    Err Missing -> Ok [after]
                                    Ok arr -> Ok (List.append arr after)
                        )
        )?

    updates =
        updatesLines
        |> List.map \line ->
            line
            |> Str.splitOn ","
            |> List.keepOks Str.toU64

    Ok { rules, updates }

testPuzzle =
    parsePuzzle
        """
        1|2
        3|4
        1|4

        1,2,3
        3,4
        """
    |> Result.withDefault ({ rules: Dict.empty {}, updates: [] })

expect
    (Dict.get testPuzzle.rules 1 == Ok [2, 4])
    && (testPuzzle.updates == [[1, 2, 3], [3, 4]])

correctUpdateMiddleValue : Update, Rules -> Result U64 Update
correctUpdateMiddleValue = \update, rules ->
    updateMidpoint = (List.len update) // 2
    update
    |> List.walkWithIndexUntil
        { before: [], res: Err [] }
        \state, value, index ->
            res = if index == updateMidpoint then Ok value else state.res
            when Dict.get rules value is
                Err _ -> Continue { res, before: List.append state.before value }
                Ok rule ->
                    when List.findFirstIndex state.before \b -> List.contains rule b is
                        Ok errIndex ->
                            # TODO build corrected list
                            { before, others } = List.splitAt state.before errIndex
                            corrected =
                                before
                                |> List.append value
                                |> List.concat others
                                |> List.concat (update |> List.splitAt (index + 1) |> .others)
                            Break { state & res: Err corrected }

                        Err _ ->
                            Continue { res, before: List.append state.before value }
    |> .res

expect (correctUpdateMiddleValue [1, 2, 3] testPuzzle.rules) == Ok 2
expect (correctUpdateMiddleValue [2, 1, 3] testPuzzle.rules) == Err [1, 2, 3]
expect
    actual = correctUpdateMiddleValue [2, 4, 1, 3] testPuzzle.rules
    actual == Err [1, 2, 4, 3]
expect
    actual = correctUpdateMiddleValue [1, 2, 4, 3] testPuzzle.rules
    actual == Err [1, 2, 3, 4]
expect (correctUpdateMiddleValue [1, 2, 3, 4] testPuzzle.rules) == Ok 3
