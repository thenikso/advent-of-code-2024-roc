# this is the module header
# app stands for application module
app [main] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.17.0/lZFLstMUCUvd5bjnnpYromZJXkQUrdhbva4xdBInicE.tar.br" }

# tutorial: https://www.roc-lang.org/tutorial
# builtins docs: https://www.roc-lang.org/builtins/
# base cli docs: https://www.roc-lang.org/packages/basic-cli/

import pf.Stdout

birds = 3

iguanas = 2

total = addAndStringify birds iguanas

# run with `roc dev main.roc`
main =
    Stdout.line! "There are $(total) animals."
    Stdout.line! "Color is $(stoplightStr Green)."
    Stdout.line! "Names: $(listTest)."
    Stdout.line! "Letter is $(getLetter "2" |> Result.withDefault "")."

addAndStringify = \num1, num2 ->
    sum = num1 + num2

    # this is to debug stuff. it can have any number or args, best with tuples
    dbg ("sum is", sum)

    if sum == 0 then
        "no"
    else
        Num.toStr sum

# example of pattern matching and tag
stoplightStr = \stoplightColor ->
    when stoplightColor is
        Red -> "red"
        Green | Yellow -> "not red"
        Custom description -> description

# Booleans are with Bool.true not `true`

# Lists are used like this
# note that |> will replace the first argument of a function
listTest =
    ["Sam", "Lee", "Ari"]
    |> List.append "Jess"
    |> List.map \n -> Str.concat n "!"
    |> Str.joinWith ", "

# shorthand for Result.try is `?` to run a function if the result is ok
getLetter : Str -> Result Str [OutOfBounds, InvalidNumStr]
getLetter = \indexStr ->
    index = Str.toU64? indexStr # equivalent to Result.try (Str.toU64 indexStr) ...
    List.get ["a", "b", "c", "d"] index

# testing, execute with `roc test main.roc`
expect getLetter "1" == Ok "b"
# expect can also be used as a soft assert

# example of List.walk
#List.walk [1, 2, 3, 4, 5] { evens: [], odds: [] } \state, elem ->
#    if Num.isEven elem then
#        { state & evens: List.append state.evens elem }
#    else
#        { state & odds: List.append state.odds elem }
## returns { evens: [2, 4], odds: [1, 3, 5] }

# list pattern matching
#when myList is
#    [] -> 0 # the list is empty
#    [Foo, ..] -> 1 # it starts with a Foo tag
#    [_, ..] -> 2 # it contains at least one element, which we ignore
#    [Foo, Bar, ..] -> 3 # it starts with a Foo tag followed by a Bar tag
#    [Foo, Bar, Baz] -> 4 # it has exactly 3 elements: Foo, Bar, and Baz
#    [Foo, a, ..] -> 5 # its first element is Foo, and its second we name `a`
#    [Ok a, ..] -> 6 # it starts with an Ok containing a payload named `a`
#    [.., Foo] -> 7 # it ends with a Foo tag
#    [A, B, .., C, D] -> 8 # it has certain elements at the beginning and end
#    [head, .. as tail] -> 9 # destructure a list into a first element (head) and the rest (tail)


# opaque types

# to define an opaque type use := (just = is for type alias)
#Username := Str

#fromStr : Str -> Username
#fromStr = \str ->
#    @Username str

#toStr : Username -> Str
#toStr = \@Username str ->
#    str

# `Username` can be used as `@Username` only in this module. can be used to skip checks later on like `NonEmptyList`

# Default values in record fields
# intended for configuration, not for data modelling
#table :
#    {
#        height : U64,
#        width : U64,
#        title ? Str,
#        description ? Str,
#    }
#    -> Table
#table = \{ height, width, title ? "oak", description ? "a wooden table" } -> ...

# how to crash
#answer : Str
#answer =
#    when Str.fromUtf8 definitelyValidUtf8 is
#        Ok str -> str
#        Err _ -> crash "This should never happen!"

# debug a roc value
# use `Inspect.toStr a` to inspect any Inpect type
