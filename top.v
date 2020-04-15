module top (
    input  wire       clk_12m,
    input  wire       rxd,
    output wire [2:0] pwm,
    output wire [2:0] led
);

wire clk_buf;

SB_GB gbuf_g0_inst (
    .USER_SIGNAL_TO_GLOBAL_BUFFER (clk_12m),
    .GLOBAL_BUFFER_OUTPUT         (clk_buf)
);

LedPwmDemo demo (
    .reset (1'b0),
    .clk   (clk_buf),
    .rxd   (rxd),
    .pwm   (pwm),
    .led   (led)
);

endmodule
