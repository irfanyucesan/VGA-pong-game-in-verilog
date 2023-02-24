`timescale 1ns / 1ps

module vgaimage(
input clk,
input btn1,
input btn2,
output vsync,
output hsync,
output reg red,
output reg green,
output reg blue);

parameter POS_SQUARE_SPEED = 3;
parameter NEG_SQUARE_SPEED = -3;
parameter SIZE_OF_BALL = 30;
parameter DELAY_COUNTER = 1250000;

parameter PADDLE_TOP = 400;
parameter PADDLE_BOTTOM = 420;
parameter PADDLE_SPEED = 8;
parameter PADDLE_WIDTH = 100;

wire [9:0] CounterX;
wire [9:0] CounterY;
wire ActiveArea;
wire click;

wire [9:0] ballX_L, ballX_R;
wire [9:0] ballY_T, ballY_B;

reg [9:0] ballX_reg;
reg [9:0] ballY_reg;

wire [9:0] ballX_reg_next;
wire [9:0] ballY_reg_next;

reg [9:0] ballX_speed_reg;
reg [9:0] ballY_speed_reg;

reg [9:0] ballX_speed_next;
reg [9:0] ballY_speed_next;

wire ball;

wire [9:0] paddle_r, paddle_l;

reg [9:0] paddleX_reg;

reg [20:0] paddle_counter;

wire paddle_en;
wire paddle;

vhsync syncgen
(
	.clk(clk),
	.hsync(hsync),
	.vsync(vsync),
	.ActiveArea(ActiveArea),
	.CounterX(CounterX),
	.CounterY(CounterY)
);

assign ballX_L = ballX_reg;
assign ballY_T = ballY_reg;
assign ballX_R = ballX_L + SIZE_OF_BALL -1;
assign ballY_B = ballY_T + SIZE_OF_BALL -1;

always @(posedge clk) begin
    ballX_reg <= ballX_reg_next;
    ballY_reg <= ballY_reg_next;
    ballX_speed_reg <= ballX_speed_next;
    ballY_speed_reg <= ballY_speed_next;
end

assign click = ((CounterX==1) && (CounterY==1)) ? 1:0;

assign ballX_reg_next = (click) ? (ballX_reg + ballX_speed_reg) : ballX_reg;
assign ballY_reg_next = (click) ? (ballY_reg + ballY_speed_reg) : ballY_reg;                           

assign ball = (ballX_L < CounterX ) && (CounterX < ballX_R) && (ballY_T < CounterY) && (CounterY < ballY_B);

assign paddle_en = btn1 ^ btn2;

assign paddle_l = paddleX_reg;
assign paddle_r = paddleX_reg + PADDLE_WIDTH -1;

assign paddle = (CounterX < paddle_r) && (paddle_l < CounterX) && (CounterY < PADDLE_BOTTOM) && (PADDLE_TOP < CounterY);

always @(posedge clk ) begin
    ballX_speed_next = ballX_speed_reg;
    ballY_speed_next = ballY_speed_reg;
        if (ballX_L < 25) begin
            ballX_speed_next = POS_SQUARE_SPEED;
        end
        else if (ballX_R > 615) begin
            ballX_speed_next = NEG_SQUARE_SPEED;
        end
        else if (ballY_T < 25) begin
            ballY_speed_next = POS_SQUARE_SPEED;
        end
        else if (ballY_B > 455) begin
            ballY_speed_next = NEG_SQUARE_SPEED;
        end
        else if ((ballY_B < PADDLE_BOTTOM) && (PADDLE_TOP < ballY_B) && (paddle_l < ballX_R) && (ballX_L < paddle_r)) begin
            ballY_speed_next = NEG_SQUARE_SPEED;
        end
        else if ((PADDLE_TOP < ballY_T) && (ballY_T < PADDLE_BOTTOM) && (paddle_l < ballX_R) && (ballX_L < paddle_r)) begin
            ballY_speed_next = POS_SQUARE_SPEED;
        end
end

always @(posedge clk)begin
	if(paddle_en==1'b1) begin
		paddle_counter = paddle_counter+1;
		if (paddle_counter == DELAY_COUNTER) begin
			paddle_counter<=0;
		end
	end

    if ((btn1==1'b1) && (paddle_counter == DELAY_COUNTER)) begin
        paddleX_reg = paddleX_reg + PADDLE_SPEED;
    end
    else if ((btn2==1'b1) && (paddle_counter == DELAY_COUNTER)) begin
        paddleX_reg = paddleX_reg - PADDLE_SPEED;
    end
end

always @(posedge clk) begin

    if((ActiveArea) && (CounterY < 25)) begin 
        {blue,green,red}<=3'b111;
    end
    else if((ActiveArea) && (CounterY > 455)) begin 
        {blue,green,red}<=3'b111;
    end
    else if ((ActiveArea) && (CounterX < 25)) begin
        {blue,green,red}<= 3'b111;
    end
    else if ((ActiveArea) && (CounterX > 615)) begin
        {blue,green,red}<= 3'b111;
    end
    else if ((ActiveArea) && (ball)) begin
        {blue,green,red}<= 3'b011;
    end
    else if ((ActiveArea) && (paddle)) begin
        {blue,green,red}<= 3'b101;
    end
    else if ((ActiveArea)) begin
        {blue,green,red}<= 3'b110;
    end
    else begin
        {blue,green,red}<=3'b000;
    end
end

endmodule