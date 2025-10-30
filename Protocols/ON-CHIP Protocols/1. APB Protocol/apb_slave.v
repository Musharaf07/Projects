//APB Slave
module apb_slave (
  input              pclk,
  input              presetn,
  input              psel,
  input              penable,
  input              pwrite,
  input      [3:0]   paddr,
  input      [15:0]  pwdata,
  output reg         pready,
  output reg [15:0]  prdata
);

  reg [15:0] mem [0:15];
  reg [2:0]  wait_cnt;

  always @(posedge pclk ) begin
    if (!presetn) begin
      pready    <= 0;
      prdata    <= 16'd0;
      wait_cnt  <= 0;
    end
    else begin
      if (psel && penable) begin
        if (wait_cnt < 2) begin
          pready    <= 0;     
          wait_cnt <= wait_cnt + 1;
        end
        else begin
          pready    <= 1;  
          wait_cnt  <= 0;
          
          if (pwrite) begin
            mem[paddr] <= pwdata;
          end
          else begin
            prdata <= mem[paddr]; 
          end
        end
      end
      else begin
        pready    <= 0;
        wait_cnt  <= 0;
      end
    end
  end

endmodule
