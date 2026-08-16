# Third-Party Notices

This file documents third-party source code, documentation, educational material, architectural references, and AI-assisted code used in this project.

This project is a personal, non-commercial engineering project. The presence of third-party material in this repository does not imply endorsement by the original authors, organizations, or service providers.

The project contains material under different licenses. The license that applies to the author's original work does **not** replace or override the licenses applicable to third-party material. Because of this, please consult the notices below before reusing individual files.

---

## 1. UART Controller — Jakub Cabal

**Source:**  
https://github.com/jakubcabal/uart-for-fpga

**Author:** Jakub Cabal

**License:** MIT License

The UART controller used in this project was copied from the above repository. The original UART source code was incorporated into this project essentially unchanged, with the exception of changing the `CLK_FREQ` generic in the main `UART.vhd` module from 50 MHz to 40 MHz to match the clock used by this project.

The original project describes itself as a VHDL 93 UART controller for FPGA applications and identifies its source code as being available under the MIT License.


---

## 2. Conway's Game of Life Program — Community-Created Nand2Tetris Program

**Source:**  
https://www.dropbox.com/scl/fi/2s70n3rnq8jokiqhsgwxr/Nand2Tetris-Life.zip?e=2&file_subpath=%2FNand2Tetris-Life%2FLife.asm&rlkey=6iw0fdgapcliz4vzmr17i3xv2&dl=0

**Author:** Robert Woodhead

**License:** Creative Commons Attribution License, according to the original source.

The `Life.asm` program was created as a learning project and is not part of the official Nand2Tetris course materials. The program was incorporated into this project for demonstration purposes.

The version included in this repository has been substantially modified from the original program.

The original creator retains authorship of the original program. This repository does not claim the original program as original work by the project author.


---

## 3. AMD Vivado Synthesis Documentation — UG901

The project uses and adapts VHDL coding examples from AMD's *Vivado Design Suite User Guide: Synthesis (UG901), Version 2024.2*.

The following examples were used:

1. **ROM Inference on an Array — VHDL**  
   https://docs.amd.com/r/2024.2-English/ug901-vivado-synthesis/ROM-Inference-on-an-Array-VHDL

2. **Single-Port RAM with Asynchronous Read — VHDL**  
   https://docs.amd.com/r/2024.2-English/ug901-vivado-synthesis/Single-Port-RAM-with-Asynchronous-Read-Coding-Example-VHDL

3. **Block RAM with Optional Output Registers — VHDL**  
   https://docs.amd.com/r/2024.2-English/ug901-vivado-synthesis/Block-RAM-with-Optional-Output-Registers-VHDL

**Source:** Advanced Micro Devices, Inc. (AMD): *Vivado Design Suite User Guide: Synthesis (UG901), Version 2024.2*

The above examples were used primarily to implement and infer FPGA ROM, distributed RAM, and block RAM structures using Vivado synthesis-compatible VHDL coding styles.

**License/copyright:** These examples are part of AMD's Vivado documentation. This project does not assert ownership of the original AMD examples. AMD's documentation and associated intellectual property remain the property of AMD and its licensors.


---

## 4. AI-Assisted Code — Anthropic Claude

**Source:** Anthropic Claude
https://claude.ai/share/9a0828fb-e4d3-4ef5-a873-4b98a7220f66

A complete HDL module used in this project was generated specifically for this project through a prompt provided to Anthropic Claude.

The generated module was incorporated into the project with only a minor modification: one line of the generated code was changed. The remainder of the module was copied into the project substantially as generated.

This notice is included for transparency regarding the development process. The module should not be represented as entirely hand-written by the project author.

**Attribution:** Anthropic Claude was used as an AI coding assistant in the creation of this module. The project author reviewed and integrated the generated code and made subsequent modifications.

---

## 5. Nand2Tetris / Hack Computer Architecture

**Project reference:**  
https://www.nand2tetris.org/

**License:** Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported (CC BY-NC-SA 3.0)
https://www.nand2tetris.org/license

The architecture of this project is based closely on the Hack computer architecture developed as part of the Nand to Tetris project.

The project follows the Hack architecture as closely as practical, including its fundamental CPU organization and instruction-set architecture. The implementation in this repository is an independent HDL implementation developed for this project.

This project should not be interpreted as an official Nand2Tetris implementation, submission, or endorsed project.

The Nand2Tetris project states that its official materials and tools are protected under the CC BY-NC-SA 3.0 license. It also requests that students and self-learners not publicly post solutions to the Nand2Tetris projects on the web.

---

## 6. Original Work in This Repository

Unless otherwise identified in this notice, the project author claims authorship of the original design work, HDL integration, system architecture decisions, modifications, testbench work, FPGA implementation work, documentation, and other original material contained in this repository.

Third-party material remains subject to its respective license and attribution requirements.

Where a source was copied or adapted, this notice identifies the source rather than representing the corresponding material as wholly original.

---

## 7. Disclaimer

This file is intended to provide clear attribution and provenance information for an educational/personal engineering project. It is not legal advice.

Where the licensing status of a source is uncertain, the original source and its applicable license or terms should be consulted directly.

Last updated: August 2026
