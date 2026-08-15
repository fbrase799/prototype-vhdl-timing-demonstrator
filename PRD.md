# VHDL Timing Demonstrator

## 1. Purpose

The VHDL Timing Demonstrator is a small hands-on project to explore and
demonstrate the basic FPGA development workflow using VHDL.

The focus is not on building a complex FPGA application, but on understanding:

- how hardware behavior is described in VHDL
- how clock-driven digital logic works
- how deterministic timing can be implemented
- how VHDL is analyzed and compiled
- how a VHDL design is simulated
- how a testbench drives the design
- how signal behavior can be inspected using waveforms
- how the VHDL workflow differs from traditional C/C++ software development

No physical FPGA board is required for the initial demonstrator.

The VHDL toolchain should run inside a Docker container so that no VHDL
development tools need to be installed directly on the host.


## 2. Learning Goals

After completing the demonstrator, I want to understand the basic VHDL
development workflow:

    VHDL Source
         |
         v
    Analysis / Compilation
         |
         v
      Simulation
         |
         v
    Waveform Generation
         |
         v
    Timing Analysis

The project should provide practical experience with the most important
concepts instead of only explaining them theoretically.

I also want to understand which parts of this workflow are simulation and
which additional steps would be required to deploy the design to a physical
FPGA.


## 3. Software vs. FPGA Perspective

One goal of the demonstrator is to understand the conceptual difference
between traditional software development and FPGA development.

A simplified software workflow is:

    C / C++
       |
       v
    Compiler
       |
       v
    Machine Code
       |
       v
    CPU executes instructions

For the initial VHDL demonstrator, the workflow is:

    VHDL
       |
       v
    Analysis / Elaboration
       |
       v
    Simulation
       |
       v
    Waveform

A later FPGA hardware workflow would additionally include:

    VHDL
       |
       v
    Synthesis
       |
       v
    Logic / Registers
       |
       v
    Place & Route
       |
       v
    Bitstream
       |
       v
    FPGA Hardware

The initial demonstrator focuses on the simulation workflow.


## 4. Demonstrator

Implement a small clock-driven timing controller.

The controller receives:

- a clock signal
- a reset signal
- a trigger signal

After receiving a trigger, the controller generates two deterministic output
pulses.

Conceptually:

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

The output signals occur at defined clock-cycle offsets after the trigger.


## 5. Example Timing Behavior

For the initial implementation:

- `trigger` starts a timing sequence
- `output_a` becomes active after 4 clock cycles
- `output_b` becomes active after 8 clock cycles
- each output pulse remains active for one clock cycle

The exact timing values should be easy to change.

Example:

    Clock cycle     0  1  2  3  4  5  6  7  8  9

    Trigger         X
    output_a                    X
    output_b                                X

The resulting timing should be clearly visible in the simulation waveform.


## 6. VHDL Concepts

The demonstrator should provide hands-on experience with:

- entity
- architecture
- ports
- signals
- clock signals
- `rising_edge(clk)`
- synchronous logic
- reset handling
- counters
- simple control logic
- concurrent signal behavior

The implementation should remain small enough that every important VHDL
construct can be understood individually.


## 7. Deterministic Timing

A central aspect of the demonstrator is deterministic timing.

The timing controller should not express delays as software waiting operations.

Instead, timing is derived from clock cycles.

For example:

    Trigger
       |
       | 4 clock cycles
       v
    output_a
       |
       | 4 additional clock cycles
       v
    output_b

This should demonstrate how synchronous digital logic can produce predictable
behavior relative to a hardware clock.


## 8. Testbench

Create a VHDL testbench for the timing controller.

The testbench should:

- generate the clock
- apply reset
- generate trigger events
- observe the output signals
- run for a defined simulation time

The testbench should allow the complete demonstrator to run without physical
hardware.

At least one complete timing sequence should be exercised.


## 9. Waveform

The simulation should generate a waveform file.

The waveform should show at least:

- `clk`
- `reset`
- `trigger`
- `output_a`
- `output_b`

If useful for understanding the implementation, internal signals such as the
counter or controller state can also be included.

The waveform should make it easy to verify that the output pulses occur at the
expected clock boundaries.

Conceptually:

    clk       _|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_

    trigger   ____|‾|____________________________

    output_a  ________________|‾|________________

    output_b  ________________________________|‾|


## 10. Docker-Based Toolchain

The VHDL development and simulation toolchain should run inside Docker.

The host should not require a local installation of GHDL.

The container should provide:

- GHDL
- Make
- required shell utilities
- VHDL analysis and elaboration
- VHDL simulation
- waveform generation

The project directory is mounted into the container.

Conceptually:

    Host / VS Code
         |
         | project directory
         v
    +--------------------------------+
    | Docker Container               |
    |                                |
    |  VHDL Source                   |
    |       |                        |
    |       v                        |
    |  GHDL Analyze                  |
    |       |                        |
    |       v                        |
    |  GHDL Elaborate                |
    |       |                        |
    |       v                        |
    |  GHDL Simulation               |
    |       |                        |
    |       v                        |
    |  Waveform Generation           |
    |                                |
    +---------------+----------------+
                    |
                    | mounted build directory
                    v
              build/waveform.vcd

The generated waveform is therefore directly available on the host.


