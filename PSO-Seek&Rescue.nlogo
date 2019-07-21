patches-own
[
  val  ; fitness de el algorimo PSO
]

turtles-own
[
  vel-x                  ; velocidad en x
  vel-y                  ; velocidad en y

  personal-best-val   ; Mejor Valor local
  personal-best-x     ; Coordenada x del Mejor local
  personal-best-y     ; Coordenada y del Mejor local
]

globals
[
  global-best-x     ; La coordenada en x con el mejor valor encontardo por el grupo
  global-best-y     ; La coordenada en y con el mejor valor encontrado por el grupo
  global-best-val   ; El mejor valor encontrado por el grupo
  persona-rescatar  ; Persona a rescatar
  help-tries        ; Cantidad de equipos de resacte enviados
  cost
]

to setup-search-landscape   ;Genera un paisaje aleatorio
  ask patches [ set val random-float 1.0 ]
  repeat accidentalidad-geografica [ diffuse val 1 ]
  let min-val min [val] of patches
  let max-val max [val] of patches
  ask patches [ set val 0.9 * (val - min-val) / (max-val - min-val)  ]  ;Normaliza los valores entre 0 y  1
  ask max-one-of patches [val]
  [
    set val 1.0
    set persona-rescatar self
  ];Coloca un unico optimo (Persona a rescatar) de valor 1
  ask patches [ set pcolor scale-color green val 0.0 1.0]
end

to setup ;Crea las particulas (Drones) y los coloca aleatoriamente
  clear-all
  setup-search-landscape
  set help-tries 0
  create-turtles cantidad-de-drones
  [
    setxy 0 0
    ;setxy random-xcor random-ycor
    set vel-x random-normal 0 10
    set vel-y random-normal 0 10
    set personal-best-val val
    set color yellow
    set size 4
  ]

  ask turtles [
    set personal-best-val 0
    set personal-best-x (random-normal -100 100)
    set personal-best-y (random-normal -100 100)
  ]

  update-highlight
  reset-ticks
end

to go
  ask turtles [
    if val > personal-best-val
    [
      set personal-best-val val
      set personal-best-x xcor
      set personal-best-y ycor
    ]
  ]
  ask max-one-of turtles [personal-best-val]
  [
    if global-best-val < personal-best-val
    [
      set global-best-val personal-best-val
      set global-best-x personal-best-x
      set global-best-y personal-best-y
    ]
  ]

  ask turtles
  [
    set vel-x inercia-del-drone * vel-x
    set vel-y inercia-del-drone * vel-y
    facexy personal-best-x personal-best-y
    let dist distancexy personal-best-x personal-best-y
    set vel-x vel-x + (1 - inercia-del-drone) * prior-maximo-personal * (random-float 1.0) * dist * dx
    set vel-y vel-y + (1 - inercia-del-drone) * prior-maximo-personal * (random-float 1.0) * dist * dy
    facexy global-best-x global-best-y
    set dist distancexy global-best-x global-best-y
    set vel-x vel-x + (1 - inercia-del-drone) * prior-maximo-grupal * (random-float 1.0) * dist * dx
    set vel-y vel-y + (1 - inercia-del-drone) * prior-maximo-grupal * (random-float 1.0) * dist * dy
    if (vel-x > ( max-velocidad-del-drone / 10 )) [ set vel-x ( max-velocidad-del-drone / 10 ) ]
    if (vel-x < 0 - ( max-velocidad-del-drone / 10 )) [ set vel-x 0 - ( max-velocidad-del-drone / 10 ) ]
    if (vel-y > ( max-velocidad-del-drone / 10 )) [ set vel-y ( max-velocidad-del-drone / 10 ) ]
    if (vel-y < 0 - ( max-velocidad-del-drone / 10 )) [ set vel-y 0 - ( max-velocidad-del-drone / 10 ) ]
    facexy (xcor + vel-x) (ycor + vel-y)
    forward sqrt (vel-x * vel-x + vel-y * vel-y)

  ]

  ask patch 0 0[
    ask neighbors [
      set pcolor orange
    ]
  ]
  update-highlight
  set cost (help-tries * 150) + (ticks * 0.05 * cantidad-de-drones)
  tick
end

to send-help
  let i -10
  let j -10
  while [i < 10]
  [
    while [j < 10]
    [
      ask patch (global-best-x - i) (global-best-y - j) [set val 0 ]
      ask patch (global-best-x - i) (global-best-y - j) [set pcolor black ]
      set j j + 1
    ]
    set j -10
    set i i + 1
  ]

  set global-best-val -10

  ask turtles [
    set personal-best-val 0
    set personal-best-x (random-normal -100 100)
    set personal-best-y (random-normal -100 100)
  ]
  set help-tries help-tries + 1
end

to update-highlight
  watch persona-rescatar
end
@#$#@#$#@
GRAPHICS-WINDOW
5
10
518
524
-1
-1
2.51244
1
10
1
1
1
0
1
1
1
-100
100
-100
100
1
1
1
ticks
30.0

