---
title: The Language of Geometry
author: Mathias Sablé Meyer, Stanislas Dehaene, Marie Amalric
header-includes:
    <script src="Main.js"></script>
html_document:
    css: style.css
    toc: true
    toc_depth: 6
    toc_float:
        collapsed: false
        smooth_scroll: false
    smart: true
---

The Language of Geometry
========================


Introduction
------------

As we believe in compositionallity and the ability to manipulate abstract
symbols in the brain, we are designing a language of geometry that allows for
this kind of operation. This is a proof of concept whose goal is to be
a proposal for a way to describe planar shapes in such a way that, with
a compositional semantics and cost function on the programs, the associated ---
unique modulo noise in the representation --- shape should match a human notion
of complexity.

The primitives were added so that relevant shapes, that we will describe
later on, feel intuitive to draw using the language. The same goes for
the complexity function.


Syntax
------


|         |     |                                                                                  |
| ------  | --- | -------------------------                                                        |
| Number  | ::= | &#124; 0, 1, 2, -1, 1.5, pi, ...                                                 |
|         |     |                                                                                  |
|         |     | &#124; Number + Number                                                           |
|         |     | &#124; Number - Number                                                           |
|         |     |                                                                                  |
|         |     | &#124; Number \* Number                                                          |
|         |     | &#124; Number / Number                                                           |
|         |     |                                                                                  |
|         |     |                                                                                  |
| Noises  | ::= | POSITION_NOISE=Number,ACCELERATION_NOISE=Number,SECOND_ORDER_NOISE=Number |
|         |     |                                                                                  |
|         |     |                                                                                  |
| Body    | ::= | &#124; Body ; Body                                                               |
|         |     | &#124; SetValues(t'=Number,v'=Number,v''=Number,t''=Number)                      |
|         |     | &#124; Save(string)                                                              |
|         |     | &#124; Load(string)                                                              |
|         |     | &#124; Turn(Number)                                                              |
|         |     | &#124; DiscreteRepeat(Number) { Body }                                           |
|         |     | &#124; Integrate(Number)                                                         |
|         |     | &#124; {}                                                                        |
| Program | ::= | &#124; Noises ; Body                                                             |
|         |     | &#124; Body                                                                      |


Intuitive Semantics
-------------------

A program either starts with 3 set values for the possible amount of noise or
it does not, in which case default values are used. Then the body of a program
is either a concatenation of bodys, with the usual syntax `;`, or an
instruction. Let us detail these a bit more.

### What is intuitive

 * A `Number` is a number : simple operations are resolved, a single value is
   defined so far and this is `pi`.
 
    If you think we need more operations tell me or make a pull request, if it's
    easy to write in OCaml it's easy to add here.

 * `{}` is an empty program that does nothing.

 * At some point, the semantics of `Undefined` will be defined. In the meantime,
   it is not defined.

       Think of it as adding infinity to the language, but with a *I don't know
       where to stop* rather than an *I will never stop* semantics.

### What is less so

#### `Save(string)` & `Load(string)`

These two instructions are used to respectively store and restore the current
context, or continuation. You can see it used in both the person example, with
a very simple use case of keeping positions stored, and in the star example
where it is dynamically over-written.

#### `DiscreteRepeat(Number) { Program }`

This takes a Number as an argument, arbitrarily transforms it to an integer (it
just usually rounds it down, don't worry. See OCaml's Pervasive.int_of_float
for more details), executes the given Program the specified mount of time.

Note that it only concatenates the program so far: if you want to play with
backtracking, repetitions with/without modifications, and so on, you have to
play around with `Save` and `Load`.

#### `SetValues(...)` & `Integrate(Number)`


Input
-----

You may look for inspiration [here](./examples/)

<form><textarea id="program" rows="10">
SetValues(v'=1.5,t''=0.0001) ;
Integrate(600.)
</textarea><div class="centerize"><button id="interpret" type="button">Interpret!</button> </div></form>


