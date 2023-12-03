# Experimental!
Lines ← &i "tools.ua" "Lines"
Aeq ← ⍤⊃($"expected _ got _")≍

Parse ← ≡⊔Lines

FindSymbols ← ¬∊: "0123456789."
FindGears ← =@*

Grow ← ≡(⊂0⊂:0)⬚0⊂:0⬚0⊂0
UnGrow ← ≡(↘2↻¯1)↘2↻¯1
Grow ← setund(Grow|Grow|UnGrow)

Neighbors ← /↥≡(⍜(⊙Grow)↻) [
  [¯1 ¯1] [¯1 0] [¯1 1]
  [0 ¯1] [1 0]
  [1 ¯1] [0 1] [1 1]] ¤

KeepNumbers ← ▽⊃(⊜/↥|⊜parse;:)∊:"0123456789",

PartOne ← /+♭⬚0≡KeepNumbers Neighbors FindSymbols .Parse

SplitMask ← ≡(⍜⊡⋅1)⊙¤⊃(⊚|∵⋅0)
KeepAllNumbers ← /⊐⊂⊐≡KeepNumbers
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

[0_0_0_0_0_0
 0_1_0_0_0_0
 0_0_0_0_0_0
 0_0_0_0_0_0
 0_0_0_0_0_0
 0_0_0_0_0_0]

Aeq ⊙Grow ,,

Aeq ⊙UnGrow :

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

&p PartOne &fras "day3.txt"
&p PartTwo &fras "day3.txt"
