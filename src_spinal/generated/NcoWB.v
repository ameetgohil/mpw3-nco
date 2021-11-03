// Generator : SpinalHDL v1.6.0    git head : 73c8d8e2b86b45646e9d0b2e729291f2b65e6be3
// Component : NcoWB
// Git hash  : 2070f360706b01c7582fc075a9da409c9e0c1032



module NcoWB (
  input               io_wb_CYC,
  input               io_wb_STB,
  output              io_wb_ACK,
  input               io_wb_WE,
  input      [29:0]   io_wb_ADR,
  output reg [31:0]   io_wb_DAT_MISO,
  input      [31:0]   io_wb_DAT_MOSI,
  input      [3:0]    io_wb_SEL,
  output     [31:0]   io_angle,
  input      [31:0]   io_xy,
  input               clk,
  input               reset
);
  reg        [31:0]   angle;
  wire                wishboneSlave_askWrite;
  wire                wishboneSlave_askRead;
  wire                wishboneSlave_doWrite;
  wire                wishboneSlave_doRead;
  reg                 _zz_io_wb_ACK;
  wire       [31:0]   wishboneSlave_byteAddress;
  reg        [31:0]   angle_driver;

  always @(*) begin
    io_wb_DAT_MISO = 32'h0;
    case(wishboneSlave_byteAddress)
      32'hc0000000 : begin
        io_wb_DAT_MISO[31 : 0] = angle_driver;
      end
      32'hc0000004 : begin
        io_wb_DAT_MISO[31 : 0] = io_xy;
      end
      default : begin
      end
    endcase
  end

  assign wishboneSlave_askWrite = ((io_wb_CYC && io_wb_STB) && io_wb_WE);
  assign wishboneSlave_askRead = ((io_wb_CYC && io_wb_STB) && (! io_wb_WE));
  assign wishboneSlave_doWrite = (((io_wb_CYC && io_wb_STB) && ((io_wb_CYC && io_wb_ACK) && io_wb_STB)) && io_wb_WE);
  assign wishboneSlave_doRead = (((io_wb_CYC && io_wb_STB) && ((io_wb_CYC && io_wb_ACK) && io_wb_STB)) && (! io_wb_WE));
  assign io_wb_ACK = (_zz_io_wb_ACK && io_wb_STB);
  assign wishboneSlave_byteAddress = ({2'd0,io_wb_ADR} <<< 2);
  assign io_angle = angle;
  always @(posedge clk) begin
    if(reset) begin
      angle <= 32'h0;
      _zz_io_wb_ACK <= 1'b0;
    end else begin
      _zz_io_wb_ACK <= (io_wb_STB && io_wb_CYC);
      angle <= angle_driver;
    end
  end

  always @(posedge clk) begin
    case(wishboneSlave_byteAddress)
      32'hc0000000 : begin
        if(wishboneSlave_doWrite) begin
          angle_driver <= io_wb_DAT_MOSI[31 : 0];
        end
      end
      default : begin
      end
    endcase
  end


endmodule
