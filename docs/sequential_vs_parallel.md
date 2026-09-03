# Sequential MAC vs Parallel Dot Product 

## 1. Architecture Comparison 

| Characteristic | Sequential MAC | Parallel Dot Product |
|---|---|---|
| Multipliers | 1 | VECTOR_LEN |
| Processing | Sequential | Parallel |
| Latency | Higher | Lower |
| Hardware usage | Lower | Higher |

## 2. Sequential Architecture

### 2.1 Overview

The sequential matrix-vector multiplier uses a single signed muliply-accumulate (MAC) unit that is reused acros the elements of each matrix row. Instead of computing every element-wise multiplication simultaneously. Our contoller processes one matrix-vector element pair per clock cycle and accumulates each product into a running result. 

### 2.2 Hardware Specifications

The module makes use of parametrization allowing us to calculate the dot product of any sized vector by setting `VECTOR_LEN` to the desired matrix size. However, one thing to keep in mind is that the `VECTOR_LEN` does not instatiate four multipliers. It process each individual matrix-vector pair on subsequent clock cycles. 

The sequential architecture reduces hardware requirements through the temporal reuse of the instatiated multiplier. The single arithmetic unit performs operations that could otherwise require mutliple parallel multipliers and adders.

### 2.3 Controller/FSM Architecture 
| State   | Function                                                      |
| ------- | ------------------------------------------------------------- |
| `IDLE`  | Wait for `start`                                              |
| `CLEAR` | Reset accumulator before processing a new row                 |
| `MAC`   | Multiply the current elements and accumulate the product      |
| `STORE` | Save the completed row dot product into `y[row_index]`        |
| `DONE`  | Signal that the complete matrix-vector operation has finished |


### 2.4 Matrix Traversal 

To efficiently index the matrix I decided to use row_index to represent the matrix row that is being computed and vector_index to represent the element inside the selected row. 

// Add an example of the indexing here 

### 2.5 Sequential Architectural Tradeoff

The primary advantage of our sequential architecture is hardware efficiency. Through the reuse of the same mac unit across muliple vector elements, our design requires less arithmetic resources than the parallel implementation. 

The major tradeoff here is increased latency; completing a dot product requires multiple clock cycles, and more controller states to coordinate the accumilation, storage and traversal of the matrix. This begs the question can additional hardware be used to create a more efficient logic circuit.

## 3. Parallel Architecture

### 3.1 Overview
The Parallel Dot Product module addresses the question we left off on in the previous section. The parallel matrix-vector multiplier reduces computation latency by processing all elements within the current matrix row simultaneously. Rather than reusing the same MAC unit across `VECTOR_LEN` clock cycles, the architecture uses `VECTOR_LEN` parallel multipliers followed by a balanced adder tree to calculate an entire row dot product combinationally. An important distinction here is that we are parallelizing within each row, not across the entire matrix. The rows are still being processed sequentially. This will be important later as we discuss matrix traversal. 

// Add arcitectural image here

### 3.2 Hardware Specifications

This module takes full adantvantage of paramtrization by creating `VECTOR_LEN` individual multipliers and passing them into an arbitrarily sized balanced tree (The derivation behind the tree will be explained in a later section). The parallel architecture increases computational resources so that operations previously distributed across multiple clock cycles are instead performed by seperate hardware units at the same time. In other words, spatial parallelism 

### 3.3 Balanced Adder Tree

After the muliplication occurs, we still need to find the sum of the products. A balanced adder tree reduces the combinational addition stages to grow linearly with vector length, the tree depth grows approximately with `log2(VECTOR_LEN)`

### 2.4 Matrix Traversal

To efficiently index the matrix, I decided to use `row_index` to represent the matrix row that is being computed and `vector_index` to represent the element inside the selected row.

For example, if:

row_index = 2  
vector_index = 1

the datapath selects:

A[2][1] × X[1]

The `vector_index` increments as the MAC unit moves through each element of the current row. Once the final element has been accumulated, the completed dot product is stored and `row_index` advances to the next matrix row.

For a four-element vector, the traversal of a single row can be represented as:

                    row_index = 0

                         |
                         v

        A[0][0] × X[0]   vector_index = 0
                 |
                 v
        A[0][1] × X[1]   vector_index = 1
                 |
                 v
        A[0][2] × X[2]   vector_index = 2
                 |
                 v
        A[0][3] × X[3]   vector_index = 3
                 |
                 v
           Store Y[0]
                 |
                 v
          row_index = 1

This means that matrix traversal occurs across two dimensions. `vector_index` controls movement across the columns of a row, while `row_index` controls movement between rows.

### 2.5 Sequential Architectural Tradeoff

The primary advantage of our sequential architecture is hardware efficiency. Through the reuse of the same MAC unit across multiple vector elements, our design requires fewer arithmetic resources than the parallel implementation.

