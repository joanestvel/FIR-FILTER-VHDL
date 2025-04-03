# FIR Filter Implementation

This repository contains the VHDL implementation of a configurable FIR filter designed to work with an external memory. The filter can be set to order 4 or 6 and operates symmetrically (using past and future samples). The coefficients for the filter are stored in an external memory.

## Project Hierarchy
```
project_reti_logiche
|
├── d12_d60
│   └── s010_s100
├── Sat
├── Add_Gen
├── FSM
```
- **Add_Gen**: Generates memory addresses.
- **Sat**: Saturation block to ensure that values remain within the valid range (8-bit signed, two’s complement).
- **FSM**: Moore state machine that coordinates data storage, memory reads, address generation, and data writing.
- **s010_s100**: Auxiliary component used within d12_d60 to handle calculations when inputs are negative.
- **d12_d60**: Divides a value by 12 or 60 depending on the filter order, normalizing data amplitude.

## Input Signals
- **i_Add (16-bit)**: Base memory address where data is stored.
- **i_clk (1-bit)**: Clock signal.
- **i_rst (1-bit, active high)**: Reset signal.
- **i_start (1-bit)**: Start signal to begin filter processing.
- **i_mem_data (8-bit)**: Data input from memory.

## Output Signals
- **o_done (1-bit)**: Indicates when processing and data storage are complete.
- **o_mem_addr (16-bit)**: Memory address for reading or writing data.
- **o_mem_data (8-bit)**: Data output to memory.
- **o_mem_we (1-bit)**: Write enable signal for memory storage.
- **o_mem_en (1-bit)**: Memory enable signal for reading or writing.

## How to Use
1. Set **i_rst** high, then bring it low to reset the system.
2. Set **i_start** high to begin processing. Keep it high until **o_done** goes high.
3. Once **o_done** is high, bring **i_start** low to restart the process.

### Memory Data Structure
The system reads and writes data following this format:
1. **Signal size (2 bytes)**: Most significant byte first.
2. **Filter order (1 byte)**: `0` for order 4, `1` for order 6.
3. **Filter coefficients (14 bytes)**:
   - First 7 bytes: Order 4 coefficients.
   - Next 7 bytes: Order 6 coefficients.
4. **Unprocessed signal**: Stored in memory.
5. **Processed signal**: Stored at the end of the unprocessed signal.

## Repository Structure
```
/repository_root
├── src/               # VHDL source files
│   ├── Add_Gen.vhd
│   ├── d12_d60.vhd
│   ├── FSM.vhd
|   ├── project_reti_logiche.vhd
|   ├── s010_s100.vhd
|   ├── Sat.vhd
│   ├── tb2425.vhd  # Testbench for verification
│
├── docs/
|   ├── Project Architecture.pptx  # System architecture diagram
|
├── README.md
```

## Tools Required
- **Vivado** or **Quartus** for synthesis and simulation.
- **ModelSim**, **Vivado Simulator**, or similar for testbench execution.

## License
This project follows the MIT license.

