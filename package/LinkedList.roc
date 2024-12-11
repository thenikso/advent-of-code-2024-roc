module [
    LinkedList,
    empty,
    fromList,
    walk,
    len,
    toList,
]

LinkedList elem := [Cons elem (LinkedList elem), Nil]

empty = \{} ->
    Nil

fromList = \list ->
    List.walkBackwards list (@LinkedList Nil) \acc, item ->
        @LinkedList (Cons item acc)

walk : LinkedList elem, state, (state, elem -> state) -> state
walk = \@LinkedList listHead, state, transform ->
    when listHead is
        Nil -> state
        Cons elem rest ->
            walk rest (transform state elem) transform

len = \listHead ->
    walk listHead 0 \sum, _ -> sum + 1

toList : LinkedList elem -> List elem
toList = \listHead ->
    walk listHead (List.withCapacity (len listHead)) \acc, elem ->
        List.append acc elem
