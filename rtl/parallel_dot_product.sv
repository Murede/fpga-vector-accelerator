module parallel_dot_product #(
    parameter int DATA_WIDTH = 8,
    parameter int VECTOR_LEN = 4,
    parameter int ACC_WIDTH =
        2 * DATA_WIDTH + $clog2(VECTOR_LEN)
) (
    input logic signed [DATA_WIDTH-1:0]
        a [VECTOR_LEN-1:0],

    input logic signed [DATA_WIDTH-1:0]
        b [VECTOR_LEN-1:0],

    output logic signed [ACC_WIDTH-1:0] result
);

    localparam int PRODUCT_WIDTH = 2 * DATA_WIDTH;

    localparam int TREE_LEVELS =
        (VECTOR_LEN <= 1) ? 0 : $clog2(VECTOR_LEN);

    logic signed [PRODUCT_WIDTH-1:0]
        product [VECTOR_LEN-1:0];

    logic signed [ACC_WIDTH-1:0]
        extended_product [VECTOR_LEN-1:0];

    logic signed [ACC_WIDTH-1:0]
        tree [TREE_LEVELS:0][VECTOR_LEN-1:0];

    always_comb begin

        // Default all internal values
        for (int i = 0; i < VECTOR_LEN; i = i + 1) begin
            product[i] = '0;
            extended_product[i] = '0;
        end

        for (int level = 0; level <= TREE_LEVELS; level = level + 1) begin
            for (int node = 0; node < VECTOR_LEN; node = node + 1) begin
                tree[level][node] = '0;
            end
        end

        // Parallel multiplication and sign extension
        for (int i = 0; i < VECTOR_LEN; i = i + 1) begin

            product[i] = a[i] * b[i];

            extended_product[i] = {
                {(ACC_WIDTH-PRODUCT_WIDTH)
                    {product[i][PRODUCT_WIDTH-1]}},
                product[i]
            };

            tree[0][i] = extended_product[i];
        end

        // Balanced adder tree
        for (int level = 1; level <= TREE_LEVELS; level = level + 1) begin

            for (int node = 0; node < VECTOR_LEN; node = node + 1) begin

                if (
                    (node < ((VECTOR_LEN + (1 << (level-1)) - 1)
                        >> (level-1))) &&
                    ((2*node) <
                        ((VECTOR_LEN + (1 << (level-1)) - 1)
                        >> (level-1)))
                ) begin

                    if (
                        (2*node + 1) <
                        ((VECTOR_LEN + (1 << (level-1)) - 1)
                        >> (level-1))
                    ) begin

                        tree[level][node] =
                            tree[level-1][2*node]
                            + tree[level-1][2*node+1];

                    end
                    else begin

                        tree[level][node] =
                            tree[level-1][2*node];

                    end
                end
            end
        end

        result = tree[TREE_LEVELS][0];

    end

endmodule