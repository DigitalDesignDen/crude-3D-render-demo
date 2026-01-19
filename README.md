## Scope



A deliberately crude and experimental, but functional 3D graphics pipeline written in VHDL. Fixed-point math, matrix transforms, perspective projection, and basic rendering experiments targeting FPGA hardware. Built for learning, tinkering, and iterative improvement. Not pretty, not fast, but real hardware 3D — and a playground for improvement.

## crude-3D-renderer-demo

> A minimal and intentionally crude 3D graphics pipeline implemented in VHDL and running on an FPGA.

![Demo screenshot](images/icosphere_wireframe.png)



## Overview

This project is an experimental 3D renderer written entirely in **VHDL**, targeting low-cost FPGAs.
It implements a very simple graphics pipeline to explore what is *actually feasible* without CPUs,
GPUs, or softcores.

The focus is on **learning, experimentation, and clarity**, not performance or visual perfection.

---

## Features

* Fixed-point 3D math (no floating point)
* Model-view-projection pipeline
* Perspective projection
* Wireframe rendering
* Rotation via transformation matrices
* Rotation input via potentiometer + ADC an board OR rot input via counter
* HDMI / video output (FPGA-driven)

---

## Demo

|Rotating Cube|Icosphere|
|-|-|
|![cube](images/cube.gif)|![icosphere](images/icosphere.gif)|

---

## High-level pipeline

```text
3D Model (ROM)
   ↓
Matrix Transform
   ↓
Perspective Divide
   ↓
Screen Space Mapping
   ↓
Line Rasterization
   ↓
Video Output
```
---
## Project structure
./ <br>
 ├── supplemental/     &ensp;&nbsp;&nbsp;# Python and blender files for exporting verticies<br>
 ├── transform/      &emsp;&nbsp;&emsp;&nbsp;&nbsp;# Matrix-vector multiplication<br>
 ├── *.qpf          &ensp;&ensp;&nbsp;&emsp;&emsp;&emsp;&emsp;# Quartus project file<br>
 ├── *.qsf          &nbsp;&ensp;&ensp;&nbsp;&emsp;&emsp;&emsp;&emsp;# Some Quartus file<br>
 ├── *.sdc          &nbsp;&emsp;&emsp;&emsp;&emsp;&emsp;# Synopsys design contraint file (timing constraints)<br>
 ├── compile_wo_sta &ensp;# Batch file for command line compilation via Quartus II API (w/o static timing analysis)<br>
 ├── compile_w_sta  &emsp;# Batch file for command line compilation via Quartus II API (with static timing analysis)<br>
 └── *.vhd          &emsp;&emsp;&emsp;&emsp;&emsp;# VHDL source files

---
## Build / Simulation
* Target FPGA: Cyclone V (5CGXFC5C6F27) on Cyclone V GX Starter Kit
* Tested with Quartus II
* Tested only on Hardware
* No testbench coverage yet (wip)
---
## Compile Scripts

### compile_wo_sta.bat
The static timing analysis is skipped with this script.
```console
G:\altera\13.0sp1\quartus\bin64\quartus_map --read_settings_files=on --write_settings_files=off graphics_pipe -c graphics_pipe_top
G:\altera\13.0sp1\quartus\bin64\quartus_fit --read_settings_files=off --write_settings_files=off graphics_pipe -c graphics_pipe_top
G:\altera\13.0sp1\quartus\bin64\quartus_asm --read_settings_files=off --write_settings_files=off graphics_pipe -c graphics_pipe_top

G:\altera\13.0sp1\quartus\bin64\quartus_pgm -c USB-Blaster -o "p;.\output_files\graphics_pipe_top.sof" -m JTAG
```
This script needs to be modified to account for the path of your Quartus installation.

### compile_w_sta.bat

```console
G:\altera\13.0sp1\quartus\bin64\quartus_sh --flow compile graphics_pipe.qpf -c graphics_pipe_top

G:\altera\13.0sp1\quartus\bin64\quartus_pgm -c USB-Blaster -o "p;.\output_files\graphics_pipe_top.sof" -m JTAG
```
This script needs to be modified to account for the path of your Quartus installation.


---
### Limitations
* No Z-buffer
* No filled faces / triangles
* No clipping
* Sometimes precision artifacts due to fixed-point math
* ~~Choppy motion when depth changes (known issue)~~ fixed
* No frame buffer
* Line positions are computed in real time for each pixel with vector math -> low vertex count models only
---
### Roadmap / Ideas
* [ ] Line clipping
* [ ] Simple triangle fill
* [ ] Depth sorting
* [ ] Better fixed-point scaling strategy
* [ ] More control interfaces
* [ ] Frame buffer
* [ ] Line-drawing algorithm like Bresenham or Xiaolin Wu
