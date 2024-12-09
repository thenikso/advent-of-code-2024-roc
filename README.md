# Advent of Code 2024 in Roc

Learning [Roc](https://www.roc-lang.org/) with [AoC 2024](https://adventofcode.com/2024).

## What I learned about Roc

I started by reading the [Roc tutorial](https://www.roc-lang.org/tutorial)
and prepared `template.roc` for the coming days.

### Day 1

I really like the `expect` keyword that let me test functions rigth there.
Had some issues with numbers in deciding which unsigned/integer to use.

Used `List.walk` a bunch of times.

### Day 2

I used the same technique to parse the input as yesterday.

Again I used `List.walk` for the main part, this time with a more complex state
variable.

I notice how the `when` and `if`s tend to increase the indentation quite a bit.

### Day 3

I learn how to use [`roc-parser`](https://github.com/lukewilliamboswell/roc-parser)
instead of regexp as I'd have done in Javascript.

The parser construction is very clean an I used a Roc-style data modeling
technique in creating a tag union to represent the possible instructions.

Once again, being able to test the functions directly in the same code file
came in handy. Also using [`dbg`](https://www.roc-lang.org/tutorial#dbg) is
really useful, much like one would use `console.log` in js.

### Day 4

Much more complex! I had to do a O2 as the naive solution but it works.

Fount out that the indentation when chaining with `|>` may become problematic
if the previous operation is too long.

```
aList
|> List.walk ...
    List.walk ...
    ...lots of code...
    |> List.dropIf ...
```

The last `List.dropIf` in this example works if it is indended or not but
the logit will change drastically. It's probably best to use intermidiate
variables in this case to avoid confusion.

This is an issue I often find with functional languages: one is tempted to
get too clever with the code (expecially function chaining) making it less readable.

Really used `dbg` this time that, together with `expect` is crucial for  debugging.

I like `when` clause guards.

## Day 5

Using `Dict`s! Very straight forward, `Dict.update` is quite usefult.
No way to make a literal Dict for test? Closest way would be to use `Dict.fromList`.

I've also used the `?` suguar to pass on a `Result` error and proceed with
the `Ok` value instead. Glat to see it also works with `when` expressions like:

```roc
result = (
  when something is
    [a, b] -> Ok a
    _ -> Err Invalid
)?
# `result` has the type of a, not Ok a because of the `?`
```

Ended the day by adding execution time to solutions by copying a package and
learning how to do create a `module` and `package`.

## Day 6

Using [`Array2D`](https://github.com/mulias/roc-array2d/tree/main) for this one.
This is also an occasion to try `Set`s.

Had some issues fixing a cryptinc type error inside a function. It turned out
that I was using an argument as one type (wrongly), which made the inference assume that
type for that argument, later I used as another type (the one I wanted it to be)
and the resulting error was quite cryptic. It would have helped if the compiler
said something like "I inferred this thing has this type from here".

## Day 7

Sometimes I feel the lack of a regular loop but it look like they may be
[coming](https://roc.zulipchat.com/#narrow/stream/304641-ideas/topic/.60for.60.20and.20.60var.60/near/471593157).

## Day 8

I'd have used variable shadowing, only mildly annoing but it can be error prone.
Luckly that should be [coming too](https://docs.google.com/document/d/1Ly5Cp_Z7dY8KLQkkDYZlGCldxQj4jLzZ0vIeB-F8lJI/edit?tab=t.0#heading=h.uw2tdxn2cvjs).

I was loosing it trying to do aritmethic with U64, just converted to I32 and
all is good now.

I could have used `Num.subWrap` but didn't know it existed!

There could probably have been a use for a `scan` or sliding window like operation
as [discussed in the forums](https://roc.zulipchat.com/#narrow/channel/304641-ideas/topic/List.2Escan).

## Day 9

Working with recursion and `List.walk` is so exausting instead of using a loop xD
