# Composed foundation Gate 2D: client Acoustic Propagation

This throwaway prototype asks whether Steam Audio 4.8.1 can remain behind a
Sacramento interface while a client presents one spatial Acoustic Propagation
event at a Sacramento-owned authoritative arrival timestamp. It also checks
that the Debian Session Authority binary has no client-audio dependency.

The authority emits the exact `sacramento.acoustic-event.v1` fixture. The
client gives Steam Audio a wall mesh and acoustic material, then uses its
direct simulation for distance attenuation, raycast occlusion, transmission,
and binaural spatialization into deterministic offline PCM. Steam Audio does
not calculate or alter authoritative time, canonical state, physical force, or
Blast Overpressure. Reflections, pathing, a real-time mixer, and native audio
device integration remain outside this narrow gate.

Run the complete proof from a fresh output root:

```sh
SACRAMENTO_GATE2D_ROOT=/tmp/sacramento-composed-foundation-gate2d \
  prototypes/composed_foundation_gate2d/run-gate2d.sh
```

This evidence belongs only on `prototype/composed-foundation-spine`; it is not
production implementation and must not merge into `develop`.
