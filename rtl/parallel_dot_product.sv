module parallel_dot_product #(
    parameter int DATA_WIDTH = 8,
    parameter int VECTOR_LEN = 4,
    parameter int ACC_WIDTH =
    2 * DATA_WIDTH + $clog2(VECTOR_LEN)
) (
    input logic signed [DATA_WIDTH - 1:0]
        a [VECTOR_LEN-1:0],

    input logic signed [DATA_WIDTH - 1:0]
        b [VECTOR_LEN-1:0],

    output logic signed [ACC_WIDTH-1:0] result 
);
    
    // Internal Datapath
    
    localparam int PRODUCT_WIDTH = 2 * DATA_WIDTH;

    localparam int TREE_LEVELS = 
        (VECTOR_LEN <=1)? 0 : $clog2(VECTOR_LEN);

    logic signed [PRODUCT_WIDTH-1:0] product [VECTOR_LEN-1:0];
    
    logic signed [ACC_WIDTH-1:0]
        tree [TREE_LEVELS:0][VECTOR_LEN-1:0];

    logic signed [ACC_WIDTH-1:0]
        extended_product [VECTOR_LEN-1:0];
    
    integer nodes_per_level;

    // Mutliplication & Sign Extension Phase
    always_comb begin
        for(int k = 0; k < VECTOR_LEN; k = k + 1) begin 
            product[k] = a[k] * b[k];

        extended_product[k] =
            {{(ACC_WIDTH-PRODUCT_WIDTH)
              {product[k][PRODUCT_WIDTH-1]}},
              product[k]};
        end

        // Default all tree entries to zero
        for (int level = 0; level <= TREE_LEVELS; level = level +1) begin 
            for(int node =0; node < VECTOR_LEN; node = node + 1) begin
                tree[level][node] = '0;
            end 
        end 

        // Level 0: Sign-extended products 
        for (int node =0; node < VECTOR_LEN; node = node + 1) begin 
            tree[0][node] = extended_product[node];
        end 

        nodes_per_level = VECTOR_LEN;

        // Build each subsequeent tree level 
        for(int level = 1; level <= TREE_LEVELS; level = level + 1) begin 

            for (int node = 0; node < nodes_per_level; node = node + 2) begin 
                if (node + 1 < nodes_per_level) begin 
                    tree[level][node/2] =
                        tree[level-1][node] + tree[level-1][node+1];
            end

                else begin 
                    tree[level][node/2] = 
                        tree[level-1][node];
                end 
            end 

            // Number of outputs produced by this level 
            nodes_per_level = (nodes_per_level + 1) /2;
        end 

        result = tree[TREE_LEVELS][0];

    end 


endmodule