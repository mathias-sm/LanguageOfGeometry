---
title: Language of Shape
author:
 - Mathias Sablé Meyer
 - Marie Amalric
 - Stanislas Dehaene
link-citations: true
lang: en
fontsize: 10pt
geometry: top=3cm, bottom=3cm, left=3cm, right=3cm
header-includes:
    - \usepackage{graphicx}
css:
    - style.css
include-before: <script src="Main.js"></script>
abstract: |
    Since the upper paleolithic, human of all cultures have reproducibly made
    drawings and painting using a small set of symbolic, non-figurative shapes:
    lines, circles, squares, spirals, zigzags, lines of dots, etc.

    These shapes involve idealized concepts such as rectilinearity, curvature
    or right angle that go beyond those available to the sensory environment.
    Furtermore, even when human drawings are figurative, the representation is
    often more conceptual than visual, as evidenced by children's of faces or
    stick-figures of the body.

    Following up on our previous proposal of a “language of geometry” (cf
    @amalric2017language), we propose that the human cognitive system encodes
    shapes as mental programs in a “language of thought” for geometrical
    shapes. Furthermore, we propose that the shapes that are perceived as
    simple correspond to the shortest mental programs; and, more generally,
    that the subjective complexity of shapes is proportional to the minimal
    description length (MDL, also known as Kolmogorov complexity), i.e. the
    length of the shortest program that can capture it. This view implies that
    even the mere perception of a shape involves its mental representation in a
    language-like format with recursive embeddings, and that the availability
    of such a language (although it may not be related to natural language) is
    what allowed humans, unlike other animals, to develop symbolic drawings.

    Our goal here is to capture the underlying structure of this language of
    shapes. Evertthing is online and can be tested at
    [http://www.dptinfo.ens-cachan.fr/~msableme/LoG/](http://www.dptinfo.ens-cachan.fr/~msableme/LoG/)
---

Rationale
=========

Let's imagine someone drawing a non-figurative shape on a piece of paper,
holding a pencil on a piece of paper. We argue that behind the representation
of what this person is drawing lies a language with primitives and combinations
that is *executed* by this person.

A language is defined by its primitive and its syntax. To identify those
components, we started from the literature on prehistoric drawings,
mathematics, children's drawing and traditional shapes across cultures. On this
bases we adopted a reference set of 6 shapes as the target for the minimal
expressiveness of our language, with the idea that our language should be
powerful enough to capture those shape with a low-complexity program.

![The reference set of shapes](baseShapes.png)

Once we had generated a simple language with as few primitives as possible we
checked its ability to generalise to other shapes by exploring the range of
programs and the associated shapes.

1. The segment is our most simple target shape, it requires the ability to draw
   something or as we will see later, to integrate a set of parameters for a
   fixed, arbitrary duration. Infinite ? Euclide ?
2. The circle should be as simple as the segment, it is somehow the simplest
   closed segment, and in our language it's represented with another set of
   parameters to integrate that defines the curvature of the drawn line.
3. The spiral is a circle that would accelerate along the integration, thus
   missing the starting point : experiments should be run here to confirm that
   indeed this is cognitively satisfying --- are people acceleration along the
   spires of a spiral?
4. The square is the first shape that requires explicit discrete repetition,
   thus mixing the infinitesimal repetition of the integration and the explicit
   repetition for the four sides. It also requires the concatenation, as
   opposed to the embedding, of two instruction : drawing a segment and
   turning.
5. The zigzag needs to deal with a repetition, but also with turning in either
   a direction or another, thus introducing simple arithmetic and variable
   manipulation to do that in a concise way --- i.e. without explicitly giving
   all the cases.
6. The line of dots was added to be able to use one shape --- the line --- as a
   cue for another --- the circle --- and thus embedding program seamlessly.

In all of the above, we postulate the existence of fixed units specific to each
operation as well as a minimal arithmetic capable of generating all integers at
least. This arithmetic can be later extended at will to include cognitively
relevant primitives --- 5 as a primitive of measurement for exemple.

Here is the proposed code for those six reference shapes:

1. Segment

```LoG
Integrate
```

2. Circle

```LoG
Integrate(angularSpeed=unit)
```

3. Spiral

```LoG
Integrate(accel=unit, angularSpeed=unit)
```

4. Square

```LoG
Repeat(Double(Double(unit))) {
  Integrate ;
  Turn
}
```

5. Zigzag

```LoG
alpha = unit ;
Repeat(indefinite) {
  Integrate ;
  Turn(angle=alpha) ;
  alpha = Opposite(alpha)
}
```

6. Line of dots

```LoG
Repeat(Double(Double(unit))) {
  Integrate(t=Half(unit),pen=off) ;
  Embed {
    Integrate(angularSpeed=unit)
  }
}
```


Syntax
======

We propose the following syntax for such a language of shapes:

```LoG
Var     ::= | unit
            | Double(Var) | Half(Var)
            | Next(Var) | Prev(Var)
            | Oppos(Var)
            | Divide(Var,Var)

Program ::= | Program ; Program
            | Turn([angle=Var])
            | Embed { Program }
            | Repeat([Var]) { Repeat }
            | Integrate([d=Var], [pen={on,off}],
                        [speed=Var],
                        [accel=Var],
                        [angularSpeed=Var],
                        [angularAccel=Var])
```

Terms within `[...]` have default values and can be omitted while still being
valid with regard to the syntax.

Semantics
=========

The three most important operators are the `Repeat` and the `Integrate`
instruction. Here is a detailed breakdown of what every instruction does:

* `;` is just the concatenation of programs : it executes the left-hand side in
  the current environment and the right hand side in the environment returned
  by the left-hand side.

* `Repeat(Var){ Program }` evaluates Var in the current context to a number `n`
  in a deterministic way that we'll explain later, and then executes the
  following program :

```LoG
Program ;
Program ;
Program ;
...
... [n times]
...
Program ;
```

  Note that while the result is syntactically equivalent to a explicitely
  written version --- and because variables can always be manually evaluated as
  there is no side effect with regard to any form of outside world input ---
  one could malignly decide not to use `Repeat` ever. Of course in many cases
  it simplifies a program a lot, and when it come down to costs it will in most
  cases significantly shrunk the cost of a given shape.

* `Integrate([...])` is the only instruction here that actually draws anything.
  The idea behind it is to move the pen, on or off the paper, during a given
  amount of time, with a given set of parameters. The integration *does* refer
  to an infinitesimal repetition in the formal semantics, although for obvious
  reasons the operational semantics is an approximation.
  It takes a few arguments, let's see the detail :

    * `t` is the duration of the integration.
    * `pen` is whether the pen should be touching the paper or not
    * `speed` indicates the speed at which the hand is moving
    * `accel` indicates how the speed should change across time
    * `angularSpeed` indicates at each time point how the direction of the
      drawing should change --- it is therefore already the derivative of an
      internal value that represents the facing direction, the same way speed
      represents the derivative of the x/y position.
    * `angularAccel` indicates how much the previous value should change over
      time

  All these variables are in arbitrary units that were chosen so that the
  default values lead to simple programs as described in the beginning of the
  document.

* `Turn(angle=[...])` is an instantaneous change in the facing direction. This
  allows non-differentiable angles, although it could be seen as a less
  expensive syntactic sugar for an `Integrate` at null speed.

* `Embed {[...]}` allows one to insert a program within another one
  seamlessly and without breaking the surrounding environment. More precisely
  it executes the given program in the current environment but when it returns
  all modifications are erased.It is at the core of the compositional aspect of
  the language.


Future work
===========

The cost of a program is straightforwardly defined as the number of
instructions in the program.

This leads to a few important questions:

* What do *simple* programs look like? This is easily answered by generating
  them and having a look at the result. Experience will show that they match
  what subjects would agree to describe as *simple*
* For a given shape, what is the simplest program, and is it the one inferred
  by humans in all cases? In most cases?
* Can we map program complexity to an objective mesure of required attention
  through brain imaging?

We are currently exploring these aspects to push this work further.


Sandbox
=======

<form>
<textarea id="program" rows="20" autocomplete="off" autocorrect="off"
autocapitalize="off" spellcheck="false">
ten = Next(Next(Double(Double(Double(unit))))) ;
 n = Next(Next(unit)) ;
 Repeat(ten) {
  Embed {
   Repeat(n) {
    Integrate(t=Divide(Half(unit),n)) ;
    Turn(angle=Divide(Double(Double(unit)),n))
   }
  } ;
  n = Next(n) ;
 Integrate(t=Half(Half(unit)),pen=off)
}</textarea>

<div class="centerize">

<button id="interpret" type="button">Interpret!</button>

<button id="ifl" type="button">I'm feeling lucky!</button>

</div> </form>

<div id="errorOutput"></div>
<div id="normalOutput"></div>


<div id="programCanvas"></div>


References
==========