BUTTON
925
325
1030
385
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
925
395
1030
450
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
720
325
915
358
cantidad-de-drones
cantidad-de-drones
1
500
200.0
1
1
NIL
HORIZONTAL

SLIDER
525
415
710
448
prior-maximo-personal
prior-maximo-personal
0
2
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
720
415
915
448
prior-maximo-grupal
prior-maximo-grupal
0
2
1.2
0.1
1
NIL
HORIZONTAL

SLIDER
525
370
710
403
inercia-del-drone
inercia-del-drone
0
0.99
0.98
0.01
1
Kg*m2
HORIZONTAL

SLIDER
720
370
915
403
max-velocidad-del-drone
max-velocidad-del-drone
1
100
51.0
0.1
1
m/s
HORIZONTAL

SLIDER
525
325
710
358
accidentalidad-geografica
accidentalidad-geografica
0
100
44.0
1
1
NIL
HORIZONTAL

PLOT
525
15
955
315
Redundancia "Objetivo encontrado"
Tiempo Transcurrido
Cantidad de Drones
0.0
10.0
0.0
50.0
true
true
"" ""
PENS
"Drones en El Objetivo" 1.0 0 -4079321 true "" "plot count turtles with [ val > 0.95 ]"
"Drones en Optimos Locales" 1.0 0 -2674135 true "" "plot count turtles with [ val <= 0.95 ]"

MONITOR
525
460
657
517
Coordenada en x
global-best-x
0
1
14

MONITOR
665
460
797
517
Coordenada en y
global-best-y
0
1
14

MONITOR
805
460
875
517
Value
global-best-val
2
1
14

BUTTON
885
460
1030
515
Falso Positivo
send-help
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
1045
350
1310
511
Mejores Valores Encontrados:\n\nInercia del Dron = 0.98\nMáxima velocidad del Dron = 50\nPrior. al máximo Personal = 0.5\nPrior. al máximo Grupal = 1.2
18
105.0
0

MONITOR
820
80
935
125
Drones en el Objetivo
count turtles with [ personal-best-val = 1 ]
0
1
11

MONITOR
820
135
935
180
Ayudas enviadas
help-tries
0
1
11

MONITOR
820
190
935
235
Costo de busqueda
cost
0
1
11

MONITOR
820
250
935
295
Tiempo transcurrido (min)
(ticks * 0.7) + (help-tries * 20)
2
1
11

PLOT
965
15
1310
315
Costo por Minuto Rescate
USD / Min
Tiempo
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Costo por Minuto" 1.0 1 -14439633 true "" "plot cost / (ticks + (help-tries * 20) + 1)"

@#$#@#$#@
## WHAT IS IT?

Particle swarm optimization (PSO) is a search/optimization technique in the field of machine learning.  Although PSO is usually employed on search spaces with many dimensions, this model demonstrates its use in a two dimensional space, for purposes of easier visualization.

Formally speaking, there is some unknown function f(x,y), and we are trying to find values for x and y, such that f(x,y) is maximized.  f(x,y) is sometimes called a fitness function, since it determines how good the current position in space is for each particle.  The fitness function is also sometimes called a "fitness landscape", since it may be comprised of many valleys and hills.

One approach (random search) would be to keep randomly choosing values for x and y, and record the largest result found.  For many search spaces this is not efficient, so other more "intelligent" search techniques are used.  Particle swarm optimization is one such technique.  Particles are placed in the search space, and move through the space according to rules that take into account each particle's personal knowledge and the global "swarm's" knowledge.  Through their movement, particles discover particularly high values for f(x,y).

This model is closely based on the algorithm described by Kennedy and Eberhart's original paper (see reference below).  However, this model is meant to demonstrate the principle, rather than be an exact replica.  Some alterations were necessary to account for using a toroidal (wrapping) world, and to enhance the visualization of the swarm motion.  Also, the function being optimized is discrete (based on a grid of values), rather than continuous.

## HOW IT WORKS

Each particle has a position (xcor, ycor) in the search space and a velocity (vx, vy) at which it is moving through that space.  Particles have a certain amount of inertia, which keeps them moving in the same direction they were moving previously.
They also have acceleration (change in velocity), which depends on two main things.

1) Each particle is attracted toward the best location that it has personally found (personal best) previously in its history.

2) Each particle is attracted toward the best location that *any* particle has ever found (global best) in the search space.

The strength with which the particles are pulled in each of these directions is dependent on the parameters ATTRACTION-TO-PERSONAL-BEST and ATTRACTION-TO-GLOBAL-BEST.  As particles move farther away from these "best" locations, the force of attraction grows stronger.  There is also a random factor about how much the particle is pulled toward each of these locations.

In this model, the particle swarm is trying to optimize a function that is determined by the values in the discrete grid of cells shown in the view.  The landscape is created by randomly assigning values to each grid cell, then performing diffusion to smooth out the values, resulting in numerous local minima (valleys) and maxima (hills).  This function was chosen merely for illustrative purposes.  As a more plausible example of a real application of PSO, the variables (x,y,z,...) might correspond to parameters of a stock market prediction model, and the function f(x,y,z,...) could evaluate the model's performance on historical data.

