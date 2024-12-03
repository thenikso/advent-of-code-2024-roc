# Advent of Code 2024 in Roc

Learning [Roc](https://www.roc-lang.org/) with [AoC 2024](https://adventofcode.com/2024).

## What I learned

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
