`timescale 1ns / 1ps
`default_nettype none

module tlcfsm(
    output reg [2:0] state,          // output for debugging
    output reg RstCount,             // use an always block
    /* another always block for these as well */
    output reg [1:0] highwaySignal, farmSignal,
    input wire [30:0] Count,         // use n computed earlier (n=31)
    input wire Clk, Rst,              // clock and reset
    input wire farmSensor
);

    // State Encoding
    localparam S0=3'd0,
              S1=3'd1,
              S2=3'd2,
              S3=3'd3,
              S4=3'd4,
              S5=3'd5;

    // Traffic Light Colors
    localparam GREEN=2'b11,
              YELLOW=2'b10,
              RED=2'b01;

    // Internal Signal
    reg [2:0] nextState;

    // Sequential Logic: State Transition
    always @(posedge Clk) begin
        if (Rst)
            state <= S0;
        else
            state <= nextState;
    end

    // Combinational Logic: Next State and Output Logic
    always @(*) begin
        // Default assignments to prevent latches
        nextState=state;
        RstCount=1'b0;
        highwaySignal=RED;
        farmSignal=RED;

        case (state)
            S0: begin // Red/Red for 1 sec
                highwaySignal=RED;
                farmSignal=RED;
                if (Count == 50000000) begin
                    RstCount=1'b1;
                    nextState=S1;
                end
            end

            S1: begin // Green/Red for 30 sec
                highwaySignal=GREEN;
                farmSignal=RED;
                if (Count == 1500000000 && farmSensor) begin
                    RstCount=1'b1;
                    nextState=S2;
                end
            end

            S2: begin // Yellow/Red for 3 sec
                highwaySignal=YELLOW;
                farmSignal=RED;
                if (Count == 150000000) begin
                    RstCount=1'b1;
                    nextState=S3;
                end
            end

            S3: begin // Red/Red for 1 sec
                highwaySignal=RED;
                farmSignal=RED;
                if (Count == 50000000) begin
                    RstCount=1'b1;
                    nextState=S4;
                end
            end

            S4: begin 
                highwaySignal = RED;
                farmSignal = GREEN;
                if (Count >= 150000000) begin
                    if (!farmSensor || Count >= 900000000) begin
                        RstCount = 1'b1;
                        nextState = S5;
                    end
                end
            end

            S5: begin // Red/Yellow for 3 sec
                highwaySignal=RED;
                farmSignal=YELLOW;
                if (Count == 150000000) begin
                    RstCount=1'b1;
                    nextState=S0;
                end
            end
            
            default: begin
                nextState=S0;
                RstCount=1'b1; // Reset counter if in unknown state
            end
        endcase
    end

endmodule