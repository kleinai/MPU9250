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


module sensor_interface_tb();

   logic clk;
   logic rst_n;
   logic sync;
   logic interrupt;
   
   logic m00_iic_scl_i;
   logic m00_iic_scl_o;
   logic m00_iic_scl_t;
   logic m00_iic_sda_i;
   logic m00_iic_sda_o;
   logic m00_iic_sda_t;
   
   logic s00_axi_arvalid;
   logic [2:0] s00_axi_araddr;
   logic s00_axi_rready;
   
   always
      #5 clk <= !clk; // 10 ns period, 100 MHz
   
   always
      #250000 sync <= !sync; // 250 us period, 4 kHz

   assign (pull1, strong0) m00_iic_scl_i = m00_iic_scl_t? 1 : m00_iic_scl_o;
   assign (pull1, strong0) m00_iic_sda_i = m00_iic_sda_t? 1 : m00_iic_sda_o;
   
   initial begin
      // Clear clock and reset
      clk <= 0;
      rst_n <= 0;
      sync <= 0;
      
      // Clear AXI signals
      s00_axi_arvalid <= 0;
      s00_axi_araddr <= 0;
      s00_axi_rready <= 0;
      
      #40;
      rst_n <= 1;
      
      // Simulation starts here
      
      #140000;
      
      s00_axi_arvalid <= 1;
      s00_axi_araddr <= 0;
      
      #4;
      
      s00_axi_arvalid <= 0;
      
      s00_axi_rready <= 1;
      
      #4;
      
      s00_axi_rready <= 0;
      
      // End simulation
   end
    
   sensor_interface_v1_0 uut (
      // I2C signals
      .m00_iic_scl_i(m00_iic_scl_i),
      .m00_iic_scl_o(m00_iic_scl_o),
      .m00_iic_scl_t(m00_iic_scl_t),
      .m00_iic_sda_i(0 /*m00_iic_sda_i*/),
      .m00_iic_sda_o(m00_iic_sda_o),
      .m00_iic_sda_t(m00_iic_sda_t),
      // AXI signals
      .s00_axi_aclk(clk),
      .s00_axi_aresetn(rst_n),
      .s00_axi_arvalid(s00_axi_arvalid),
      .s00_axi_araddr(s00_axi_araddr),
      .s00_axi_rready(s00_axi_rready),
      .sync(sync),
      .interrupt(interrupt)
   );

endmodule
