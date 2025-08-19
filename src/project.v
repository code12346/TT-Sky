module tt_um_code12346_pwm (
    input  wire clk,
    input  wire rst_n,
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena
);

    // Duty cycle from ui_in[6:0]
    wire [6:0] dc = ui_in[6:0];
    reg pwm_out;
    reg pwm_out1;

    // Internal PWM module
    pwm pwm_inst (
        .clk(clk),
        .rst_n(rst_n),
        .dc(dc),
        .pwm_out(pwm_out),
        .pwm_out1(pwm_out1)
    );

    // Gate outputs with ena
    assign uo_out[0]   = ena ? pwm_out  : 1'b0;
    assign uo_out[1]   = ena ? pwm_out1 : 1'b0;
    assign uo_out[7:2] = 6'b0;

    // Not using bidirectional IOs
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule


// ----------------------------------------------------
// PWM generator logic
// ----------------------------------------------------
module pwm (
    input clk,
    input rst_n,          // active-low reset
    input wire [6:0] dc,
    output reg pwm_out,
    output reg pwm_out1
);

    reg [7:0] count;
    wire [7:0] threshold;

    // Scale percentage (0–100) into 8-bit threshold (0–255)
    assign threshold = (dc * 255) / 100;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 8'd0;
            pwm_out <= 0;
            pwm_out1 <= 0;
        end else begin
            count <= count + 1;

            if (threshold == 0) begin
                pwm_out <= 0;
            end else if (dc >= 7'd100) begin
                pwm_out <= 1;
            end else if (count < threshold) begin
                pwm_out <= 1;
            end else begin
                pwm_out <= 0;
            end

            pwm_out1 <= pwm_out;  // delayed copy
        end
    end
endmodule
