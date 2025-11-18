# Cache Controller

A hardware-level cache controller implemented in Verilog, designed to manage memory requests between the CPU, cache, and main memory. This project simulates cache hits, misses, valid bits, dirty bits, and replacement policies using a clean, modular finite state machine (FSM).

<p align="center">
  <img src="assets/banner/banner8.png" width="100%" alt="Project Banner">
</p>


---

## 🚀 Overview

This project models how a basic CPU cache controller works at the hardware level.  
It handles:

- Memory reads and writes  
- Checking for cache hits/misses  
- Updating valid and dirty bits  
- Managing block replacements  
- Communicating with main memory  

Useful for understanding low-level memory hierarchy, hardware design, and FPGA development flow.

---

## 🧩 Key Features

| Feature | Description |
|--------|-------------|
| **Cache Hit/Miss Logic** | Determines quickly whether data exists in cache. |
| **Finite State Machine (FSM)** | Manages transitions for reads, writes, and memory access. |
| **Dirty & Valid Bit Handling** | Ensures correctness during write-backs. |
| **SRAM/Main Memory Interface** | Simulates communication between levels of memory. |
| **Configurable Parameters** | Cache size, block size, associativity (if applicable). |
| **Fully Synthesizable** | Suitable for FPGA toolchains. |

---

## 🛠 Tech Stack

- **Verilog HDL**  
- **Hardware Simulation Tools:** ModelSim / Vivado / Quartus  
- **Target Platform:** Any FPGA board with enough logic resources  
- **Testing:** Behavioral simulation + waveform analysis

---

## 📂 Directory Structure