The model runs until some particle in the swarm has found the "true" optimum value (which is 1.00).

## HOW TO USE IT

Press SETUP to initialize the fitness landscape and place the particles randomly in the space.  Each time you press SETUP, a different random landscape is created.

Press STEP (for one step) or GO to run the particle swarm optimization algorithm.

The LANDSCAPE-SMOOTHNESS slider determines how smooth of a landscape will be created when the SETUP button is pushed.

The POPULATION-SIZE slider controls the number of particles used.

The ATTRACTION-TO-PERSONAL-BEST slider determines the strength of attraction of each particle toward the location where it had previously found the highest value (in it's own history).

The ATTRACTION-TO-GLOBAL-BEST slider determines the strength of attraction of each particle toward the best location ever discovered by any member of the swarm.

The PARTICLE-INERTIA slider controls the amount to which particles keep moving in the same direction they have been (as opposed to being pulled by the forces of attraction).

The PARTICLE-SPEED-LIMIT slider controls the maximum rate of movement (in either the x or y directions) for each particle.  Although this feature is not always part of

The TRAILS-MODE chooser allows you to choose what kind of visualization you would like for the particles' paths (trails).  "Traces" means that particles will leave their paths indefinitely on the view.  "Tails" means that only the last step they took will be displayed.  "None" means that no particle paths will be shown.  Note that the display will not update until GO (or STEP) is run again.

The HIGHLIGHT-MODE chooser lets you see the best location anywhere in the search space ("True best") or the best location that the swarm has found ("Best found").  Note that the display will not update until GO (or STEP) is run again.

The BEST-VALUE-FOUND monitor displays the "global best" value of the swarm so far.  That is, what is the best value that has been found by any particle.  The maximum value it could reach is 1.0, at which point the simulation will stop.

## THINGS TO NOTICE

You will often see particles travelling in paths that are roughly elliptical.  Why do you think this is?  (Think about the major factors that influence the velocity of each particle.)

Sometimes the swarm quickly finds the "perfect" (value = 1.0) solution, and other times it becomes "stuck" in the wrong area of the search space, and looks like it may never find the perfect solution.  This notion of getting trapped near a "local maximum", when there is a better "global maximum" somewhere in the search space is a common problem that can arise in many optimization techniques (hill climbers, genetic algorithms, simulated annealing).  One variation of the PSO algorithm uses a repulsive force between particles to help keep them spread out in the space, and less likely to all gravitate to a suboptimal value.

## THINGS TO TRY

Turn HIGHLIGHT-MODE to "Best found", and run the simulation several times.  How often does the "Best found" location change?  Does is change more frequently at the beginning, or near the end of the simulation?

Try varying the PARTICLE-INERTIA slider.  When it's 0.0, the particles move solely based on the location of their "personal best" and the "global best", and not their movement history.  When it's 1.0, the particles velocities never change, resulting in straight-line movement.  Can you find an optimal value for the PARTICLE-INERTIA somewhere between these extremes?  Do you think the optimal value depends on other factors, such as the population size, the smoothness of the landscape, or the parameters of attraction?

## EXTENDING THE MODEL

Add a repulsive force between particles, to try to help prevent them all from prematurely converging on a small area of the search space.

The search space being explored in this model is meaningless --- just a random landscape of values that has been smoothed.  Change it to something more meaningful.

What happens if the function that is being optimized is changing over time?  That is, modify the model so that the particle swarm is trying to find the best solution in a dynamic environment, where the values of the grid cells are changing.  If the change isn't happening too quickly, can the swarm follow the maximum around as it moves through the space?

There are many other variations on PSO.  Try searching the web to learn more about some of them, or invent your own.

## NETLOGO FEATURES

Using combinations of built-in NetLogo primitives can avoid tricky "edge cases" in toroidal worlds.  When deciding how the velocity of each particle should change, we need some way to get a vector from each particle's location to another location in the world (the personal best or the global best).  In an unbounded 2D space, one could compute this vector by subtracting `(x-goal - xcor)` and `(y-goal - ycor)`.  However, that doesn't work in our wrapping (toroidal) world. (Why not?).  So, instead we use `facexy` to point the turtle in the correct direction, then `dx` and `dy` together give us a unit vector pointed towards the target, and we can multiply those by the `distancexy` to that location, to get a vector of the correct length.

## RELATED MODELS

Simple Genetic Algorithm, Artificial Neural Net, Perceptron, Hill Climbing Example (Code Example).

## CREDITS AND REFERENCES

Based on the algorithm presented in the following paper: Kennedy, J. & Eberhart, R. (1995), 'Particle swarm optimization', Neural Networks, 1995. Proceedings., IEEE International Conference on 4.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Stonedahl, F. and Wilensky, U. (2008).  NetLogo Particle Swarm Optimization model.  http://ccl.northwestern.edu/netlogo/models/ParticleSwarmOptimization.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2008 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2008 Cite: Stonedahl, F. -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
