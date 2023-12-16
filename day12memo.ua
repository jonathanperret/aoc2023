# Experimental!
Parse ← ↯¯1_2 ⊜(□⍣⊜⋕⋅⊙;≠@,.) ¬∊:"\n ".

PlaceOne ← (
  # max start index
  ↧⊃(-:⧻|⊗ @#|:⊙∘)
  ≥0.
  (
    []
  | ⊃⋅∘+
    ⊙(⍜▽(≡⋅@#)=@?. ↘1 ↙)
    +1 ⊚ ⌕ ▽:@#
  )
)

Count ← ↬memo(
  :∩(±⧻),,
  (
    ¬∊@#; # no groups: check end of string
  | (
      0 # empty string, groups remaining: fail
    | ⊙⊃(⊢|↘1)
      PlaceOne,,
      ⊃(+⊙;|⋅∘) # add length to starts
      ⊙∩¤
      ≡(|3
        ↘ # drop part used by first
        ↫
      )
      /+
    )
  )
)
PartTwo ← (
  Parse
  ≡(
    ∩°□°⊟
    $"._?_?_?_?_" .... ⊙(▽5)
    Count
  )
  /+
)

$ ???.### 1,1,3
$ .??..??...?##. 1,1,3
$ ?#?#?#?#?#?#?#? 1,3,1,6
$ ????.#...#... 4,1,1
$ ????.######..#####. 1,6,5
$ ?###???????? 3,2,1

&fras "day12.txt";
⍜now PartTwo
