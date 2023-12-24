# Experimental!
Parse ← ↯¯1_2_3 ⊜⋕¬∊:", @\n".
StripZ ← ⍜°⍉(↙2)

Cross ← /-×⇌

Intersect ← (
  ∩°⊟ # -- p1 v1 p2 v2
  ⊃(
    Cross ⋅⊙⋅∘ # denom = v1 cross v2
  | Cross -⊙⋅∘ # v2 cross (p2 - p1)
  | :          # v1 p1
  )
  # t = v2 cross (p2 - p1) / denom
  ÷
  # poi = p1 + t*v1
  +×
)

# ( min max [ p1 v1 ] [ p2 v2 ] -- ok )
IntersectOK ← (
  ⊙⊙⊃(Intersect|∩(⊙±°⊟⊢⍉))
  # -- min max poi p1.x sign(v1.x) p2.x sign(v2.x)
  ⊃(
    # poi >= min
    /↧≥⊙⋅∘
  | # poi <= max
    /↧≤⋅⊙∘
  | # sign(poi.x-p1.x) == sign(v1.x)
    ⋅⋅⊙∘
    =±-:⊢
  | # sign(poi.x-p2.x) == sign(v2.x)
    ⋅⋅⊙⋅⋅⊙∘
    =±-:⊢
  )
  ↧∩↧ # and it all
)
PartOne ← (
  ⊃(⋅⋅∘|⊙∘)
  Parse
  StripZ
  ⊠(IntersectOK ⊃(⋅⋅⊙∘|⊙∘)).
  ÷2/+♭
)
---
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍
Aeq 1 Cross [1 0] [0 1]
Aeq ¯1 Cross [0 1][1 0]
Aeq ¯2 Cross [1 1][1 ¯1]

Aeq [2 2] Intersect [[0 0] [1 1]][[0 4] [1 ¯1]]
Aeq [14.3 15.3] ⍜(×10)⁅ Intersect [[18 19] [¯1 ¯1]][[19 13] [¯2 1]]
Aeq [∞ ∞] ⌵ Intersect [[18 19] [¯1 ¯1]][[20 25] [¯2 ¯2]]

Aeq 1 IntersectOK 7 27 [[18 19] [¯1 ¯1]] [[19 13] [¯2 1]]
Aeq 1 IntersectOK 7 27 :[[18 19] [¯1 ¯1]] [[19 13] [¯2 1]]
Aeq 1 IntersectOK 7 27 [[20 25] [¯2 ¯2]] [[19 13] [¯2 1]]
Aeq 1 IntersectOK 7 27 :[[20 25] [¯2 ¯2]] [[19 13] [¯2 1]]
Aeq 0 IntersectOK 7 27 [[12 31] [¯1 ¯2]] [[19 13] [¯2 1]]
Aeq 0 IntersectOK 7 27 :[[12 31] [¯1 ¯2]] [[19 13] [¯2 1]]
Aeq 0 IntersectOK 7 27 [[20 19] [1 ¯5]] [[19 13] [¯2 1]]
Aeq 0 IntersectOK 7 27 [[18 19] [¯1 ¯1]] [[20 25] [¯2 ¯2]]

$ 19, 13, 30 @ -2,  1, -2
$ 18, 19, 22 @ -1, -1, -2
$ 20, 25, 34 @ -2, -2, -4
$ 12, 31, 28 @ -1, -2, -1
$ 20, 19, 15 @  1, -5, -3
Aeq 2 PartOne 7 27

&p "Tests OK"
---
⍤⊃⋅∘≍ 15318 PartOne 200000000000000 400000000000000 &fras "day24.txt"
# ⍤⊃⋅∘≍ 0 now PartTwo &fras "day24.txt"
