##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) 15 [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 

# Jour 15

## Partie 1

On arrive à l'usine de lave, où un renne nous accueille.

Apparemment il va falloir implémenter un algorithme de hachage de chaîne ?

Exemple :

```no_run
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
```

Il y a `11` sous-chaînes (séparées par `,`) dans cet exemple. Chacune doit être soumise au hachage qui donne un résultat entre `0` et `255`, puis la somme doit être calculée. Et les étapes du hachage d'une chaîne sont :
* Prendre le code ASCII du premier caractère de la chaîne ;
* Augmenter la _valeur en cours_ (qui a commencé à `0`) de ce code ;
* Multiplier la _valeur en cours_ par `17` ;
* Appliquer un `modulo` `256` à la `_valeur en cours_` ;
* Continuer avec le caractère suivant.

Le résultat du hachage est la _valeur en cours_ à la fin de la chaîne.

Commençons par le hachage de chaîne. C'est assez trivial avec un `fold` :

```
Hash ← (
  ∧(◿ 256 × 17 + -@\0) : 0
)

$ HASH
```

Plus qu'à découper la chaîne en entrée, appliquer `Hash` et faire la somme.

Ah, c'était rapide. Sauf que… ce n'est pas la bonne réponse ??

Hmm, l'entrée ne contient qu'une ligne. Et on me dit d'ignorer les caractères de fin de ligne… Je n'ai rien fait de spécial pour ça et après vérification, le fichier contient bien un `\n` à la fin.

OK, voici la bonne version :

```
Split ← ⊜□¬∊:",\n".
Hash ← ∧(◿ 256 × 17 + -@\0) : 0
PartOne ← /+≡(Hash °□) Split

$ rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
⍤⊃⋅∘≍ 1320 PartOne
```

## Partie 2

Ce n'était qu'une mise en appétit, bien sûr.

La chaîne est un programme à exécuter.

Il y a deux types d'instruction, celles avec un `=` et celles avec un `-`.

Les instructions `=` (ex. `rn=1`) s'interprètent ainsi :
* un signe `=` sépare le _label_ de la _valeur_ ;
* l'application du hachage ci-dessus au _label_ (`rn`) donne un _numéro de boîte_ ;
* ensuite dans cette boîte, insérer une paire avec ce _label_ et cette _valeur_. Si aucune paire n'existe avec ce même _label_ dans la boîte, il faut l'insérer en fin de liste, sinon il faut remplacer la paire existante.

Les instructions `-` (ex. `rn-`) s'interprètent ainsi :
* le _label_ précède `-` ;
* l'application du hachage ci-dessus au _label_ (`rn`) donne un _numéro de boîte_ ;
* dans cette boîte, enlever la paire portant ce label si elle existe.

Je commence par implémenter l'exécution d'une instruction : trouver la bonne boîte, changer son contenu.

C'est assez laborieux. Peut-être que la représentation que j'ai choisie (des paires chaîne + nombre, chacun emboîté avec `box` bien sûr) n'est pas assez idiomatique.

Enfin bon, j'en viens à bout, à renfort de _switch functions_ surtout.

Ensuite il ne me reste qu'à appliquer toutes les instructions en séquence (`fold` encore), puis calculer le score final, ce qui se fait assez simplement — à part quand je tombe sur un cas particulier de liste vide : 

```
/+ [1 2]
## 3
/+ ↙ 0 []
## 0
/+ ≡°□ [□1 □2]
## 3
/+ ≡°□ ↙ 0 [□1 □2]
## []
```

Voilà le résultat final :

```
Hash ← ∧(◿ 256 × 17 + -@\0) : 0
Split ← ⊜□¬∊:",\n".
PartOne ← /+≡(Hash °□) Split
EmptyBox ← ↙0 [{"x" 1}]
EmptyBoxes ← ▽ : □EmptyBox
ApplyToBox ← (
  ⊃(
    ∊ @= ; # on vérifie le type d'instruction
  | ⋅∘     # on garde la boîte
  | ∘      # on garde l'instruction
  )
  (
    # cas des instructions "-"
    ⊓(
      □▽ ≥@a. # on prend le label de l'instruction
    | ≡⊢.     # on extrait les labels des paires
    )
    ▽≠ # on garde les paires non correspondantes
  |    #
    # cas des instructions "="
    ⊃(
      ▽ ≥@a.             # on prend le label
    | ⋕▽ ∊:"0123456789". # on prend la valeur
    )
    ∩□ # on les box pour préparer la nouvelle paire
    ⊃(
      ⊙(≡⊢.;) # on extrait les labels des paires
      =       # on cherche laquelle correspond
    | ⊟       # on prépare la nouvelle paire
    )
    /+. # est-ce qu'il y a une correspondance?
    (
      ⊂ ;   # non, on ajoute la nouvelle paire à la fin
    | ⊢⊚    # on trouve l'index de la correspondance
      ⍜⊡ ⋅∘ # on remplace la paire
    )
  )
)
Exec ← (|2
  ⊃(
    ▽ ≥@a. # on extrait le label
  | ⋅∘     # on garde les boîtes
  | ∘      # on garde l'instruction
  )
  Hash              # on calcule l'index de la boîte
  ⍜(°□⊡) ApplyToBox # et on applique l'instruction
)
ExecAll ← ∧(Exec °□)
ScoreBox ← (
  ±⧻. # vérification de boîte vide
  (
    0
  | ≡(°□⊡1) # on extrait la valeur des paires
    +1⇡⧻.
    ×
    /+
  )
)
ScoreBoxes ← (
  ≡(ScoreBox °□)
  +1⇡⧻.
  ×
  /+
)
PartTwo ← (
  Split
  EmptyBoxes 256
  :
  ExecAll
  ScoreBoxes
)

$ rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7

⍤⊃⋅∘≍ 1320 PartOne .
⍤⊃⋅∘≍ 145 PartTwo
```

##### Aller au jour : [1](Jour%201) [2](Jour%202) [3](Jour%203) [4](Jour%204) [5](Jour%205) [6](Jour%206) [7](Jour%207) [8](Jour%208) [9](Jour%209) [10](Jour%2010) [11](Jour%2011) [12](Jour%2012) [13](Jour%2013) [14](Jour%2014) 15 [16](Jour%2016) [17](Jour%2017) [18](Jour%2018) [19](Jour%2019) [20](Jour%2020) [21](Jour%2021) [22](Jour%2022) [23](Jour%2023) [24](Jour%2024) [25](Jour%2025) 
