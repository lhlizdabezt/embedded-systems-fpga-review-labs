<p align="center">
  <img src="https://raw.githubusercontent.com/lhlizdabezt/embedded-systems-fpga-review-labs/main/assets/fpga-review-motion.svg" alt="Animated FPGA SoPC review pipeline" />
</p>

<h1 align="center">⚡ Embedded Systems FPGA Review Labs ⚡</h1>

<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Inter&weight=700&size=24&pause=900&color=2563EB&center=true&vCenter=true&width=900&lines=Verilog+Custom+IP+%7C+Avalon-MM+SoPC+%7C+Nios+II+C;Quartus+Prime+%7C+Platform+Designer+%7C+PIO+Timer+DMA;Professional+FPGA%2FEmbedded+Systems+Review+Workspace" alt="Animated FPGA review headline" />
</p>

<p align="center">
  <a href="https://github.com/lhlizdabezt/embedded-systems-fpga-review-labs/releases/tag/v1.0.0"><img src="https://img.shields.io/badge/Release-v1.0.0-0f766e?style=for-the-badge" alt="Release v1.0.0" /></a>
  <img src="https://img.shields.io/badge/FPGA-DE10--Standard-2563EB?style=for-the-badge" alt="DE10-Standard FPGA" />
  <img src="https://img.shields.io/badge/Bus-Avalon--MM-D95319?style=for-the-badge" alt="Avalon-MM" />
  <img src="https://img.shields.io/badge/Firmware-Nios%20II%20C-334155?style=for-the-badge" alt="Nios II C" />
  <img src="https://img.shields.io/badge/Docs-Typst-239DAD?style=for-the-badge" alt="Typst documentation" />
</p>

> Professional review workspace for Embedded Systems coursework, focused on SoPC design on Intel/Altera FPGA platforms. The repository turns lab folders into a readable engineering artifact: source code, hardware systems, firmware examples, and a structured review document.

## 🧭 Engineering Signal

| What this proves | Evidence in repo |
| --- | --- |
| FPGA/SoPC workflow | Quartus `.qpf/.qsf`, Platform Designer `.qsys`, generated system wrappers |
| Hardware/software integration | Nios II C apps using memory-mapped IO through `IORD` / `IOWR` |
| Custom IP design | Verilog Avalon-MM slave blocks, HEX display drivers, switch/key register interfaces |
| Embedded timing/control | PIO, timer interrupt flow, setup modes, clock logic, DMA transfer practice |
| Documentation maturity | Typst review source plus compiled `DeCuong_OnTap_LuongHaiLong.pdf` |

## 📂 Repository Map

| Path | Purpose |
| --- | --- |
| `Bai7/` | Timer and custom HEX IP lab using Nios II, Avalon-MM peripherals, switches, and six HEX displays. |
| `Bai8_new/` | DMA-oriented Nios II project with separate on-chip memories and interrupt-driven transfer flow. |
| `de1/` | Digital clock practice project using PIO, switches, and seven-segment display control from C. |
| `de2/` | Extended SoC clock design with custom Verilog registers, key reader, switch input, and HEX output IP. |
| `DeCuongOnTap_HTNhung/` | Typst source for the structured Embedded Systems review document. |
| `DeCuong_OnTap_LuongHaiLong.pdf` | Exported review document prepared for study and submission reference. |

## 🛠️ Technical Stack

<p align="center">
  <img src="https://img.shields.io/badge/Intel%20Quartus-Prime-2563EB?style=flat-square" alt="Intel Quartus Prime" />
  <img src="https://img.shields.io/badge/Platform%20Designer-Qsys-0f766e?style=flat-square" alt="Platform Designer Qsys" />
  <img src="https://img.shields.io/badge/Verilog-Custom%20IP-334155?style=flat-square" alt="Verilog custom IP" />
  <img src="https://img.shields.io/badge/C-Nios%20II%20SBT-D95319?style=flat-square" alt="Nios II Software Build Tools" />
  <img src="https://img.shields.io/badge/Typst-Review%20Notes-239DAD?style=flat-square" alt="Typst review notes" />
</p>

- **Hardware design:** Avalon-MM bus systems, PIO, timer, DMA, custom slave peripherals.
- **Firmware:** bare-metal C applications for register access, polling, interrupt handling, and display control.
- **Documentation:** review notes aligned with Master/Bus/Slave concepts, SoPC flow, and lab-level implementation details.
- **Portfolio practice:** generated caches and bitstreams are excluded so the repo stays reviewable and reproducible.

## 🚀 How To Rebuild Locally

1. Open the relevant `.qpf` project in Intel Quartus Prime.
2. Inspect or regenerate the `.qsys` design with Platform Designer/Qsys.
3. Rebuild the Quartus project and regenerate output files locally.
4. Regenerate the Nios II BSP from the current hardware system.
5. Build and run the matching C application inside the corresponding `Software/` folder.

Generated folders such as `db/`, `incremental_db/`, `output_files/`, BSP build products, and bitstream files are intentionally excluded from Git. Recreate them locally with the FPGA toolchain.

## 🏷️ Release

- **`v1.0.0`** - initial professional portfolio release for the FPGA/SoPC review labs.
- Includes Quartus/Platform Designer source structure, Verilog IP, Nios II C examples, Typst review source, and the exported review PDF.

## 👤 Author

**Lương Hải Long** - Electronics and Telecommunications student at HCMUS, focused on Verilog/FPGA design, embedded systems, C/C++, Python automation, AI, Kaggle, IPYNB notebooks, and practical hardware-software integration.

<p align="center">
  <b>⚙️ FPGA/SoPC • Embedded Systems • Digital Logic • Documentation-first Engineering</b><br />
  <samp>From lab folders to reviewable engineering evidence.</samp>
</p>
