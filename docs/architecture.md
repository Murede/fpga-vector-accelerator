# Architecture

> This is a learn-as-I-go project. The architecture records both the currently verified design and the next concepts being explored; it does not claim to be a finished production accelerator.

## Objective

The project explores two implementation styles for short unsigned vector operations:

1. A parallel datapath that computes all lanes at once.
2. An iterative datapath that trades latency for lower resource use by reusing arithmetic hardware.

The parallel building blocks are implemented. The iterative vector MAC controller is the next development milestone.

## Data representation

- Vector length: 4 elements
- Element width: 8 bits
- Arithmetic interpretation: unsigned
- ALU result width: 8 bits; addition overflow and subtraction underflow wrap modulo 256
- Product width: 16 bits
- Dot-product and accumulator width: 18 bits

An 18-bit output is sufficient because the maximum result is:

```text
4 * (2^8 - 1)^2 = 4 * 255^2 = 260100 < 2^18
```

## Module hierarchy

### Scalar and vector ALU

`alu` is a combinational scalar lane. `combinational_vector_alu` instantiates four lanes with a shared opcode.

| Opcode | Operation |
|---|---|
| `00` | Addition |
| `01` | Subtraction |
| `10` | Bitwise AND |
| `11` | Bitwise XOR |

`registered_alu` and `controller_alu` demonstrate two ways to wrap the combinational datapath in a clocked request/completion interface.

### Parallel dot product

`vector_dot_product` uses four 8-by-8-bit multipliers followed by a balanced two-level adder tree:

```text
p0 = a0*b0 ----\
                 +-- sum01 --\
p1 = a1*b1 ----/             \
                               +-- dot_product
p2 = a2*b2 ----\             /
                 +-- sum23 --/
p3 = a3*b3 ----/
```

Explicit zero extension preserves the required width at every addition stage.

### Sequential MAC

`mac_unit` adds one unsigned product to an 18-bit accumulator per enabled clock cycle. Synchronous reset clears the accumulator, while a deasserted enable holds its previous value.

## Interface timing

All sequential modules use a synchronous active-high reset.

For `registered_alu`:

1. Assert `start` with stable operands and opcode.
2. Inputs are captured on the next rising edge.
3. The result and `done` are produced on the following rising edge.
4. `done` returns low after one cycle; `result` remains stored.

The FSM-based `controller_alu` uses explicit `IDLE`, `LOAD`, `EXECUTE`, and `DONE` states to illustrate control/datapath separation.

## Verification strategy

Each implemented design block has a self-checking testbench. The suite checks:

- Every scalar and vector ALU opcode
- 8-bit addition overflow behavior
- Registered transaction timing and one-cycle completion pulses
- Reset and enable-hold behavior in the MAC
- Typical, zero, mixed large-value, and maximum-value dot products

GitHub Actions compiles each test independently with SystemVerilog-2012 enabled and runs it with `vvp`. VCD artifacts are generated locally for waveform inspection and excluded from version control.

## Current limitations

- The design has not yet been synthesized for a named FPGA target.
- Timing closure, maximum clock frequency, utilization, and power have not been measured.
- Inputs are unsigned and fixed at four 8-bit elements.
- There is not yet a top-level FPGA board interface.

These are deliberately stated as future validation work rather than inferred performance claims.
