# Experimental!

Parse ← ⊜(≠@#)≠@\n.
Directions ← [0_1 ¯1_0 0_¯1 1_0]

Step ← (
  ⊝☇1≡(+Directions ¤) # get unique neighbors
  ⊃(
    ⬚0⊡
  | /↧⍉≥¤0_0
  | ⊙∘
  )  # check map
  ▽× # reject rocks and outside cells
)
Relen ← (
  :
  ⬚0 ↯ ⇌ ⊟ ⊙: ⊡1△.
)
Resize ← (
  ,:
  ⍜⊙⍉Relen : Relen
)

Hash ← (
  ⍤"hash number arrays only"=0type.
  ♭⋯+4294967296♭
  ⬚0↯ ¯1_32
  /(
    ⊙⍜°⋯(×31)
    ⬚0=
  )
  °⋯
)

⍤⊃⋅∘ ≠ ∩Hash 0 1
⍤⊃⋅∘ ≠ ∩Hash 0 0_0
⍤⊃⋅∘ ≠ ∩Hash 0_0 0_0_0

# ( size matrix -- matrixes )
CutUp ← (
  .
  ☇2 ≡(≡⍉ ↯ ⊂ ⊃(∘|⊂ ¯1 ⊢⇌△.;)⊙⍉) ¤ ⊙(↯ ⊂ ⊃(∘|⊂ ¯1 ⊢⇌△.;))
)

Trim ← (
  ⊃(⊡0_0)∘
  ⊃(⊙∘|∘)
  ≠,
  ≡/↥
  ▽
  ⍉
  ⊙.:
  ≡/↥≠
  ▽
  ⍉
)

Trim [9_9_9_9
      9_1_2_9
      9_3_4_9
      9_9_9_9]

⍤⊃⋅∘≍ [1_2
       3_4]

$ ...........
$ .....###.#.
$ .###.##..#.
$ ..#.#...#..
$ ....#.#....
$ .##..S####.
$ .##..#...#.
$ .......##..
$ .##.#.####.
$ .##..##.##.
$ ...........
Input ←
RealTargetStep ← 1000

Input ← &fras "day21.txt"
RealTargetStep ← 26501365

GardenSize ← ⧻ Parse Input
CycleLength ← ×2 GardenSize
GrowSize ← 21
TargetStep ← -◿2.RealTargetStep
Modulus ← ◿ CycleLength RealTargetStep

SimulatedSteps ← 1115 # + ◿2 RealTargetStep ×4 CycleLength 

Walk ← (
  ◿2. # check for oddness
  (
    # even
    ÷2
    ⊙0 # counter
  |    # odd
    ⌊÷2
    ⊙1 # counter
    ⊙⊙Step
  )
  ⍥(
    +2 # bump counter
    ⊙(
      Step
      Step
    )
    (
      # do nothing
    | # -- counter visitedlist garden
      ⊙(
        # -- visitedlist garden
        ⊃(
          (
            # hash viz
            °⊚
            # -- visitedmatrix largegarden
            Resize ⧻: # resize to largegarden size

            CutUp GrowSize
            ≡Hash
            ↯ ⊟ . GrowSize
            Trim
            # ⍜(♭↻⊟.⌈÷2GrowSize)⊛ # classify hashes
            ⍜♭⊛ # classify hashes
            ∵(⊡:" abcdefghijklmnopqrstuv")

            # +@🌀 ◿120
            # +@A ◿300
            # +1000 ◿1000
            ≡(/⊂⍉⬚@\s⊟" "⍉)
            ≡&p
                | # 
          )1
            | # 

          ⧻:        # get large garden size
          ÷GrowSize # recover minigarden size
          ⌊÷        # convert to minigarden coord
          °⊚        # compute occupancy for each minigarden
          # Resize GrowSize # match map size

          &p$"occ:_"Trim. # show occupancies
          ;
            | # 
          ⊙∘
        )
      )
    )↧⊃(=Modulus◿CycleLength|>×0 CycleLength).
    ⊃⊙∘⋅(
      ⊢⍉
      /↧
      &p$"min=_".
      ⍤"warning, getting out of garden">0
    )
    &p$"n=_ S=_"⊃(⊙⧻|⊙∘)
  )
  ; # &p
  ⊙;
)
Center ← [.]⌊÷2⧻
PartOne ← (
  ⊙Parse
  ⊙(¤Center.)
  # ⊙⊙(&p$"_ garden cells out of _"⊃(/+|⧻)♭.)
  ⧻Walk
)
Grow ← (
  ⍤"odd only"=1◿2.
  ⍉ ▽ ⊙(⍉▽) .
)
---
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

$ ...........
$ .....###.#.
$ .###.##..#.
$ ..#.#...#..
$ ....#.#....
$ .##..S####.
$ .##..#...#.
$ .......##..
$ .##.#.####.
$ .##..##.##.
$ ...........
; # Aeq 16 PartOne 6.

# &fras "day21.txt";

&p "Tests OK"
---
# ⍤⊃⋅∘≍ 3709 PartOne 64 &fras "day21.txt"
# ⍤⊃⋅∘≍ 3709 &p⍜now PartOne 2 [65_65] &fras "day21.txt"
# ⍤⊃⋅∘≍ 0 &p⍜now PartTwo &fras "day21.txt"

Parse Input
Grow GrowSize
Walk SimulatedSteps Center.
# &ims °⊚.
⧻
