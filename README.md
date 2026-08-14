# Nand2Tetris Hack Computer in Synthesizable VHDL

## Overview

This project is a synthesizable VHDL implementation of the **Hack computer architecture** described in *The Elements of Computing Systems: Building a Modern Computer from First Principles* by Noam Nisan and Shimon Schocken.

The design follows the Hack architecture closely and is capable of executing programs written in the Hack assembly language. All major computer components are implemented as synthesizable VHDL, including the ALU, program counter, CPU, memory, ROM, and top-level computer system.

The design was developed and tested using AMD Vivado Design Suite (2024.2) and implemented on a Digilent Arty Z7-20 FPGA development board. The design can be adapted to other FPGA platforms, although the clocking, pin assignments, VGA interface, and other board-specific constraints will need to be modified accordingly.

The project includes:

* Synthesizable VHDL implementations of the Hack computer components
* FPGA implementation of the complete computer
* VGA output
* UART-based keyboard input
* A pre-loaded working sample Hack program of Conway's Game of Life (see Third-Party Sources and Attribution section)
* Support for loading and executing different Hack assembly programs

The original simulation-only version of the design that preceded this project is available here:
https://github.com/stefobillis-spec/ALU-design-in-VHDL

---

## Architecture

The project is organized into individual RTL components that correspond to the major components of the Hack computer.

The primary design components are:

* **ALU** — Performs arithmetic and logical operations
* **Program Counter (PC)** — Stores and updates the current instruction address
* **CPU** — Decodes and executes Hack instructions
* **Memory** — Provides the Hack RAM address space, integrates the RAM 16K and screen, and interfaces with I/O
* **RAM16K** - The primary portion of the memory
* **Screen** - Portion of the memory responsible for controlling the screen (acting as VRAM)
* **ROM** — Stores the program instructions
* **VGA Controller** — Provides video output for the Hack screen
* **UART** — Provides serial input/output
* **Debouncer** — Conditions the physical reset input
* **Computer** — Integrates the CPU, memory, and ROM

The project also makes use of a block design that incorporates the computer modules, the UART modules, the VGA controller,
debouncer, clocking wizard, and an optional ILA.

The design uses a 40 MHz system clock for the main computer logic and a 25 MHz clock for the VGA interface.

### Repository Structure

```text
sources/
    ALU.vhd
    PC.vhd
    CPU.vhd
    Memory.vhd
    ROM.vhd
    ...    
Third Party Sources/
    ...
    
conv_to_VHDL.py
THIRD_PARTY_NOTICES.md
LICENSE
README.md
```

The exact contents of the directories may change as the project develops.

---

# Building and Running the Design

## Requirements

### Software

* AMD Vivado Design Suite
* Tera Term or another serial terminal program
* Python 3.x (only required if using `conv_to_VHDL.py` to convert Hack machine code into VHDL format)

### Hardware

The reference implementation was developed using:

* Digilent Arty Z7-20 with the Zynq-7000 SoC
* Digilent VGA PMOD
* 1080p monitor with VGA input
* Digilent USB-to-UART adapter PMOD
* USB connection to the development computer

The design can be ported to another FPGA development board, but the following may need to be modified:

* Clock input frequency
* Clocking Wizard configuration
* XDC constraints
* VGA pin assignments
* UART pin assignments
* Reset/button pin assignments

Note: The Arty Z7's onboard USB-UART interface is connected to the Zynq processing system. Because this project does not use the Zynq processing system or Vitis, a separate USB-to-UART adapter is used for the UART interface.

---

## FPGA Implementation

### Step 1 — Create the Vivado Project

Create a new Vivado project targeting your FPGA device.

Add the VHDL files from the `sources` directory as design sources.

Also add the UART source files from `Third Party Sources`.

Do not add `design_1_wrapper.vhd` at this stage. This file is generated later by Vivado from the block design.

After adding the source files, the Design Sources hierarchy should resemble:

![Vivado Design Sources hierarchy](https://github.com/user-attachments/assets/e76d1f6d-c868-4bc8-846c-e4094f5e7c58)
Note: originally the Debouncer.vhd file was called Top.vhd, so in the image Top.vhd is the debouncer file.

---

### Step 2 — Create the Block Design

Create a new Vivado Block Design and add the required RTL modules.

Connect the modules according to the following reference design:

![Vivado block design](https://github.com/user-attachments/assets/3bbdfb0d-e7e0-4b21-82a3-4cb7b7b8282f)

Add a **Clocking Wizard** connected to the board's clock source and configure the outputs as follows:

Connect the external interfaces as follows:

* `button` from `Debouncer.vhd` to a physical reset button
* `UART_RXD` from `UART.vhd` to the physical UART RX input
* `UART_TXD` from `UART.vhd` to the physical UART TX output
* VGA controller outputs to the physical VGA interface

The **Integrated Logic Analyzer (ILA)** is optional. It can be included for debugging or for observing internal signals while the design is running on the FPGA.

---

### Step 3 — Generate the HDL Wrapper and Implement

Generate the HDL wrapper for the Block Design.

Add the appropriate **Xilinx Design Constraints (`.xdc`)** file.

A constraint file for the reference Arty Z7-20 configuration is included in the repository. If using a different board or hardware configuration, create or modify the constraints accordingly.

Next run synthesis, implementation, and bitstream generation. Program the FPGA with the generated bitstream.

---

### Step 4 — Configure the UART

Open Tera Term and create a serial connection to the USB-to-UART adapter.

Configure the serial port speed to 115200 baud

Use the default UART configuration implemented by the provided UART module for the remaining serial settings.

Once connected, keyboard input entered through Tera Term can be received by the Hack computer through the UART interface.

---

# Running Other Hack Assembly Programs

The program executed by the computer is stored in `ROM.vhd`.

To run a different Hack assembly program, the ROM contents must be replaced with the corresponding 16-bit Hack machine instructions.

## Step 1 — Assemble the Program

Create or open a Hack assembly program using the [Nand2Tetris online IDE](https://nand2tetris.org/).

Open the Assembler and load or create the desired `.asm` program.

Run the assembler and select Translate All.

The resulting output consists of the 16-bit binary machine instructions that will be loaded into the FPGA ROM.

---

## Step 2 — Convert the Machine Code to VHDL Format

The repository includes `conv_to_VHDL.py`, which can be used to convert the assembler output into a format suitable for the `ROM.vhd` initialization array.

Run the program then paste the generated machine code into the program when prompted. Next, enter the total number of instructions 
in the program.

The script will format the instructions as VHDL values, separated by commas and arranged in columns of five instructions.

Copy the generated output into the ROM initialization array in `ROM.vhd`.

---

## Step 3 — Update the ROM Length

**Important:** Update the `data_length` constant in `ROM.vhd` to match the total number of instructions in the new program, because
The ROM size must be large enough to contain every instruction in the program.

For example, if the program contains 0 to 127 instructions:

```vhdl
constant data_length : integer := 127;
```

---

## Step 4 — Rebuild the FPGA Design

After modifying `ROM.vhd`:

1. Save the file.
2. Run synthesis again.
3. Run implementation again.
4. Generate a new bitstream.
5. Program the FPGA with the new bitstream.

The FPGA will then execute the newly loaded Hack program after reset.

---

# Third-Party Sources and Attribution

This project incorporates and adapts code, documentation examples, educational material, and AI-generated code from external sources.

Third-party material is not covered by the license for the author's original work unless its respective license permits it.

See [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for complete attribution, source links, modification information, and applicable licensing information.

Major external sources include:

* Jakub Cabal's FPGA UART implementation
* AMD Vivado UG901 VHDL synthesis examples
* A community-created Nand2Tetris/Hack implementation of Conway's Game of Life by Robert Woodhead
* Anthropic Claude-generated HDL
* The Nand2Tetris Hack architecture

---

# License

Original work in this repository is licensed under the **MIT License**. See [`LICENSE`](LICENSE) for the full license text.

Third-party source code and other external material remain subject to their respective licenses and terms. See [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for details.