## 11. Waveform Viewer

The waveform viewer does not initially need to run inside the Docker
container.

The preferred separation is:

    Docker
       |
       | generates
       v
    waveform.vcd
       |
       v
    Host Waveform Viewer

This avoids unnecessary GUI forwarding from Docker to macOS.

GTKWave or another suitable waveform viewer can be used on the host.

If a convenient browser-based or containerized waveform viewer is identified
later, it may be added as an optional extension.


## 12. Docker Image

Provide a `Dockerfile` containing the complete VHDL simulation toolchain.

The image should:

- use a suitable Linux base image
- install GHDL
- install Make
- contain no project-specific source code
- use the mounted project directory as its workspace
- be reproducible from the `Dockerfile`

The container should be treated as a development toolchain rather than as an
application runtime.


## 13. Docker Compose

Provide a Docker Compose configuration to simplify use of the development
container.

The Compose configuration should:

- build the VHDL toolchain image
- mount the project directory into the container
- set the project directory as working directory
- allow Make targets to be executed inside the container

Example usage:

    docker compose -f docker/compose.yml build

    docker compose -f docker/compose.yml run --rm vhdl make analyze

    docker compose -f docker/compose.yml run --rm vhdl make test

    docker compose -f docker/compose.yml run --rm vhdl make waveform


## 14. Build and Execution

The complete VHDL workflow should execute inside the Docker container.

The intended workflow is:

    VHDL source
        |
        v
      Analyze
        |
        v
     Elaborate
        |
        v
    Run simulation
        |
        v
    Generate waveform
        |
        v
    Store waveform in build/

The host is responsible only for:

- editing source files
- starting Docker
- inspecting generated artifacts
- displaying the waveform

The `Makefile` should hide unnecessary GHDL command-line details while still
providing separate targets so that the individual development steps can be
explored.


## 15. Make Targets

The project should provide at least the following Make targets:

### `make analyze`

Analyze the VHDL source and testbench.

This step should demonstrate the VHDL analysis/compilation stage.

### `make elaborate`

Elaborate the testbench design.

This should demonstrate the step between VHDL analysis and simulation.

### `make test`

Run the testbench simulation.

### `make waveform`

Run the simulation and generate the waveform file.

Expected output:

    build/timing_controller.vcd

### `make clean`

Remove generated simulation and build artifacts.


## 16. Project Structure

Initial project structure:

    vhdl-timing-demonstrator/
    |
    +-- PRD.md
    +-- README.md
    +-- Makefile
    +-- Dockerfile
    +-- .gitignore
    |
    +-- docker/
    |   +-- compose.yml
    |
    +-- src/
    |   +-- timing_controller.vhd
    |
    +-- test/
    |   +-- timing_controller_tb.vhd
    |
    +-- build/
        +-- generated simulation artifacts

Generated files in `build/` should not be committed to Git.


## 17. Development Workflow

The intended development workflow is:

1. Edit VHDL source code on the host using VS Code or another editor.
2. Build the Docker toolchain if necessary.
3. Run GHDL analysis inside Docker.
4. Fix VHDL syntax or semantic errors.
5. Elaborate the design.
6. Run the testbench.
7. Generate the waveform.
8. Inspect the waveform.
9. Modify the VHDL implementation.
10. Repeat the simulation and compare the resulting timing behavior.

This should provide a short feedback cycle without requiring a physical FPGA.


## 18. Documentation

The `README.md` should eventually document:

- purpose of the demonstrator
- architecture of the timing controller
- Docker prerequisites
- build instructions
- GHDL analysis and elaboration
- simulation instructions
- waveform generation
- explanation of the resulting waveform
- key observations about VHDL and FPGA development

A screenshot of the final waveform can be added to the documentation.


## 19. Out of Scope

The initial demonstrator does not include:

- physical FPGA hardware
- Xilinx Vivado
- Intel Quartus
- production FPGA development
- complex DSP algorithms
- high-speed communication interfaces
- CPU/FPGA communication
- operating systems
- vendor-specific FPGA IP
- advanced timing constraints
- production-level verification
- complex VHDL frameworks
- graphical Linux applications inside Docker

The objective is to understand the fundamental VHDL workflow first.


## 20. Definition of Done

The initial demonstrator is complete when:

- the Docker image can be built successfully
- no local GHDL installation is required
- the VHDL timing controller can be analyzed successfully with GHDL
- the testbench can be analyzed and elaborated
- the simulation runs without errors
- a waveform file is generated in `build/`
- the waveform is accessible from the host
- the waveform contains clock, reset, trigger and output signals
- `output_a` occurs at the configured clock offset
- `output_b` occurs at the configured clock offset
- changing the timing values results in predictable waveform changes
- the basic VHDL constructs used in the implementation are understood
- the difference between simulation and execution on physical FPGA hardware
  can be explained


## 21. Possible Next Steps

After completing the initial demonstrator, possible extensions are:

1. Add a finite-state machine.
2. Make timing parameters configurable.
3. Generate multiple signals concurrently.
4. Add overlapping or repeated trigger events.
5. Explore VHDL synthesis.
6. Inspect the synthesized hardware structure.
7. Introduce FPGA timing constraints.
8. Run the design on a physical FPGA development board.
9. Explore communication between CPU software and FPGA logic.