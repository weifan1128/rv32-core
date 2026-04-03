# RISC-V CPU

A SystemVerilog implementation of a 5-stage pipelined RV32IM CPU.

## Features

- **5-stage pipeline**: IF → ID → EX → MEM → WB
- **RV32I base ISA**: arithmetic, logic, load/store, branch, jump instructions
- **M extension**: MUL, MULH, MULHU, MULHSU (multi-cycle multiplier)
- **CSR**: RDCYCLE, RDCYCLEH, RDINSTRET, RDINSTRETH
- **Hazard handling**:
  - Data hazards: EX→EX and MEM→EX forwarding
  - Load-use: 1-cycle stall
  - Control hazards: 1-cycle penalty (JAL/JALR), 2-cycle penalty (branch taken)
- **Synchronous reset** (active-high)

## Directory Structure

```
RISCV_CPU/
├── src/
│   ├── top.sv               # Top-level module (CPU + SRAM)
│   ├── CPU.sv               # Pipeline CPU core
│   ├── Controller.sv        # Control signal decoder
│   ├── SRAM_wrapper.sv      # SRAM interface wrapper
│   ├── IF/
│   │   ├── Reg_PC.sv        # Program counter register
│   │   └── IF_ID.sv         # IF/ID pipeline register
│   ├── ID/
│   │   ├── Decoder.sv       # Instruction decoder
│   │   ├── Imm_Ext.sv       # Immediate sign extension
│   │   ├── RegFile.sv       # 32-entry register file
│   │   └── ID_EX.sv         # ID/EX pipeline register
│   ├── EX/
│   │   ├── ALU.sv           # Arithmetic logic unit
│   │   ├── JB_Unit.sv       # Jump/branch target unit
│   │   └── EX_MEM.sv        # EX/MEM pipeline register
│   ├── MEM/
│   │   ├── ST_align_unit.sv # Store alignment (SB/SH/SW)
│   │   ├── csr_unit.sv      # CSR counter unit
|   |   ├── Multiplier.sv    # multiplier
│   │   └── MEM_WB.sv        # MEM/WB pipeline register
│   └── WB/
│       └── LD_align_unit.sv # Load alignment (LB/LH/LBU/LHU)
├── sim/
│   ├── top_tb.sv            # Testbench (provided)
│   ├── SRAM/                # SRAM model (provided)
│   └── prog0~5/             # Test programs
├── include/
│   └── CPU_def.svh          # Shared definitions
└── Makefile
```

## Memory Map

| Region | CPU Byte Address | SRAM Word Address |
|--------|-----------------|-------------------|
| Instruction Memory (IM1) | `0x0000` – `0x7FFF` | `addr[15:2]` |
| Data Memory (DM1) | `0x8000` – `0xFFFF` | `addr[15:2]` |
| `_test_start` | `0x8000` | `DM[0x2000]` |
| `_sim_end` | `0xFFFC` | `DM[0x3FFF]` |

## Synthesis Results (v0.1 — Multiplier in EX stage)

> Tool: Synopsys Design Compiler  
> Library: UMC 0.18 µm  
> Corner: WCCOM — SS, 1.62 V, 125 °C  

### Timing

| Parameter | Value |
|-----------|-------|
| Clock period | 15 ns (66.67 MHz) |
| Slack | 0.00 ns (just met) |
| Critical path | DM read → LD_align → WB forwarding mux → **Multiplier (combinational 32×32)** → ALU → Controller (jb_flush) → IF/ID → Decoder → RegFile → ID/EX |
| SRAM read delay | 5.74 ns |
| Multiplier delay | ~4.13 ns (8.27 → 12.40 ns) |

**Bottleneck:** The combinational 32×32 multiplier placed in the EX stage dominates the critical path (~27% of the cycle budget).

### Area

| Category | Value |
|----------|-------|
| Combinational cells | 291,506 µm² |
| Sequential cells | 99,072 µm² |
| **Total logic area** | **390,578 µm²** |
| SRAM macros (×2) | 5,344,495 µm² |
| **Total cell area** | **5,735,073 µm²** |
| Cell count | 14,304 (12,605 comb + 1,660 seq + 2 macros) |

