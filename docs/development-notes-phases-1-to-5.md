# Development Notes: Scalar ALU to Vector Dot Product

This document is a searchable companion to my [original handwritten development notebook](phase-1-to-5-development-notes.pdf). It summarizes the first five project phases and connects the design reasoning to the SystemVerilog modules and self-checking testbenches in this repository.

This is a learn-as-I-go engineering record. The RTL and testbenches are the source of truth when an early handwritten value, signal name, or timing sketch differs from the implemented design.

## Development progression

| Phase | Design milestone | RTL | Testbench | Main verification focus |
|---|---|---|---|---|
| 1 | 8-bit combinational ALU | [`alu.sv`](../rtl/alu.sv) | [`alu_tb.sv`](../tb/alu_tb.sv) | Four opcodes, representative operands, and 8-bit wraparound behavior |
| 2 | Registered ALU transaction | [`registered_alu.sv`](../rtl/registered_alu.sv) | [`registered_alu_tb.sv`](../tb/registered_alu_tb.sv) | Input capture, result latency, stored output, and one-cycle `done` pulse |
| 3 | FSM-controlled datapath | [`controller_alu.sv`](../rtl/controller_alu.sv) | [`controller_alu_tb.sv`](../tb/controller_alu_tb.sv) | `IDLE`/`LOAD`/`EXECUTE`/`DONE` sequencing and repeated transactions |
| 4 | Four-lane vector ALU | [`combinational_vector_alu.sv`](../rtl/combinational_vector_alu.sv) | [`combinational_vector_alu_tb.sv`](../tb/combinational_vector_alu_tb.sv) | All four lanes performing the selected operation concurrently |
| 5a | Sequential multiply-accumulate unit | [`mac_unit.sv`](../rtl/mac_unit.sv) | [`mac_unit_tb.sv`](../tb/mac_unit_tb.sv) | Reset, accumulation, enable/hold behavior, and full-width arithmetic |
| 5b | Parallel four-element dot product | [`vector_dot_product.sv`](../rtl/vector_dot_product.sv) | [`vector_dot_product_tb.sv`](../tb/vector_dot_product_tb.sv) | Per-lane multiplication, adder-tree summation, zero cases, mixed values, and maximum values |

## Phase 1: combinational scalar ALU

The first phase established a reusable 8-bit arithmetic lane. Two operands and a 2-bit opcode select one of four operations:

| Opcode | Operation | Result |
|---|---|---|
| `00` | Add | `a + b` |
| `01` | Subtract | `a - b` |
| `10` | Bitwise AND | `a & b` |
| `11` | Bitwise XOR | `a ^ b` |

The result is intentionally 8 bits wide. Addition carry-out and subtraction underflow therefore wrap modulo 256. This limitation is documented and tested rather than treated as an accidental overflow.

The design is purely combinational: it has no clock, reset, or stored state. The testbench drives operands and an opcode, allows the combinational logic to settle, and checks the result automatically.

## Phase 2: registered transaction timing

The registered wrapper introduced clocked data movement and a request/completion interface around the ALU. A transaction captures stable inputs when `start` is asserted, computes from the registered operands, stores the result, and asserts `done` for one cycle.

The main learning goal was separating functional correctness from timing correctness. The scalar ALU testbench had already checked the arithmetic; this phase added checks for capture timing, latency, completion signaling, reset behavior, and retention of the last result.

## Phase 3: explicit controller FSM

The controller version replaced implicit progress tracking with four named states:

```text
IDLE -> LOAD -> EXECUTE -> DONE -> IDLE
```

This made control and datapath responsibilities visible. The state register stores the current phase of the transaction, combinational next-state logic chooses the following state, and state-dependent actions capture inputs, execute the operation, store the result, and generate `done`.

The testbench verifies both the ALU result and the control sequence across clock edges. It also checks that `done` is limited to the `DONE` state and that another transaction can begin after the controller returns to `IDLE`.

## Phase 4: four-lane vector datapath

The vector ALU reuses the scalar lane four times. Each lane receives a different pair of 8-bit elements while all lanes share one opcode:

```text
A[0] op B[0] -> R[0]
A[1] op B[1] -> R[1]
A[2] op B[2] -> R[2]
A[3] op B[3] -> R[3]
```

This phase demonstrates spatial hardware parallelism: the four ALU instances operate concurrently instead of executing four software-style loop iterations. Because the module remains combinational, its testbench needs no clock or reset. Every lane must match the behavior already established by the scalar ALU.

## Phase 5: MAC and dot-product datapaths

The fifth phase moved from general arithmetic and logic toward a DSP-style operation used in signal processing and machine-learning workloads:

```text
dot_product = A0*B0 + A1*B1 + A2*B2 + A3*B3
```

Two architectures support this learning milestone:

- `mac_unit` reuses one multiplier and accumulator across clock cycles.
- `vector_dot_product` uses four multipliers concurrently and combines their products with a balanced adder tree.

The parallel design uses deliberate width growth:

| Value | Width |
|---|---|
| Input element | 8 bits |
| Product | 16 bits |
| Pair sum | 17 bits |
| Final four-product sum | 18 bits |

For unsigned inputs, the maximum result is:

```text
4 * 255 * 255 = 260100
```

That value fits in 18 bits. The dot-product testbench checks a normal example (`[2, 4, 6, 8] . [1, 3, 5, 7] = 100`), zero inputs, mixed larger values, and the maximum-width boundary case.

## Verification approach

The first five phases use self-checking testbenches rather than relying only on waveform inspection. Each testbench supplies known inputs, calculates or defines the expected result, and reports a failure when the design output or transaction timing differs.

GitHub Actions runs the six phase 1-to-5 simulations plus the iterative vector-MAC and signed-MAC testbenches with Icarus Verilog on each push and pull request. VCD files can also be generated locally for timing inspection in GTKWave.

## Continuing development

The repository now verifies the later iterative vector-MAC controller and signed MAC in the automated workflow. The parameterized signed matrix-vector controller, arbitrary-length parallel dot product, and parallel matrix-vector wrapper extend the learning path beyond this notebook. Their exact verification state is tracked in the root README rather than being folded into the completed Phase 1-5 record.
