# VHDL Timing Demonstrator

A small hands-on project for the basic FPGA development workflow using VHDL.
No physical FPGA board is required. GHDL and GTKWave run in Docker, so the
host does not need a local VHDL toolchain or waveform viewer. Edit sources
on the host, simulate in the `vhdl` container, then open GTKWave in a
browser.

## Purpose

The goal is to understand how hardware behavior is described in VHDL, how
clock-driven logic produces deterministic timing, and how that workflow
differs from compiling C/C++ and running it on a CPU.

```
VHDL source
    |
    v
Analysis / compilation
    |
    v
Simulation
    |
    v
Waveform generation
    |
    v
Timing analysis
```

A later hardware flow would continue through synthesis, place-and-route, and
bitstream generation. This demonstrator stops at simulation.

## Architecture

The timing controller is a synchronous block with three inputs and two outputs:

```
Clock  --------+
               |
Trigger -------+----> +-------------------+
                     | Timing Controller |
Reset ---------+----> |                   |
                     +---------+---------+
                               |
                     +---------+---------+
                     |                   |
                     v                   v
                  output_a            output_b
```

After a rising edge on `trigger`, the controller counts clock cycles:

| Signal     | Default timing                         |
|------------|----------------------------------------|
| `output_a` | one-cycle pulse 4 clocks after trigger |
| `output_b` | one-cycle pulse 8 clocks after trigger |

```
Clock cycle     0  1  2  3  4  5  6  7  8  9

Trigger         X
output_a                    X
output_b                                X
```

Cycle 0 is the clock edge that samples the rising trigger. Delays are VHDL
generics (`DELAY_A`, `DELAY_B`) so the offsets are easy to change.

A new trigger is ignored while a sequence is already running.

## Prerequisites

| Tool   | Where | Role                                              |
|--------|-------|---------------------------------------------------|
| Docker | Host  | Builds and runs the GHDL and GTKWave containers   |

GHDL, Make, and GTKWave are installed in the images, not on the host. Vendor
FPGA tools (Vivado, Quartus) are not required. Install Docker Desktop on
macOS; no other local tools are needed.

Two containers are used on purpose:

- `vhdl` is a small analysis/simulation image (GHDL + Make)
- `gtkwave` is a separate viewer with a virtual display and a browser
  frontend (noVNC), so it can stay running while you re-run simulations

## Build the images

From the repository root:

```bash
docker compose -f docker/compose.yml build
```

Project sources are bind-mounted at `/work` when a container starts.

## Analyze, test, and generate a waveform

All Make targets run inside the container:

```bash
docker compose -f docker/compose.yml run --rm vhdl make analyze
docker compose -f docker/compose.yml run --rm vhdl make elaborate
docker compose -f docker/compose.yml run --rm vhdl make test
docker compose -f docker/compose.yml run --rm vhdl make waveform
docker compose -f docker/compose.yml run --rm vhdl make clean
```

`make waveform` (the default `make` target) analyzes, elaborates, runs the
self-checking testbench, and writes `build/timing_controller.vcd`. That file
appears on the host because `build/` is on the mounted project directory.

The testbench applies reset, fires two complete trigger sequences, and
asserts that each output pulse occurs at the configured offset and lasts one
clock cycle.

## Waveform

After `make waveform`, start the GTKWave container and open it in a browser:

```bash
docker compose -f docker/compose.yml up gtkwave
```

Then visit [http://localhost:6080](http://localhost:6080). The session
connects automatically and loads `build/timing_controller.vcd` with `clk`,
`reset`, `trigger`, `output_a`, `output_b`, and the internal counter. Stop
the viewer with Ctrl+C.

You can leave GTKWave running and regenerate the VCD; use File → Reload
Waveform in GTKWave to pick up a new simulation.

The VCD includes at least:

- `clk`
- `reset`
- `trigger`
- `output_a`
- `output_b`

Internal signals such as `count` and `state` are also present and help show
how the sequence is generated.

Expected shape after reset is released:

```
clk       _|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_

trigger   ____|‾|____________________________

output_a  ________________|‾|________________

output_b  ________________________________|‾|
```

`output_a` rises four clock edges after the trigger is sampled; `output_b`
rises four edges after that. Each pulse is high for exactly one clock period.

To change the timing, edit the generics in
`src/timing_controller.vhd` (defaults) or the constants in
`test/timing_controller_tb.vhd` (the values used by the test), then run
`make waveform` again. The pulses should move to the new cycle offsets.

## VHDL concepts used

The design is intentionally small so each construct stays visible:

- `entity` / `architecture` and ports
- generics for configurable delays
- signals, including a delayed `trigger` used for edge detection
- `rising_edge(clk)` and synchronous reset
- a cycle counter
- a two-state controller (`IDLE` / `RUNNING`)
- concurrent clock generation in the testbench

The device under test never uses `wait for` to create delays. Timing comes
only from counting clock cycles. `wait` appears in the testbench to generate
stimulus and sample outputs, which is normal for simulation and is not
synthesizable hardware.

## Software vs FPGA development

A simplified software workflow compiles C/C++ to machine code that a CPU
executes instruction by instruction. Delays are often loops, sleeps, or
timers in software.

In this VHDL flow, the source describes concurrent hardware. Simulation
evaluates that description over simulated time and writes a waveform. The
same source could later be synthesized into registers and logic on an FPGA,
but that step is out of scope here.

The important observation: `output_a` and `output_b` are predictable relative
to the clock because they are produced by synchronous digital logic, not by
a program waiting in a thread.
