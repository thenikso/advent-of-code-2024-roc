app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br" }

import pf.Stdout
import pf.File

main =
    input = File.readUtf8! "data/inputs/01.txt"
    Stdout.line! "part 1: $(Inspect.toStr (part1 input))" #
    Stdout.line! "part 2: $(Inspect.toStr (part2 input))" #

example =
    """
    """

# Solutions

part1 = \input -> None

expect part1 example == None

part2 = \input -> None

expect part2 example == None

# Utils
