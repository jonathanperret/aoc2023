# Experimental!
Parse ← ↯¯1_2_3 ⊜⋕¬∊:", @\n".
StripZ ← ⍜°⍉(↙2)

Cross ← /-×⇌

# ( [ p1 v1 ] [ p2 v2 ] -- bool )
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
MakeScad ← (
  ≡(
    ♭
    ⍜(↙3)(×1e-12)
    ≡(□$"__"⊃(⊡:"++-"±|⌵))
    °[⊙⊙⊙⊙⊙∘]
    ∩°□ ⊙⊙∩∩°□
    □$"translate([_,_,_]) hull() { dot(); translate(len*[_,_,_]) dot(); }"
  )
  &fwa "day24.scad"$"module lines() {\n_\n}"/⊐$"_\n_"
)

CrossThree ← (
  # [ x1 y1 z1 ] [x2 y2 z2]
  -⊃(
    ↻1 # [ y1 z1 x1 ] [x2 y2 z2]
    ×  # [ y1x2 z1y2 x1z2 ]
    ↻1 # [ z1y2 x1z2 y1x2 ]
  | ↻2 # [ z1 x1 y1 ] [x2 y2 z2]
    ×  # [ z1x2 x1y2 y1z2 ]
    ↻2 # [ y1z2 z1x2 x1y2 ]
  )
  # [ y1z2-z1y2 z1x2-x1z2 x1y2-y1x2 ]
)

DotThree ← (
  /+×
)

NormThree ← (
  ⍜(°√)/+
)

NormalizeThree ← (
  ÷ NormThree.
)

# ( [ p1 v1 ] [ p2 v2 ] -- distance )
LineSeparation ← (
  ∩°⊟ # -- p1 v1 p2 v2
  ⊃(
    -:⊙⋅∘                          # p1 - p2
  | NormalizeThree CrossThree ⋅⊙⋅∘ # n = normalized(v1 cross v2)
  )
  ⌵DotThree
)
# size center
MakeRangeTable ← (
  ⊠⊟°⊟⍉+⍉×¤÷10-5⇡10 ⊙¤
)

# ( t l -- p )
PointOnLine ← (
  ⊙(°⊟⇌) # t v p
  +×
)

# [ t1 t2 ] l1 l2 lines
TryPair ← (
  °⊟ # t1 t2
  ⊙: # t1 l1 t2 l2
  ∩PointOnLine
  # -- pi1=t1*v1+p1 pi2=t2*v2+p2
  ⊃(∘|-)
  # -- pi1 pi2-pi1
  ⊟
  # [ pi vi ]
  ¤
  /↥≡LineSeparation
)

# [[[t1 t2]*]*]
ScanRange ← (
  ⍜(☇1)(
    ≡TryPair
  )
)

Step ← (
  # rangesize rangecenter data
  ⊃(
    ∘ # keep rangesize
  | MakeRangeTable
    ⊃(
      ScanRange
      # &p ↙3 ⊏⍏.♭. # ⍜(×1e12)⁅
      # &ims ÷/↥♭..
      &p$"worst=_ best=_"⊃(/↥|/↧)♭.
      ⊢⍏♭ # min cell index
    | ☇1  # as pair list
    )
    ⊡ # pick best pair as new center
    &p$"best pair=_".
  | ⋅⋅⊙⊙∘ # keep data
  )
  # rangesize rangecenter data
)

Solve ← (
  # pick two stones
  °⊟↙ 2.
  ¤⊙∩¤ # fix stones and list
  # start with a range
  ⊟. 1e13 [0 0]
  ⍢(
    # &p$"_ _",,
    Step
    ×0.5
  | >1/↧
  )
  ; # drop range size
  ⁅ # round t1 t2 to ints
  &p$"t1=_ t2=_"°⊟.
  ⊙⊙⊙;
  # [ t1 t2 ] l1 l2
  ⊙(&p$"l1=\n_\nl2=\n_\n",,)
  ⊙⊙(∩(°⊟⊢))°⊟
  &p$"p1=_\nv1=_\np2=_\nv2=_"⊃(⋅⋅⊙⊙⊙∘|⊙⊙⊙⊙⊙∘)
  ∩+⊃(×⊙⋅⋅∘|⋅⋅∘|×⋅⊙⋅⋅⋅∘|⋅⋅⋅⋅∘|⊙∘)
  # pi1 pi2 t1 t2
  &p$"pi1=_\npi2=_",,
  ⊃(
    ÷:∩- # v = (pi2-pi1)/(t2-t1)
    &p$"v=_".
  | ⋅⋅∘ # t1
  | ∘   # pi2
  )
  -× # p = pi1 - t1*v
  &p$"p=_".
  /+
)
PartTwo ← (
  Parse
  Solve
)
---
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Aeq 0 DotThree 1_0_0 0_1_0
Aeq 1 DotThree 1_0_0 1_0_0

Aeq 1 NormThree 1_0_0
Aeq 21 NormThree 4_13_16 # https://en.wikipedia.org/wiki/Pythagorean_quadruple#Primitive_Pythagorean_quadruples_with_small_norm

Aeq 0_0_15 CrossThree 5_0_0 0_3_0
Aeq 15_0_0 CrossThree 0_0_5 0_¯3_0

Aeq 10 LineSeparation [1_1_1 2_0_0] [0_0_11 0_1_0]

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

[[406226548612650 249663107713011 205092926261090][¯68 327 ¯148]]
[[406226548612650 249663107713011 205092926261090][¯68 327 ¯148]]
°⊟⇌
+×1e6
⊙1_0_0
⊟
LineSeparation
Aeq 0

$ 19, 13, 30 @ -2,  1, -2
$ 18, 19, 22 @ -1, -1, -2
$ 20, 25, 34 @ -2, -2, -4
$ 12, 31, 28 @ -1, -2, -1
$ 20, 19, 15 @  1, -5, -3
Aeq 2 PartOne 7 27

&p "Tests OK"
---
⍤⊃⋅∘≍ 15318 PartOne 200000000000000 400000000000000 &fras "day24.txt"
⍤⊃⋅∘≍ 870379016024859 PartTwo &fras "day24.txt"
