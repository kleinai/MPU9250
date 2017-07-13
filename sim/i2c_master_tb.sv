`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2017 10:55:37 AM
// Design Name: 
// Module Name: sensor_interface_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module i2c_master_tb();

   logic clk;
   logic rst_n;
   logic en;
   logic[6:0] addr;
   logic write;
   logic[7:0] wdata;
   logic[7:0] rdata;
   logic act;
   logic err;
   logic next;
   logic multibyte_n;

   logic scl_i;
   logic scl_t;
   logic scl_o;
   logic sda_i;
   logic sda_t;
   logic sda_o;

   assign (pull1, strong0) scl_i = scl_t? 1 : scl_o;
   assign (pull1, strong0) sda_i = sda_t? 1 : sda_o;

   always 
      #5 clk <= !clk;
   
   initial begin
      // Clear clock and reset
      clk <= 0;
      rst_n <= 0;
      
      // Clear signals
      en <= 0;
      addr <= 0;
      write <= 0;
      wdata <= 0;
      multibyte_n <= 0;
      
      #40;
      rst_n <= 1;
      
      // Simulation starts here

      en <= 1;
      addr <= 0;
      write <= 1;
      wdata <= 8'h1234;

      // Try another byte
      @(posedge next)
      en <= 1;
      addr <= 0;
      write <= 1;
      wdata <= 8'h5678;

      // Change to read
      @(posedge next)
      en <= 1;
      addr <= 0;
      write <= 0;
      wdata <= 8'h9ABC;

      // Change address read
      @(posedge next)
      en <= 1;
      addr <= 1;
      write <= 0;
      wdata <= 8'hDEF0;

      // Release enable
      @(posedge next)
      en <= 0;
      addr <= 1;
      write <= 0;
      wdata <= 8'h1234;
      
      // End simulation
   end
    

   i2c_master #(
      .SYSTEM_CLOCK(100_000_000),
      .BUS_CLOCK(400_000)
   ) uut (
      .*
   );

endmodule