---
title: The Language of Shape --- On machines that draw
author:
 - Mathias Sablé Meyer
 - Stanislas Dehaene
 - Marie Amalric
link-citations: true
lang: en
fontsize: 10pt
geometry: top=3cm, bottom=3cm, left=3cm, right=3cm
abstract: |
    Across culture and history, one can only be struck with the universal
    existence of symbolic, non figurative drawgings: spirals, lines of dots,
    circles, etc.
    And even when drawings are figuratives, the link to the object
    represented is often more conceptual than visual --- as are the children
    representations of faces or bodies.

    Our goal is to capture the underlying structure in a (programing-)language
    that would model the structure of shapes more than their visual aspect.

---

Rationale
=========

Let's imagine someone drawing a non-figurative shape on a piece of paper,
holding a pencil on a piece of paper. We argue that behind the representation
of what this person is drawing lies a language with primitives and combinations
that is *executed* by this person.


We aim at a model for such a scenario: it should be expressive enough to
capture shapes but should also be cognitively realistic. Thus simple shapes
should have simple programs --- the meaning of "simple" will be discussed
further.

From the literature of prehistoric drawings, mathematics, children's drawing
and traditional shapes across cultures fixed a set as the target for the
minimal expressiveness of the language: if a given shape cannot be reached then
the language is not powerful enough. What is more these shapes should have low
complexity within the language.

Once we had a simple language with as few primitives as possible we checked
that it was able to generalise enough by exploring the set of programs and
associated shapes to see whether it would generate novel simple shapes that
were not in the target set.


* The segment is our most simple target shape, it requires the ability to draw
  something or as we will see later, to integrate a set of parameters for a
  fixed, arbitrary duration. Infinite ? Euclide ?
* The circle should be as simple as the segment, it is somehow the simplest
  closed segment, and in our language it's represented with another set of
  parameters to integrate that defines the curvature of the drawn line.
* The spiral is a circle that would accelerate along the integration, thus
  missing the starting point : experiments should be run here to confirm that
  indeed this is cognitively satisfying --- are people acceleration along the
  spires of a spiral?
* The square is the first shape that requires explicit discrete repetition,
  thus mixing the infinitesimal repetition of the integration and the explicit
  repetition for the four sides. It also requires the concatenation, as opposed
  to the embedding, of two instruction : drawing a segment and turning.
* The zigzag needs to deal with a repetition, but also with turning in either a
  direction or another, thus introducing simple arithmetic and variable
  manipulation to do that in a concise way --- i.e. without explicitly giving
  all the cases.
* The line of dots was added to be able to use one shape --- the line --- as a
  cue for another --- the circle --- and thus embedding program seamlessly.

Syntax
======

We propose the following syntax for such a language of shapes:

```LoG
Var     ::= | unit | 0
            | Double(Var) | Half(Var)
            | Next(Var) | Prev(Var)
            | Oppos(Var)
            | Divide(Var,Var) | ...?

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

General remark : a program is a concatenation of smaller programs hence
compositionally is obviously central and the evaluations takes instruction one
at a time in the written order and evaluate them in the context they're in as
per the previous instructions.

The two most important operators are the `Repeat` and the `Integrate`
instruction. Here is a detailed breakdown of what every instruction does:

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

* `SavePos/LoadPos` allow one to backtrack on previous positions in the plane
  without having to manually Integrate with pen off. This is cognitively very
  important and is a fundamental difference with previously existing `Logo`
  language, in many situation is seems implausible that the reasoning behind a
  backtracking would be some sort of hidden stroke.

* `SaveStroke/LoadStroke` -> NEEDS TO BE DISCUSSED

Exploration
===========

[Blabla]
