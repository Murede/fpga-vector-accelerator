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
        (VECTOR_LEN <=1)? 1 : $clog2(VECTOR_LEN);

    logic signed [PRODUCT_WIDTH-1:0] product [VECTOR_LEN-1:0];
    
    logic signed [ACC_WIDTH-1:0]
        tree [TREE_LEVELS:0][VECTOR_LEN-1:0];

    logic signed [ACC_WIDTH-1:0]
        extended_product [VECTOR_LEN-1:0];

    // Mutliplication & Sign Extension Phase

    integer i;
    integer j;

    always_comb begin
        for(i = 0; i < VECTOR_LEN; i = i + 1) begin 
            product[i] = a[i] * b[i];

        extended_product[i] =
            {{(ACC_WIDTH-PRODUCT_WIDTH)
              {product[i][PRODUCT_WIDTH-1]}},
              product[i]};
        end
    end
    
    // Accumilation Phase 
   integer nodes_per_level;

   always_comb begin 
        // Default all tree entries to zero
        for (i=0; i <= TREE_LEVELS; i = i +1) begin 
            for(j =0; j < VECTOR_LEN; j = j+1) begin
                tree[i][j] = '0;
            end 
        end 

        // Level 0: Sign-extended products 
        for (i =0; i < VECTOR_LEN; i = i + 1) begin 
            tree[0][i] = extended_product[i];
        end 

        nodes_per_level = VECTOR_LEN;

        // Build each subsequeent tree level 
        for(i = 1; i <= TREE_LEVELS; i = i + 1) begin 

            for (j = 0; j < nodes_per_level; j = j + 2) begin 
                if (j + 1 < nodes_per_level) begin 
                    tree[i][j/2] =
                        tree[i-1][j] + tree[i-1][j+1];
            end

                else begin 
                    tree[i][j/2] = 
                        tree[i-1][j];
                end 
            end 

            // Number of outputs produced by this level 
            nodes_per_level = (nodes_per_level + 1) /2;
        end 

        result = tree[TREE_LEVELS][0];

    end 


endmodule