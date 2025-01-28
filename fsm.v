module pro(
    input clk, // Clock signal
    input rst_n, // Active-low reset
    input start_tx, // Start transmission signal
    input [7:0] data_in, // Data to be transmitted
    input ack_in, // Acknowledge input from slave
    output reg scl, // I2C clock signal
    output reg sda, // I2C data signal
    output reg done, // Transmission done signal
    output reg busy // FSM busy signal
);

    // Define state parameters
    parameter IDLE = 3'b000;
    parameter START = 3'b001;
    parameter ADDRESS = 3'b010;
    parameter DATA = 3'b011;
    parameter WAIT_ACK = 3'b100;
    parameter STOP = 3'b101;

    // Current and next state
    reg [2:0] current_state, next_state;
    reg [3:0] bit_count; // Bit counter for data and address
    reg [7:0] data_reg; // Register for data transmission

    // FSM state transition logic
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state and output logic
    always @ (*) begin
        case (current_state)
            IDLE: begin
                scl = 1;
                sda = 1;
                done = 0;
                busy = 0;
                if (start_tx) begin
                    next_state = START;
                end else begin
                    next_state = IDLE;
                end
            end

            START: begin
                scl = 1;
                sda = 0; // Generate start condition (SDA goes low while SCL is high)
                done = 0;
                busy = 1;
                next_state = ADDRESS;
            end

            ADDRESS: begin
                scl = ~scl; // Toggle clock for address transmission
                sda = data_reg[7]; // Send MSB first
                done = 0;
                busy = 1;
                if (bit_count == 7) begin
                    next_state = WAIT_ACK; // Wait for acknowledgment after address
                end else begin
                    next_state = ADDRESS;
                end
            end

            WAIT_ACK: begin
                scl = 1; // High clock for slave to send ACK
                done = 0;
                busy = 1;
                if (ack_in == 0) begin
                    next_state = DATA;
                end else begin
                    next_state = STOP;
                end
            end

            DATA: begin
                scl = ~scl; // Toggle clock for data transmission
                sda = data_reg[7]; // Send MSB first
                done = 0;
                busy = 1;
                if (bit_count == 7) begin
                    next_state = STOP; // End transmission
                end else begin
                    next_state = DATA;
                end
            end

            STOP: begin
                scl = 1;
                sda = 1; // Generate stop condition (SDA goes high while SCL is high)
                done = 1; // Indicate transmission is done
                busy = 0;
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Bit counter logic
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n)
            bit_count <= 4'b0000;
        else if (current_state == ADDRESS || current_state == DATA) begin
            if (scl == 1) begin
                bit_count <= bit_count + 1;
            end
        end else begin
            bit_count <= 4'b0000;
        end
    end

    // Data register load logic (assuming data_in is to be sent)
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n)
            data_reg <= 8'b0;
        else if (current_state == START)
            data_reg <= {data_in[7:1], 1'b0}; // Address + R/W bit for simplicity
    end

endmodule