The major tradeoff here is increased latency. Completing a dot product requires multiple clock cycles and more controller states to coordinate the accumulation, storage, and traversal of the matrix.

This begs the question: can additional hardware be used to create a more efficient logic circuit in terms of computation time?

## 3. Parallel Architecture

### 3.1 Overview

The Parallel Dot Product module addresses the question we left off on in the previous section. The parallel matrix-vector multiplier reduces computation latency by processing all elements within the current matrix row simultaneously.

Rather than reusing the same MAC unit across `VECTOR_LEN` clock cycles, the architecture uses `VECTOR_LEN` parallel multipliers followed by a balanced adder tree to calculate an entire row dot product combinationally.

An important distinction here is that we are parallelizing within each row, not across the entire matrix. The rows are still being processed sequentially. This will be important later as we discuss matrix traversal.

For `VECTOR_LEN = 4`, the architecture can be visualized as:

                    Current Matrix Row

        A[row][0]    A[row][1]    A[row][2]    A[row][3]
            |            |            |            |
            ×            ×            ×            ×
            |            |            |            |
          X[0]         X[1]         X[2]         X[3]
            |            |            |            |
            v            v            v            v
           P0           P1           P2           P3
            \           /             \           /
             \         /               \         /
              +-------+                 +-------+
                  |                         |
                SUM0                      SUM1
                   \                       /
                    \                     /
                     +-------------------+
                              |
                              v
                         row_result
                              |
                              v
                       Y[row_index]

Unlike the sequential architecture, all four multiplications are represented by separate pieces of hardware and can therefore occur simultaneously.

### 3.2 Hardware Specifications

This module takes full advantage of parameterization by creating `VECTOR_LEN` individual multipliers and passing their results into an arbitrarily sized balanced adder tree. The derivation behind the tree will be explained in the following section.

The parallel architecture increases computational resources so that operations previously distributed across multiple clock cycles are instead performed by separate hardware units at the same time.

In other words, we have replaced temporal hardware reuse with spatial parallelism.

For example:

VECTOR_LEN = 4

Sequential Architecture:

                     Single Multiplier
                           |
            reused across four elements
                           |
             P0 -> P1 -> P2 -> P3

Parallel Architecture:

          Multiplier 0 -> P0
          Multiplier 1 -> P1
          Multiplier 2 -> P2
          Multiplier 3 -> P3
                 |
                 v
             Adder Tree

Changing `VECTOR_LEN` therefore changes more than just the size of our input. It changes the amount of arithmetic hardware described by the RTL.

For example:

VECTOR_LEN = 2
-> 2 parallel multipliers

VECTOR_LEN = 4
-> 4 parallel multipliers

VECTOR_LEN = 8
-> 8 parallel multipliers

This is an important distinction between parameterization in software and parameterization in hardware. Increasing the parameter can result in additional physical logic being generated during synthesis.

### 3.3 Balanced Adder Tree

After the multiplication occurs, we still need to find the sum of the products. Simply creating multiple multipliers does not complete the dot product because all of the resulting products must eventually be reduced into one final value.

A balanced adder tree allows us to perform these additions in stages. Instead of allowing the number of sequential addition stages to grow linearly with vector length, the depth of the tree grows approximately with `log2(VECTOR_LEN)`.

For `VECTOR_LEN = 4`:

Level 0:

             P0          P1          P2          P3
              \          /            \          /
               \        /              \        /

Level 1:

                 P0 + P1                P2 + P3
                       \                  /
                        \                /

Level 2:

                    (P0 + P1) + (P2 + P3)
                              |
                              v
                            result

This means a four-element vector only requires two levels of addition after multiplication.

The relationship between vector length and tree depth can be represented as:

| `VECTOR_LEN` | Approximate Addition Levels |
|---:|---:|
| 2 | 1 |
| 4 | 2 |
| 8 | 3 |
| 16 | 4 |

The number of tree levels can therefore be calculated using:

`TREE_LEVELS = $clog2(VECTOR_LEN)`

The tree itself is represented using:

`tree[level][node]`

where `level` represents the current stage of the tree and `node` represents the value at that position.

The first level of the tree contains our sign-extended multiplication results:

tree[0][0] = product[0]  
tree[0][1] = product[1]  
tree[0][2] = product[2]  
tree[0][3] = product[3]

Each following level combines pairs of values from the previous level:

tree[level][node/2] =
tree[level-1][node] + tree[level-1][node+1]

This process continues until only one value remains, which becomes the final dot-product result.

### 3.4 Non-Power-of-Two Vector Lengths

One problem with creating a parameterized balanced tree is that `VECTOR_LEN` is not guaranteed to be a power of two.

For example, consider:

VECTOR_LEN = 5

The first reduction produces:

              P0     P1     P2     P3     P4
               \     /       \     /       |
                \   /         \   /        |
                 S0            S1          P4
                   \           /            |
                    \         /             |
                       S2                  P4
                         \                 /
                          \               /
                              result

