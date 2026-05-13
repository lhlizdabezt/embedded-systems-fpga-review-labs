# Embedded Systems FPGA Review Labs

Professional review workspace for Embedded Systems coursework, focused on SoPC design on Intel/Altera FPGA platforms. The repository combines Quartus Prime projects, Platform Designer/Qsys systems, Verilog custom IP, Nios II C applications, and a structured Typst review document for the main exam topics.

## Scope

This repository is organized around four practical themes:

- Master, Bus, and Slave concepts in Avalon-MM based SoPC systems.
- End-to-end embedded-system design flow with Quartus Prime, Platform Designer/Qsys, Nios II SBT, and FPGA programming.
- Practical lab projects for PIO-driven HEX displays, custom HEX IP, timer-based clock logic, and DMA transfer.
- Review notes and compiled study material for the Embedded Systems course.

## Repository Structure

| Path | Purpose |
| --- | --- |
| `Bai7/` | Timer and custom HEX IP lab using Nios II, Avalon-MM peripherals, switches, and six HEX displays. |
| `Bai8_new/` | DMA-oriented Nios II project with separate on-chip memories and interrupt-driven transfer flow. |
| `de1/` | Digital clock practice project using PIO, switches, and seven-segment display control from C. |
| `de2/` | Extended SoC clock design with custom Verilog registers, key reader, switch input, and HEX output IP. |
| `DeCuongOnTap_HTNhung/` | Typst source for the structured Embedded Systems review document. |
| `DeCuong_OnTap_LuongHaiLong.pdf` | Exported review document prepared for study and submission reference. |

## Technical Highlights

- Designs Avalon-MM systems where Nios II acts as the main bus master.
- Builds and integrates custom Avalon-MM slave IP blocks in Verilog.
- Uses C applications to access memory-mapped registers through `IORD` and `IOWR`.
- Demonstrates polling, timer interrupt, switch-controlled setup modes, and DMA interrupt handling.
- Keeps source files, project configuration, and review notes versioned while excluding generated build caches and bitstreams.

## Toolchain

- Intel Quartus Prime
- Platform Designer / Qsys
- Nios II Software Build Tools
- Verilog and SystemVerilog
- C for embedded bare-metal software
- Typst for technical documentation

## How To Use

1. Open the relevant `.qpf` project in Quartus Prime.
2. Inspect or regenerate the `.qsys` system with Platform Designer.
3. Rebuild the Quartus project to generate FPGA output files locally.
4. Regenerate the Nios II BSP from the current hardware system.
5. Build and run the C application from the corresponding `Software/` folder.

Generated folders such as `db/`, `incremental_db/`, `output_files/`, BSP build products, and bitstream files are intentionally excluded from Git. They should be recreated locally by the FPGA toolchain.

## Author Bio

**Luong Hai Long** is an Electronics and Telecommunications student focused on embedded systems, FPGA/Verilog design, C/C++, Python, artificial intelligence, Kaggle workflows, and practical hardware-software integration.
