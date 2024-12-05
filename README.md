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
