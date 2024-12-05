module { readfile, stdout, time } -> [solve]

solve : Str, U64, (Str -> a) -> Task {} _ where a implements Inspect
solve = \day, part, solver ->
    input = readfile! "data/inputs/$(day).txt"
    startTime = time! {}
    result = solver input
    endTime = time! {}
    resultTimeStr = if (endTime - startTime) < 1 then "<1" else Num.toStr (endTime - startTime)
    stdout! "Day $(day) part $(Num.toStr part): $(Inspect.toStr result) [$(resultTimeStr)ms]\n"
