module tt_um_code12346_pwm (
    input  wire clk,
    input  wire rst_n,      // active-low reset from TinyTapeout
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena
);

    // Convert active-low reset to active-high
    wire reset = ~rst_n;

    // Duty cycle: use full 8-bit input (0–255)
    wire [7:0] dc = ui_in;

    // PWM outputs
    wire pwm_out;
    wire pwm_out1;

    // Instantiate PWM module
    pwm pwm_inst (
        .clk(clk),
        .reset(reset),
        .dc(dc),
        .pwm_out(pwm_out),
        .pwm_out1(pwm_out1)
    );

    // Map outputs
    assign uo_out[0] = pwm_out;
    assign uo_out[1] = pwm_out1;
    assign uo_out[7:2] = 6'b0;

    // Not using bidirectional IOs
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule


// ----------------------------------------------------
// PWM generator logic
// ----------------------------------------------------
module pwm (
    input  wire clk,
    input  wire reset,       // active-high reset
    input  wire [7:0] dc,    // duty cycle 0–255
    output reg pwm_out,
    output reg pwm_out1
);
    reg [7:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count <= 8'd0;
            pwm_out <= 1'b0;
            pwm_out1 <= 1'b0;
        end else begin
            count <= count + 1;

            // Compare duty cycle directly
            if (count < dc)
                pwm_out <= 1'b1;
            else
                pwm_out <= 1'b0;

            // Second output is same as pwm_out (you can change if needed)
            pwm_out1 <= pwm_out;
        end
    end
endmodule
