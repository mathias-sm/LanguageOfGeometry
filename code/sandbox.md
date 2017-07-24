---
title: The Language of Geometry --- Sandbox
author:
 - Mathias Sablé Meyer
 - Stanislas Dehaene
 - Marie Amalric
include-before: <script src="Main.js"></script>
css:
 - style.css
link-citations: true
lang: en
---

# Syntax

```LoG
Var     := | unit_ | 0
           | Double(Var) | Half(Var)
           | Next(Var) | Prev(Var)
           | Oppos(Var)
           | Divide(Var,Var)

Program := | Program ; Program
           | Embed { Program }
           | Turn(angle=Var)
           | Repeat([2]) { Body }
           | Integrate([d=Var],
                       [pen={on,off}],
                       [speed=Var],
                       [accel=Var],
                       [angularSpeed=Var],
                       [angularAccel=Var])
```


# Sandbox

<form>
<textarea id="program" rows="20" autocomplete="off" autocorrect="off"
autocapitalize="off" spellcheck="false">
dix = Next(Next(Double(Double(Double(unit))))) ;
 n = Next(Next(unit)) ;
 Repeat(dix) {
  Embed {
   Repeat(n) {
    Integrate(t=Divide(Half(unit),n)) ;
    Turn(angle=Divide(Double(Double(unit)),n))
   }
  } ;
  n = Next(n) ;
 Integrate(t=Half(Half(unit)),pen=off)
}</textarea>

<div class="centerize"> <button id="interpret"
type="button">Interpret!</button> </div> </form>

<div id="errorOutput"></div>
<div id="normalOutput"></div>

<div id="programCanvas"></div>

