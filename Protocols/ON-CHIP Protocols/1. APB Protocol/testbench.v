module apb_tb;
  reg pclk, presetn;
  wire        psel, penable, pwrite, pready;
  wire [3:0]  paddr;
  wire [15:0] pwdata, prdata;

  reg         rw, transfer;
  reg  [3:0]  rd_addr, wr_addr;
  reg  [15:0] wr_val;
  wire [15:0] rd_val;

  apb_master master1 (
    .pclk(pclk),
    .presetn(presetn),
    .psel(psel),
    .penable(penable),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .pready(pready),
    .prdata(prdata),
    .rw(rw),
    .transfer(transfer),
    .rd_addr(rd_addr),
    .wr_addr(wr_addr),
    .wr_val(wr_val),
    .rd_val(rd_val)
  );

  apb_slave slave1 (
    .pclk(pclk),
    .presetn(presetn),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .pready(pready),
    .prdata(prdata)
  );

  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  initial begin
    presetn = 0;
    rw = 0;
    transfer = 0;
    wr_addr = 0;
    rd_addr = 0;
    wr_val = 0;
    #20 presetn = 1;
  end

  task apb_write(input [3:0] addr_in, input [15:0] data_in);
  begin
    @(posedge pclk);
    rw  = 1;
    wr_addr = addr_in;
    wr_val  = data_in;
    transfer   = 1;
    @(posedge pclk);
    transfer   = 0;
    wait (pready);   
    @(posedge pclk);
    $display("APB WRITE: Addr=%h, Data=%h", addr_in, wr_val);
  end
  endtask

  task apb_read(input [3:0] addr_in);
  begin
    @(posedge pclk);
    rw  = 0;
    rd_addr = addr_in;
    transfer   = 1;
    @(posedge pclk);
    transfer   = 0;
    wait (pready);
    @(posedge pclk);
    $display("APB READ: Addr=%h, Data=%h", addr_in, rd_val);
  end
  endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    @(posedge presetn); 

    apb_write(4'h2, 16'hCCAD);
    apb_write(4'h5, 16'hBCAE);
    
    apb_read(4'h2);
    apb_read(4'h5);
    
    #100 $finish;
  end

endmodule
