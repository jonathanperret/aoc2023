Lines ← &i "tools.ua" "Lines"
Aeq ← ⍤⊃($"expected _ got _")≍

Parse ← ⊜(□ ⊜parse ≠@\n.) ¬⌕"\n\n".

# PartOne ← /+⊏↙3⍖.≡(/+⊔)Parse

---
$ 10

Parse
dump∘

# Aeq 90 PartOne

&p "Tests OK"

---

# &p PartOne &fras "day1.txt"
# &p PartTwo &fras "day1.txt"
