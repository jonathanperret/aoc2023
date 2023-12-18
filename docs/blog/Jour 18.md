## Partie 1

Il faut creuser un lagon pour stocker de la lave ?

```no_run
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
```

C'est un programme d'excavation. On extrait des blocs d'un mètre cube, comme dans Minecraft, en se déplaçant dans une direction (`U/D/L/R` à chaque fois). Il y a aussi des couleurs pour peindre la tranchée, mais c'est pour plus tard apparemment.

La question de la première partie, c'est le nombre de cubes qui auront été enlevés si on parcourt d'abord le chemin indiqué (qui fait une boucle, apparemment) :

```no_run
#######
#.....#
###...#
..#...#
..#...#
###.###
#...#..
##..###
.#....#
.######
```

Puis qu'on remplit l'intérieur (tiens, ça me rappelle quelque chose) :

```no_run
#######
#######
#######
..#####
..#####
#######
#####..
#######
.######
.######
```

Je me dis que pour cette dernière opération je pourrai peut-être réutiliser du code du jour 10 ?

Allez c'est parti pour la lecture de l'entrée. C'est un peu plus sophistiqué que ces derniers jours, mais rien de méchant. Je choisis de stocker les directions, les distances et les couleurs dans 3 tableaux séparés.

```
Parse ← ⊜(°□⊢⊙⋕⊙∩°□°[⊙⊙∘] ⊜□ ¬∊:" #()".) ≠@\n.

$ R 6 (#70c710)
$ D 5 (#0dc571)
$ L 2 (#5713f0)
$ D 2 (#d2c081)
$ R 2 (#59c680)
$ D 2 (#411b91)
$ L 5 (#8ceee2)
$ U 2 (#caa173)
$ L 1 (#1b58a2)
$ U 2 (#caa171)
$ R 2 (#7807d2)
$ U 3 (#a77fa3)
$ L 2 (#015232)
$ U 2 (#7a21e3)

Parse
```

Je réalise que je ne sais pas quelle taille doit faire le terrain. Je pourrais l'agrandir au fur et à mesure ?

Je tente une petite exploration : je fais simplement la somme des `U`, des `L`, etc :

```
Parse ← ⊜(°□⊢⊙⋕⊙∩°□°[⊙⊙∘] ⊜□ ¬∊:" #()".) ≠@\n.
Directions ← [0_1 ¯1_0 0_¯1 1_0]
DirLetters ← "RULD"

$ R 6 (#70c710)
$ D 5 (#0dc571)
$ L 2 (#5713f0)
$ D 2 (#d2c081)
$ R 2 (#59c680)
$ D 2 (#411b91)
$ L 5 (#8ceee2)
$ U 2 (#caa173)
$ L 1 (#1b58a2)
$ U 2 (#caa171)
$ R 2 (#7807d2)
$ U 3 (#a77fa3)
$ L 2 (#015232)
$ U 2 (#7a21e3)

Parse
⊙⊙;               # on laisse tomber les couleurs
↘4 ⊛ ⊂ DirLetters # on remplace les lettres par des numéros de directions
⊏ :Directions     # puis par les vecteurs
×                 # multipliés par les distances
\+
°⊟⇌⍉
∩[⊃/↧/↥]
⍉⊟
```

Si sur l'exemple on va bien de `0 0` à `9 6`, avec l'entrée complète on va de `¯256 0` à `165 378`.

Bon, mais maintenant que je sais calculer cette étendue justement, rien ne s'oppose à ce que j'en déduise une taille de terrain appropriée et un point de départ.

Si je prends la négation du coin supérieur gauche comme point de départ, je devrais ne visiter que des points de coordonnées non négatives.


65309 : _your answer is too low_.
65546 : _your answer is too low_.

#### fin

