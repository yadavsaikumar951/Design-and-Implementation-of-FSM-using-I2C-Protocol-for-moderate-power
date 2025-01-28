module pro_tb;

    // Testbench signals
    reg clk; // Clock signal
    reg rst_n; // Active-low reset
    reg start_tx; // Start transmission signal
    reg [7:0] data_in; // Data to be transmitted
    reg ack_in; // Acknowledge input from slave
    wire scl; // I2C clock signal
    wire sda; // I2C data signal
    wire done; // Transmission done signal
    wire busy; // FSM busy signal

    // Instantiate the i2c_fsm module
    pro uut (
        .clk(clk),
        .rst_n(rst_n),
        .start_tx(start_tx),
        .data_in(data_in),
        .ack_in(ack_in),
        .scl(scl),
        .sda(sda),
        .done(done),
        .busy(busy)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // 100 MHz clock
    end

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        start_tx = 0;
        data_in = 8'hA5; // Example data to transmit (0xA5)
        ack_in = 0;

        // Apply reset
        #10 rst_n = 1;
        #10 rst_n = 0; // Deassert reset
        #10 rst_n = 1;

        // Start transmission
        #10 start_tx = 1; // Initiate transmission
        #10 start_tx = 0;

        // Simulate the I2C process
        // Generate a clock and acknowledge signals
        // Address phase
        #20 ack_in = 0; // ACK from slave, assume ACK for now

        // Data transmission phase
        #20 ack_in = 0; // ACK after sending the first byte of data
        #20 ack_in = 0; // ACK after sending the second byte of data (if needed)

        // Stop transmission
        #20 ack_in = 1; // No ACK, to simulate end of transmission

        // Wait for done signal
        #20;
        $display("I2C FSM Testbench finished.");
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t | clk=%b | rst_n=%b | start_tx=%b | data_in=%h | ack_in=%b | scl=%b | sda=%b | done=%b | busy=%b", 
                 $time, clk, rst_n, start_tx, data_in, ack_in, scl, sda, done, busy);
    end

endmodule
