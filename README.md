# Nannd2tetris Hack Computer Emulated with Synthesizable VHDL Code

* **Description:** This project is based on the Hack computer described in "The Elements of Computing Systems: Building a Modern Computer from First Principles" by Noam Nisan and Shimon Schocken. The computer architecture is very similar to the Hack computer, and it can run Hack assembly machine code. All of the components are designed in VHDL, can be simulated in any hardware design platform such as AMD Vivado or Intel Quartus, and are synthesizable. This project is perfect for educational demonstration purposes or to help learn digital design. In the "Design Sources" folder of this repository are the designs of the ALU, program counter, CPU, Memory, ROM, and the full computer design. In the "Simulations" folder are the simulations of each of the corresponding components. Note: simulation.vhd is the simulation for the ALU. Initial version of this project can be found here https://github.com/stefobillis-spec/ALU-design-in-VHDL


**Running the Design:** You will need Vivado Design Suite to synthesize and implement the design on an FPGA. I used a Digilent Arty Z7-20 with the Zynq 7000, however any AMD FPGA or SOC will work. Note: if using a different part, the contraints would be different. I also used a full HD 1080P monitor and I ran it through VGA. For the keyboard function a board with UART is needed. I had to use a separate USB to UART module because the one on my Arty Z7 is connected to the PS of the Zynq, and I wanted to avoid using Vitis for this project. To capture inputs from my laptop keyboard I used Tera Term. 

*STEP 1:* Download all of the VHDL files from the sources folder (except for design_1_wrapper.vhd which is there for reference) and all the UART files from the Third Party Sources folder. Open a new project in Vivado and add all of them as design sources. After all the files are added, the Design Sources Hierarchy should look like the following figure. Note: The design_1_wrapper.vhd will be created later on so it won't be there yet. Also, the Debouncer.vhd file is the Top.vhd file in the screen shot.

*STEP 2:* Create a new block diagram. Add the Modules to the design and connect them as seen in the following figure. Add a clocking wizard connected to your clock source. Make clk_out1 40MHz and clk_out2 25MHz. The "button" input from Debouncer.vhd will be mapped to your reset switch. The UART_RXD input from UART.vhd will be mapped to the RX pin on your physical board and the UART_TXD output to the TX pin. The vga_controller.vhd outputs will be connected to your physical VGA driver. 
The ILA is optional, but you may include it for debugging purposes, or to see the design running in real time. 

*STEP 3:* Generate the design wrapper of the block diagram. Add a contraints file. You can use the one provided if you are using the same board and setup as me, or create your own. Proceed to run synthesis, implementation, and generate the bitstream. Program your device.

*STEP 4:* Turn on Tera Term  and set the connection to serial. Then go to Setup>Serial Port>Speed and change it to 115200. 


**Running other Hack Assembly Programs**
If you would like to try running other Hack Assembly programs on this design then you will have to change the ROM.vhd file. First go to the nand2tetris online ide, navigate to the assembler, copy or create your program in Hack assembly. Then press the translate all button to generate the desired 16-bit machine code. That is the code which must be copied into the ROM.vhd file. (To better format it, included is a conv_to_VHDL.py file. Run it, paste the machine code in the input, and input the total number of instructions. The program will spit out all of your machine code separated by comas and in columns of 5.) After you have copied the instructions into the ROM.vhd, save it, and rerun synthesis and implmenetation. 
IMPORTANT: Make sure that the data_length constant in ROM.vhd is updated to the number of instructions your program has!!!


**Licences**
This project is MIT licence. All licence information regarding reused code is included in Third-Party_Notice.md.