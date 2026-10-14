
`timescale 1ns/100ps

module sr_tb;

    parameter width = 4;

    reg clk;
    reg serial_in;
    reg En;

    wire serial_out;
    wire [width-1:0] q;

    reg [width-1:0] expected;
    integer errors;
    integer i;

    // Device Under Test
    top #(
        .width(width)
    ) dut (
        .clk(clk),
        .serial_in(serial_in),
        .En(En),
        .serial_out(serial_out),
        .q(q)
    );

    // Clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Apply one test and check its result
    task test_cycle;
        input en_value;
        input data_value;
        begin
            // Drive away from the rising edge
            @(negedge clk);
            En = en_value;
            serial_in = data_value;

            // Calculate expected next state
            if (en_value)
                expected = {data_value, expected[width-1:1]};

            // DUT updates at rising edge
            @(posedge clk);
            #1;

            // Check register and serial output
            if (q !== expected ||
                serial_out !== expected[0]) begin
                $display(
                    "FAIL t=%0t En=%b Si=%b q=%b expected=%b out=%b",
                    $time, En, serial_in, q, expected, serial_out
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS t=%0t En=%b Si=%b q=%b out=%b",
                    $time, En, serial_in, q, serial_out
                );
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, sr_tb);

        errors = 0;
        En = 0;
        serial_in = 0;
        expected = {width{1'b0}};

        // Allow initial state to settle
        #1;

        if (q !== expected) begin
            $display("FAIL: Initial q=%b expected=%b",
                     q, expected);
            errors = errors + 1;
        end

        // 1. Enable disabled: register must hold
        test_cycle(0, 1);
        test_cycle(0, 0);
        test_cycle(0, 1);

        // 2. Shift in all ones
        for (i = 0; i < width + 1; i = i + 1)
            test_cycle(1, 1);

        // 3. Shift in all zeros
        for (i = 0; i < width + 1; i = i + 1)
            test_cycle(1, 0);

        // 4. Alternating input pattern
        test_cycle(1, 1);
        test_cycle(1, 0);
        test_cycle(1, 1);
        test_cycle(1, 0);
        test_cycle(1, 1);
        test_cycle(1, 0);

        // 5. Disable while register contains data
        test_cycle(1, 1);
        test_cycle(1, 0);
        test_cycle(0, 1);
        test_cycle(0, 0);
        test_cycle(0, 1);

        // 6. Re-enable and verify shifting resumes
        test_cycle(1, 1);
        test_cycle(1, 0);

        // Final report
        $display("--------------------------------");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d errors", errors);
        $display("--------------------------------");

        $finish;
    end

endmodule
