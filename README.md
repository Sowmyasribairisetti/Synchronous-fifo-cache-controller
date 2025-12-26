# Synchronous-fifo-cache-controller
# Design and SystemVerilog Verification of FIFO & Cache Controller

## Overview
This project implements a parameterized Synchronous FIFO and a Direct-Mapped Cache Controller. It includes a complete SystemVerilog verification environment using interfaces, assertions (SVA), and functional coverage.

## Features
### FIFO Design
- **Parameterized**: Configurable `DATA_WIDTH` and `DEPTH`.
- **Status Flags**: Full and Empty generation using an extra pointer bit.
- **Protection**: Internal logic prevents overflow and underflow.

### Cache Controller
- **Architecture**: Direct-mapped cache.
- **Logic**: Hit/Miss detection based on valid bits and tag comparison.
- **Operations**: Synchronous read and write support.

## Verification Environment
The testbench (`tb_top.sv`) uses SystemVerilog constructs to ensure design correctness:
- **Interface**: Decouples the testbench from the design pins.
- **Assertions (SVA)**: Checks for illegal states like FIFO overflow.
- **Functional Coverage**: Measures how much of the design logic was exercised (Target: 75%+).
- **Monitor**: Real-time console logging of data movement.

## Simulation Results
The simulation was performed using Vivado XSim.

### FIFO Test
The FIFO correctly stored and retrieved data (`44, 44, 42, 1d, 58`) in order. A 1-cycle latency is observed due to the synchronous nature of the memory.

### Cache Test
Successfulfollowed by a "Cache Hit" and correct data retrieval (`aaaabbbb`).


## Tools Used
- **HDL**: Verilog (RTL)
- **HVL**: SystemVerilog (Testbench)
- **Simulator**: Vivado / ModelSim
