# Experimental!
Lines ← ⊕□⍜▽¯:\+.=, @\n
Aeq ← ⍤⊃($"expected _ got _")≍

Parse ← ≡°□Lines

FindSymbols ← ¬∊: "0123456789."

Directions ← [1_¯1 0_1 1_1 0_¯1 1_0¯1_¯1 ¯1_0 ¯1_1]
Neighbors ← /↥≡(⬚0↻) Directions ¤

KeepNumbers ← ▽⊃(⊜/↥|⊜⋕;:)∊:"0123456789",

PartOne ← (
  Parse
  FindSymbols .
  Neighbors
  ⬚0≡KeepNumbers
  /+♭
)

FindGears ← =@*
SplitMask ← ≡(⍜⊡⋅1)⊙¤⊃(⊚|∵⋅0)
KeepAllNumbers ← /⊐⊂ ≡(□KeepNumbers)
GearRatio ← (⋅0|/×) =2 ⧻.

PartTwo ← (
  Parse
  FindGears .
  SplitMask
  ≡(GearRatio KeepAllNumbers Neighbors)⊙¤
  /+
)

---

$ 467..114..
$ ...*......
$ ..35..633.
$ ......#...
$ 617*......
$ .....+.58.
$ ..592.....
$ ......755.
$ ...$.*....
$ .664.598..

Aeq 4361 PartOne .
Aeq 467835 PartTwo

$ ....
$ ....
$ .*..
$ .12.
$ ....

Parse

[0_0_0_0
 0_0_0_0
 0_1_0_0
 0_0_0_0
 0_0_0_0]

Aeq ⊙FindSymbols

[0_0_0_0
 0_0_0_0
 0_1_0_0
 0_0_0_0
 0_0_0_0]

[0_0_0_0
 1_1_1_0
 1_0_1_0
 1_1_1_0
 0_0_0_0]

Aeq ⊙Neighbors

[1_0_0_0
 0_0_0_0
 0_0_0_0
 0_0_0_0]

[0_1_0_0
 1_1_0_0
 0_0_0_0
 0_0_0_0]

Aeq ⊙Neighbors

Aeq [12] KeepNumbers 1_1_1_0_0_0_0 $ .12.34.

$ .45.
$ 3.7.
$ .*..
$ .12.
$ ....

Aeq 22 PartOne

Aeq 20 GearRatio 5_4
Aeq 0 GearRatio [5]

$ .45*
$ ..7.
$ .*..
$ .12.
$ .*..

Aeq 399 PartTwo

&p "Tests OK"

---

Aeq 535351 PartOne &fras "day3.txt"
Aeq 87287096 PartTwo &fras "day3.txt"