### Power

> Note: low-effort analysis with unannotated inputs; values are estimates.

| Group | Power | % |
|-------|-------|---|
| Memory (SRAM) | 77.78 mW | 92.1% |
| Register | 4.54 mW | 5.4% |
| Combinational | 2.15 mW | 2.5% |
| **Total dynamic** | **83.22 mW** | — |
| Leakage | 1.24 mW | — |
| **Total** | **84.46 mW** | — |

Operating voltage: 1.62 V

---

## Synthesis Results (v0.2 — Multiplier moved to MEM stage)

> Tool: Synopsys Design Compiler  
> Library: UMC 0.18 µm  
> Corner: WCCOM — SS, 1.62 V, 125 °C  

### Timing

| Parameter | Value |
|-----------|-------|
| Clock period | 12.4 ns (80.6 MHz) |
| Slack | 0.00 ns (just met) |
| Critical path | DM read → LD_align → WB forwarding mux → EX rs2 mux → ALU → Controller (jb_flush) → IF/ID → Decoder → RegFile → ID/EX |
| SRAM read delay | 5.74 ns |
| Data arrival time | 13.19 ns |

**Observation:** Multiplier is no longer on the critical path. The bottleneck is now the SRAM read → load-forwarding → ALU → branch flush → decode chain.

### Area

| Category | Value |
|----------|-------|
| Combinational cells | 291,403 µm² |
| Sequential cells | 103,337 µm² |
| **Total logic area** | **394,740 µm²** |
| SRAM macros (×2) | 5,344,495 µm² |
| **Total cell area** | **5,739,235 µm²** |
| Cell count | 14,489 (12,718 comb + 1,731 seq + 2 macros) |

### Power

> Note: low-effort analysis with unannotated inputs; values are estimates.

| Group | Power | % |
|-------|-------|---|
| Memory (SRAM) | 93.83 mW | 92.01% |
| Register | 5.73 mW | 5.62% |
| Combinational | 2.41 mW | 2.37% |
| **Total dynamic** | **100.73 mW** | — |
| Leakage | 1.24 mW | — |
| **Total** | **101.97 mW** | — |

Operating voltage: 1.62 V

---

## PPA Comparison

### Version Descriptions

| Version | ISA | CSR | Microarchitecture change |
|---------|-----|-----|--------------------------|
| v0.1 | RV32I + M (MUL/MULH/MULHU/MULHSU) | RDCYCLE, RDCYCLEH, RDINSTRET, RDINSTRETH | Baseline — combinational multiplier in EX stage |
| v0.2 | RV32I + M (MUL/MULH/MULHU/MULHSU) | RDCYCLE, RDCYCLEH, RDINSTRET, RDINSTRETH | Multiplier moved to MEM stage |

### PPA Summary

| Version | Multiplier | Clock | Slack | Logic Area | Total Area | Total Power |
|---------|-----------|-------|-------|-----------|-----------|------------|
| v0.1 | EX stage  | 15 ns | 0.00 ns ✅ | 390,578 µm² | 5,735,073 µm² | 84.46 mW |
| v0.2 | MEM stage  | 12.4 ns | 0.00 ns ✅ | 394,740 µm² | 5,739,235 µm² | 101.97 mW |

**v0.2 takeaway:** Moving the multiplier out of EX removes it from the critical path. Timing met at 12.4 ns. The new bottleneck is the SRAM load-forwarding → branch-flush → decode chain.

---

## Simulation

```bash
make rtl0   # prog0 — basic arithmetic (RV32I)
make rtl1   # prog1 — insertion sort (RV32I)
make rtl2   # prog2 — signed 64-bit multiply (M ext)
make rtl3   # prog3 — GCD via subtraction (no M ext)
make rtl4   # prog4 — factorial + rdcycle/rdinstreth
make rtl5   # prog5 — signed/unsigned 64-bit multiply
```

Pass condition: output prints `Simulation PASS!!` and `sim/progN/result_rtl.txt` matches `golden.hex`.