`P4` does not have another product to pair with during the first addition stage.

Rather than discarding the value, the architecture passes the unmatched node directly into the next level of the tree.

The number of active nodes therefore follows:

5 -> 3 -> 2 -> 1

The number of outputs produced by each level is calculated using:

`nodes_per_level = (nodes_per_level + 1) / 2`

Because SystemVerilog integer division removes the fractional portion, adding one before dividing allows the calculation to behave like a ceiling division for our positive node counts.

This allows the same architecture to support both power-of-two and non-power-of-two vector lengths without hard-coding a tree specifically for one vector size.

### 3.5 Matrix Traversal

The parallel architecture also simplifies how we traverse the matrix.

The sequential implementation required two indices:

`row_index`  
`vector_index`

The `row_index` determined which matrix row was being processed, while `vector_index` selected the individual element within that row.

The parallel architecture no longer requires `vector_index`.

Instead of selecting:

A[row_index][vector_index]

the parallel datapath receives the entire current row:

A[row_index][0]  
A[row_index][1]  
A[row_index][2]  
...  
A[row_index][VECTOR_LEN-1]

Each element is connected to its own multiplier.

The traversal therefore becomes:

                     row_index = 0
                           |
                           v
                   Compute Entire Row 0
                           |
                           v
                       Store Y[0]
                           |
                           v
                     row_index = 1
                           |
                           v
                   Compute Entire Row 1
                           |
                           v
                       Store Y[1]
                           |
                          ...
                           |
                           v
                    Final Matrix Row
                           |
                           v
                          DONE

We have therefore removed sequential traversal across the columns while maintaining sequential traversal across the rows.

### 3.6 Controller/FSM Architecture

Removing the sequential MAC operation also allows us to simplify the controller.

The parallel architecture uses four states:

| State | Function |
|---|---|
| `IDLE` | Wait for a new `start` command |
| `COMPUTE` | Allow the parallel combinational datapath to calculate the current row |
| `STORE` | Store `row_result` into `y[row_index]` and move to the next row |
| `DONE` | Signal that the complete matrix-vector multiplication has finished |

The state flow can be represented as:

                         start
                           |
                           v
                         IDLE
                           |
                           v
                       COMPUTE
                           |
                           v
                         STORE
                         /   \
                        /     \
               More Rows       Final Row
                   |                |
                   v                v
                COMPUTE            DONE
                   ^                |
                   |________________|
                      Next Operation

Compared with the sequential architecture:

Sequential:

IDLE -> CLEAR -> MAC -> MAC -> ... -> STORE

Parallel:

IDLE -> COMPUTE -> STORE

The `CLEAR` state is no longer necessary because the parallel dot-product module does not contain a sequential accumulator that must be reset before each row.

Similarly, we no longer remain in the `MAC` state for multiple vector elements. All of the element-wise products are generated simultaneously by the parallel datapath.

The controller is therefore simplified as a direct consequence of moving more of the computation into parallel hardware.

### 3.7 Parallel Architectural Tradeoff

The primary advantage of the parallel architecture is reduced computation latency. By instantiating `VECTOR_LEN` multipliers, the design can calculate all element-wise products for the current row simultaneously rather than distributing these operations across multiple clock cycles.

However, this performance improvement is not free.

Increasing the amount of parallel computation requires additional arithmetic hardware:

More Multipliers
        |
        v
More Simultaneous Computation
        |
        v
Fewer Required Computation Cycles
        |
        v
Reduced Latency

At the same time:

More Multipliers
        |
        v
More FPGA Resources
        |
        v
Greater Hardware Cost

The balanced adder tree also introduces a combinational path between the multipliers and the final result. As `VECTOR_LEN` increases, the number of addition levels grows. Although the balanced tree limits this growth to approximately `log2(VECTOR_LEN)`, this path may still influence the maximum achievable clock frequency.

At this stage, these are architectural expectations rather than measured results. The synthesis and timing analysis performed later in the project will allow us to determine the actual resource usage, critical path, and performance differences between the two implementations.

## 4. Architectural Comparison

The sequential and parallel implementations demonstrate two different approaches to performing the same mathematical operation.

The sequential architecture focuses on temporal reuse:

One MAC Unit
     |
     v
Reuse Hardware Across Clock Cycles
     |
     v
Lower Resource Requirements
     |
     v
Higher Computation Latency

The parallel architecture focuses on spatial parallelism:

Multiple Multipliers
     |
     v
Perform Operations Simultaneously
     |
     v
Lower Computation Latency
     |
     v
Higher Resource Requirements

The key architectural difference is therefore not the mathematical operation being performed. Both implementations calculate the same matrix-vector multiplication. The difference is how that computation is mapped onto hardware.

The sequential architecture distributes the computation across time, while the parallel architecture distributes the computation across additional hardware.

The next stage of the project will use synthesis, timing, and resource analysis to quantify the tradeoff between these two approaches.