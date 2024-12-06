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

day = "00"

main =
    AoC.solve! day 1 part1 #
    AoC.solve! day 2 part2 #

example =
    """
    """

# Solutions

part1 = \input -> None

expect part1 example == None

part2 = \input -> None

expect part2 example == None

# Utils
