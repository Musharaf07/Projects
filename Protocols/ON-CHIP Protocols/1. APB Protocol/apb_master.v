//APB Master
module apb_master (
  input               pclk,
  input               presetn,
 // M to S
  output              psel,
  output              penable,
  output      [3:0]   paddr,
  output              pwrite,
  output      [15:0]  pwdata,
// S to M
  input               pready,
  input       [15:0]  prdata,
//M
  input               rw,  
  input               transfer,   
  input       [3:0]   rd_addr,
  input       [3:0]   wr_addr,
  input       [15:0]  wr_val,
  output reg  [15:0]  rd_val
);

  parameter IDLE   = 2'b00, SETUP  = 2'b01, ACCESS = 2'b10;
  reg [1:0] cur_state, nxt_state;
  
  reg [3:0]   addr_reg;
  reg [15:0]  data_reg;
  reg         wr_en;

  always @(posedge pclk) begin
    if (!presetn)
      cur_state <= IDLE;
    else
      cur_state <= nxt_state;
  end

  always @(*) begin
    nxt_state = cur_state;   
    case (cur_state)
      IDLE:   if (transfer) nxt_state = SETUP;
      SETUP:  nxt_state = ACCESS;
      ACCESS: begin
        if (pready && transfer)
          nxt_state = SETUP;
        else if (pready && !transfer)
          nxt_state = IDLE;
        else
          nxt_state = ACCESS;
      end
      default: nxt_state = IDLE;
    endcase
  end

  always @(*) begin
    wr_en    = 1'b0;
    addr_reg = 4'd0;
    data_reg = 16'd0;
    rd_val   = 16'd0;

    if ((cur_state == SETUP) || (cur_state == ACCESS)) begin
      if (rw) begin
        wr_en    = 1'b1;
        addr_reg = wr_addr;
        data_reg = wr_val;
      end
      else begin
        wr_en    = 1'b0;
        addr_reg = rd_addr;
        rd_val   = prdata;
      end
    end
  end

  assign psel    = (cur_state != IDLE);
  assign penable = (cur_state == ACCESS);
  assign pwrite  = wr_en;
  assign paddr   = addr_reg;
  assign pwdata  = (wr_en) ? data_reg : 16'd0;

endmodule
