app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br",
    parser: "https://github.com/lukewilliamboswell/roc-parser/releases/download/0.9.0/w8YKp2YAgQt5REYk912HfKAHBjcXsrnvtjI0CBzoAT4.tar.br",
}

import pf.Stdout
import parser.Parser exposing [const, keep, skip, oneOf, Parser, sepBy]
import parser.String exposing [parseStr, string, digits]

main =
    Stdout.line! "parsed: $(Inspect.toStr (parseGame example))"

example = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"

Requirement : [Green U64, Red U64, Blue U64]
RequirementSet : List Requirement
Game : { id : U64, requirements : List RequirementSet }

parseGame : Str -> Result Game [ParsingError]
parseGame = \s ->
    green = const Green |> keep digits |> skip (string " green")
    red = const Red |> keep digits |> skip (string " red")
    blue = const Blue |> keep digits |> skip (string " blue")

    requirementSet : Parser _ RequirementSet
    requirementSet = (oneOf [green, red, blue]) |> sepBy (string ", ")

    requirements : Parser _ (List RequirementSet)
    requirements = requirementSet |> sepBy (string "; ")

    game : Parser _ Game
    game =
        const (\id -> \r -> { id, requirements: r })
        |> skip (string "Game ")
        |> keep digits
        |> skip (string ": ")
        |> keep requirements

    when parseStr game s is
        Ok g -> Ok g
        Err (ParsingFailure _) | Err (ParsingIncomplete _) -> Err ParsingError
