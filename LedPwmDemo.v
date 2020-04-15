// Generator : SpinalHDL v1.4.0    git head : ecb5a80b713566f417ea3ea061f9969e73770a7f
// Date      : 15/04/2020, 00:33:15
// Component : LedPwmDemo


`define UartParityType_defaultEncoding_type [1:0]
`define UartParityType_defaultEncoding_NONE 2'b00
`define UartParityType_defaultEncoding_EVEN 2'b01
`define UartParityType_defaultEncoding_ODD 2'b10

`define UartStopType_defaultEncoding_type [0:0]
`define UartStopType_defaultEncoding_ONE 1'b0
`define UartStopType_defaultEncoding_TWO 1'b1

`define fsm_enumDefinition_defaultEncoding_type [1:0]
`define fsm_enumDefinition_defaultEncoding_boot 2'b00
`define fsm_enumDefinition_defaultEncoding_fsm_READ_ADDR 2'b01
`define fsm_enumDefinition_defaultEncoding_fsm_READ_DATA 2'b10
`define fsm_enumDefinition_defaultEncoding_fsm_WRITE_PWM 2'b11

`define UartCtrlTxState_defaultEncoding_type [2:0]
`define UartCtrlTxState_defaultEncoding_IDLE 3'b000
`define UartCtrlTxState_defaultEncoding_START 3'b001
`define UartCtrlTxState_defaultEncoding_DATA 3'b010
`define UartCtrlTxState_defaultEncoding_PARITY 3'b011
`define UartCtrlTxState_defaultEncoding_STOP 3'b100

`define UartCtrlRxState_defaultEncoding_type [2:0]
`define UartCtrlRxState_defaultEncoding_IDLE 3'b000
`define UartCtrlRxState_defaultEncoding_START 3'b001
`define UartCtrlRxState_defaultEncoding_DATA 3'b010
`define UartCtrlRxState_defaultEncoding_PARITY 3'b011
`define UartCtrlRxState_defaultEncoding_STOP 3'b100


module BufferCC (
  input               io_initial,
  input               io_dataIn,
  output              io_dataOut,
  input               clk,
  input               reset 
);
  reg                 buffers_0;
  reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      buffers_0 <= io_initial;
      buffers_1 <= io_initial;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module UartCtrlTx (
  input      [2:0]    io_configFrame_dataLength,
  input      `UartStopType_defaultEncoding_type io_configFrame_stop,
  input      `UartParityType_defaultEncoding_type io_configFrame_parity,
  input               io_samplingTick,
  input               io_write_valid,
  output reg          io_write_ready,
  input      [7:0]    io_write_payload,
  input               io_cts,
  output              io_txd,
  input               io_break,
  input               clk,
  input               reset 
);
  wire                _zz_2_;
  wire       [0:0]    _zz_3_;
  wire       [2:0]    _zz_4_;
  wire       [0:0]    _zz_5_;
  wire       [2:0]    _zz_6_;
  reg                 clockDivider_counter_willIncrement;
  wire                clockDivider_counter_willClear;
  reg        [2:0]    clockDivider_counter_valueNext;
  reg        [2:0]    clockDivider_counter_value;
  wire                clockDivider_counter_willOverflowIfInc;
  wire                clockDivider_counter_willOverflow;
  reg        [2:0]    tickCounter_value;
  reg        `UartCtrlTxState_defaultEncoding_type stateMachine_state;
  reg                 stateMachine_parity;
  reg                 stateMachine_txd;
  reg                 _zz_1_;
  `ifndef SYNTHESIS
  reg [23:0] io_configFrame_stop_string;
  reg [31:0] io_configFrame_parity_string;
  reg [47:0] stateMachine_state_string;
  `endif


  assign _zz_2_ = (tickCounter_value == io_configFrame_dataLength);
  assign _zz_3_ = clockDivider_counter_willIncrement;
  assign _zz_4_ = {2'd0, _zz_3_};
  assign _zz_5_ = ((io_configFrame_stop == `UartStopType_defaultEncoding_ONE) ? (1'b0) : (1'b1));
  assign _zz_6_ = {2'd0, _zz_5_};
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_configFrame_stop)
      `UartStopType_defaultEncoding_ONE : io_configFrame_stop_string = "ONE";
      `UartStopType_defaultEncoding_TWO : io_configFrame_stop_string = "TWO";
      default : io_configFrame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_configFrame_parity)
      `UartParityType_defaultEncoding_NONE : io_configFrame_parity_string = "NONE";
      `UartParityType_defaultEncoding_EVEN : io_configFrame_parity_string = "EVEN";
      `UartParityType_defaultEncoding_ODD : io_configFrame_parity_string = "ODD ";
      default : io_configFrame_parity_string = "????";
    endcase
  end
  always @(*) begin
    case(stateMachine_state)
      `UartCtrlTxState_defaultEncoding_IDLE : stateMachine_state_string = "IDLE  ";
      `UartCtrlTxState_defaultEncoding_START : stateMachine_state_string = "START ";
      `UartCtrlTxState_defaultEncoding_DATA : stateMachine_state_string = "DATA  ";
      `UartCtrlTxState_defaultEncoding_PARITY : stateMachine_state_string = "PARITY";
      `UartCtrlTxState_defaultEncoding_STOP : stateMachine_state_string = "STOP  ";
      default : stateMachine_state_string = "??????";
    endcase
  end
  `endif

  always @ (*) begin
    clockDivider_counter_willIncrement = 1'b0;
    if(io_samplingTick)begin
      clockDivider_counter_willIncrement = 1'b1;
    end
  end

  assign clockDivider_counter_willClear = 1'b0;
  assign clockDivider_counter_willOverflowIfInc = (clockDivider_counter_value == (3'b111));
  assign clockDivider_counter_willOverflow = (clockDivider_counter_willOverflowIfInc && clockDivider_counter_willIncrement);
  always @ (*) begin
    clockDivider_counter_valueNext = (clockDivider_counter_value + _zz_4_);
    if(clockDivider_counter_willClear)begin
      clockDivider_counter_valueNext = (3'b000);
    end
  end

  always @ (*) begin
    stateMachine_txd = 1'b1;
    case(stateMachine_state)
      `UartCtrlTxState_defaultEncoding_IDLE : begin
      end
      `UartCtrlTxState_defaultEncoding_START : begin
        stateMachine_txd = 1'b0;
      end
      `UartCtrlTxState_defaultEncoding_DATA : begin
        stateMachine_txd = io_write_payload[tickCounter_value];
      end
      `UartCtrlTxState_defaultEncoding_PARITY : begin
        stateMachine_txd = stateMachine_parity;
      end
      default : begin
      end
    endcase
  end

  always @ (*) begin
    io_write_ready = io_break;
    case(stateMachine_state)
      `UartCtrlTxState_defaultEncoding_IDLE : begin
      end
      `UartCtrlTxState_defaultEncoding_START : begin
      end
      `UartCtrlTxState_defaultEncoding_DATA : begin
        if(clockDivider_counter_willOverflow)begin
          if(_zz_2_)begin
            io_write_ready = 1'b1;
          end
        end
      end
      `UartCtrlTxState_defaultEncoding_PARITY : begin
      end
      default : begin
      end
    endcase
  end

  assign io_txd = _zz_1_;
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      clockDivider_counter_value <= (3'b000);
      stateMachine_state <= `UartCtrlTxState_defaultEncoding_IDLE;
      _zz_1_ <= 1'b1;
    end else begin
      clockDivider_counter_value <= clockDivider_counter_valueNext;
      case(stateMachine_state)
        `UartCtrlTxState_defaultEncoding_IDLE : begin
          if(((io_write_valid && (! io_cts)) && clockDivider_counter_willOverflow))begin
            stateMachine_state <= `UartCtrlTxState_defaultEncoding_START;
          end
        end
        `UartCtrlTxState_defaultEncoding_START : begin
          if(clockDivider_counter_willOverflow)begin
            stateMachine_state <= `UartCtrlTxState_defaultEncoding_DATA;
          end
        end
        `UartCtrlTxState_defaultEncoding_DATA : begin
          if(clockDivider_counter_willOverflow)begin
            if(_zz_2_)begin
              if((io_configFrame_parity == `UartParityType_defaultEncoding_NONE))begin
                stateMachine_state <= `UartCtrlTxState_defaultEncoding_STOP;
              end else begin
                stateMachine_state <= `UartCtrlTxState_defaultEncoding_PARITY;
              end
            end
          end
        end
        `UartCtrlTxState_defaultEncoding_PARITY : begin
          if(clockDivider_counter_willOverflow)begin
            stateMachine_state <= `UartCtrlTxState_defaultEncoding_STOP;
          end
        end
        default : begin
          if(clockDivider_counter_willOverflow)begin
            if((tickCounter_value == _zz_6_))begin
              stateMachine_state <= (io_write_valid ? `UartCtrlTxState_defaultEncoding_START : `UartCtrlTxState_defaultEncoding_IDLE);
            end
          end
        end
      endcase
      _zz_1_ <= (stateMachine_txd && (! io_break));
    end
  end

  always @ (posedge clk) begin
    if(clockDivider_counter_willOverflow)begin
      tickCounter_value <= (tickCounter_value + (3'b001));
    end
    if(clockDivider_counter_willOverflow)begin
      stateMachine_parity <= (stateMachine_parity ^ stateMachine_txd);
    end
    case(stateMachine_state)
      `UartCtrlTxState_defaultEncoding_IDLE : begin
      end
      `UartCtrlTxState_defaultEncoding_START : begin
        if(clockDivider_counter_willOverflow)begin
          stateMachine_parity <= (io_configFrame_parity == `UartParityType_defaultEncoding_ODD);
          tickCounter_value <= (3'b000);
        end
      end
      `UartCtrlTxState_defaultEncoding_DATA : begin
        if(clockDivider_counter_willOverflow)begin
          if(_zz_2_)begin
            tickCounter_value <= (3'b000);
          end
        end
      end
      `UartCtrlTxState_defaultEncoding_PARITY : begin
        if(clockDivider_counter_willOverflow)begin
          tickCounter_value <= (3'b000);
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module UartCtrlRx (
  input      [2:0]    io_configFrame_dataLength,
  input      `UartStopType_defaultEncoding_type io_configFrame_stop,
  input      `UartParityType_defaultEncoding_type io_configFrame_parity,
  input               io_samplingTick,
  output              io_read_valid,
  input               io_read_ready,
  output     [7:0]    io_read_payload,
  input               io_rxd,
  output              io_rts,
  output reg          io_error,
  output              io_break,
  input               clk,
  input               reset 
);
  wire                _zz_2_;
  wire                io_rxd_buffercc_io_dataOut;
  wire                _zz_3_;
  wire                _zz_4_;
  wire                _zz_5_;
  wire                _zz_6_;
  wire       [0:0]    _zz_7_;
  wire       [2:0]    _zz_8_;
  wire                _zz_9_;
  wire                _zz_10_;
  wire                _zz_11_;
  wire                _zz_12_;
  wire                _zz_13_;
  wire                _zz_14_;
  wire                _zz_15_;
  reg                 _zz_1_;
  wire                sampler_synchroniser;
  wire                sampler_samples_0;
  reg                 sampler_samples_1;
  reg                 sampler_samples_2;
  reg                 sampler_samples_3;
  reg                 sampler_samples_4;
  reg                 sampler_value;
  reg                 sampler_tick;
  reg        [2:0]    bitTimer_counter;
  reg                 bitTimer_tick;
  reg        [2:0]    bitCounter_value;
  reg        [6:0]    break_counter;
  wire                break_valid;
  reg        `UartCtrlRxState_defaultEncoding_type stateMachine_state;
  reg                 stateMachine_parity;
  reg        [7:0]    stateMachine_shifter;
  reg                 stateMachine_validReg;
  `ifndef SYNTHESIS
  reg [23:0] io_configFrame_stop_string;
  reg [31:0] io_configFrame_parity_string;
  reg [47:0] stateMachine_state_string;
  `endif


  assign _zz_3_ = (stateMachine_parity == sampler_value);
  assign _zz_4_ = (! sampler_value);
  assign _zz_5_ = ((sampler_tick && (! sampler_value)) && (! break_valid));
  assign _zz_6_ = (bitCounter_value == io_configFrame_dataLength);
  assign _zz_7_ = ((io_configFrame_stop == `UartStopType_defaultEncoding_ONE) ? (1'b0) : (1'b1));
  assign _zz_8_ = {2'd0, _zz_7_};
  assign _zz_9_ = ((((1'b0 || ((_zz_14_ && sampler_samples_1) && sampler_samples_2)) || (((_zz_15_ && sampler_samples_0) && sampler_samples_1) && sampler_samples_3)) || (((1'b1 && sampler_samples_0) && sampler_samples_2) && sampler_samples_3)) || (((1'b1 && sampler_samples_1) && sampler_samples_2) && sampler_samples_3));
  assign _zz_10_ = (((1'b1 && sampler_samples_0) && sampler_samples_1) && sampler_samples_4);
  assign _zz_11_ = ((1'b1 && sampler_samples_0) && sampler_samples_2);
  assign _zz_12_ = (1'b1 && sampler_samples_1);
  assign _zz_13_ = 1'b1;
  assign _zz_14_ = (1'b1 && sampler_samples_0);
  assign _zz_15_ = 1'b1;
  BufferCC io_rxd_buffercc ( 
    .io_initial    (_zz_2_                      ), //i
    .io_dataIn     (io_rxd                      ), //i
    .io_dataOut    (io_rxd_buffercc_io_dataOut  ), //o
    .clk           (clk                         ), //i
    .reset         (reset                       )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_configFrame_stop)
      `UartStopType_defaultEncoding_ONE : io_configFrame_stop_string = "ONE";
      `UartStopType_defaultEncoding_TWO : io_configFrame_stop_string = "TWO";
      default : io_configFrame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_configFrame_parity)
      `UartParityType_defaultEncoding_NONE : io_configFrame_parity_string = "NONE";
      `UartParityType_defaultEncoding_EVEN : io_configFrame_parity_string = "EVEN";
      `UartParityType_defaultEncoding_ODD : io_configFrame_parity_string = "ODD ";
      default : io_configFrame_parity_string = "????";
    endcase
  end
  always @(*) begin
    case(stateMachine_state)
      `UartCtrlRxState_defaultEncoding_IDLE : stateMachine_state_string = "IDLE  ";
      `UartCtrlRxState_defaultEncoding_START : stateMachine_state_string = "START ";
      `UartCtrlRxState_defaultEncoding_DATA : stateMachine_state_string = "DATA  ";
      `UartCtrlRxState_defaultEncoding_PARITY : stateMachine_state_string = "PARITY";
      `UartCtrlRxState_defaultEncoding_STOP : stateMachine_state_string = "STOP  ";
      default : stateMachine_state_string = "??????";
    endcase
  end
  `endif

  always @ (*) begin
    io_error = 1'b0;
    case(stateMachine_state)
      `UartCtrlRxState_defaultEncoding_IDLE : begin
      end
      `UartCtrlRxState_defaultEncoding_START : begin
      end
      `UartCtrlRxState_defaultEncoding_DATA : begin
      end
      `UartCtrlRxState_defaultEncoding_PARITY : begin
        if(bitTimer_tick)begin
          if(! _zz_3_) begin
            io_error = 1'b1;
          end
        end
      end
      default : begin
        if(bitTimer_tick)begin
          if(_zz_4_)begin
            io_error = 1'b1;
          end
        end
      end
    endcase
  end

  assign io_rts = _zz_1_;
  assign _zz_2_ = 1'b0;
  assign sampler_synchroniser = io_rxd_buffercc_io_dataOut;
  assign sampler_samples_0 = sampler_synchroniser;
  always @ (*) begin
    bitTimer_tick = 1'b0;
    if(sampler_tick)begin
      if((bitTimer_counter == (3'b000)))begin
        bitTimer_tick = 1'b1;
      end
    end
  end

  assign break_valid = (break_counter == 7'h68);
  assign io_break = break_valid;
  assign io_read_valid = stateMachine_validReg;
  assign io_read_payload = stateMachine_shifter;
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      _zz_1_ <= 1'b0;
      sampler_samples_1 <= 1'b1;
      sampler_samples_2 <= 1'b1;
      sampler_samples_3 <= 1'b1;
      sampler_samples_4 <= 1'b1;
      sampler_value <= 1'b1;
      sampler_tick <= 1'b0;
      break_counter <= 7'h0;
      stateMachine_state <= `UartCtrlRxState_defaultEncoding_IDLE;
      stateMachine_validReg <= 1'b0;
    end else begin
      _zz_1_ <= (! io_read_ready);
      if(io_samplingTick)begin
        sampler_samples_1 <= sampler_samples_0;
      end
      if(io_samplingTick)begin
        sampler_samples_2 <= sampler_samples_1;
      end
      if(io_samplingTick)begin
        sampler_samples_3 <= sampler_samples_2;
      end
      if(io_samplingTick)begin
        sampler_samples_4 <= sampler_samples_3;
      end
      sampler_value <= ((((((_zz_9_ || _zz_10_) || (_zz_11_ && sampler_samples_4)) || ((_zz_12_ && sampler_samples_2) && sampler_samples_4)) || (((_zz_13_ && sampler_samples_0) && sampler_samples_3) && sampler_samples_4)) || (((1'b1 && sampler_samples_1) && sampler_samples_3) && sampler_samples_4)) || (((1'b1 && sampler_samples_2) && sampler_samples_3) && sampler_samples_4));
      sampler_tick <= io_samplingTick;
      if(sampler_value)begin
        break_counter <= 7'h0;
      end else begin
        if((io_samplingTick && (! break_valid)))begin
          break_counter <= (break_counter + 7'h01);
        end
      end
      stateMachine_validReg <= 1'b0;
      case(stateMachine_state)
        `UartCtrlRxState_defaultEncoding_IDLE : begin
          if(_zz_5_)begin
            stateMachine_state <= `UartCtrlRxState_defaultEncoding_START;
          end
        end
        `UartCtrlRxState_defaultEncoding_START : begin
          if(bitTimer_tick)begin
            stateMachine_state <= `UartCtrlRxState_defaultEncoding_DATA;
            if((sampler_value == 1'b1))begin
              stateMachine_state <= `UartCtrlRxState_defaultEncoding_IDLE;
            end
          end
        end
        `UartCtrlRxState_defaultEncoding_DATA : begin
          if(bitTimer_tick)begin
            if(_zz_6_)begin
              if((io_configFrame_parity == `UartParityType_defaultEncoding_NONE))begin
                stateMachine_state <= `UartCtrlRxState_defaultEncoding_STOP;
                stateMachine_validReg <= 1'b1;
              end else begin
                stateMachine_state <= `UartCtrlRxState_defaultEncoding_PARITY;
              end
            end
          end
        end
        `UartCtrlRxState_defaultEncoding_PARITY : begin
          if(bitTimer_tick)begin
            if(_zz_3_)begin
              stateMachine_state <= `UartCtrlRxState_defaultEncoding_STOP;
              stateMachine_validReg <= 1'b1;
            end else begin
              stateMachine_state <= `UartCtrlRxState_defaultEncoding_IDLE;
            end
          end
        end
        default : begin
          if(bitTimer_tick)begin
            if(_zz_4_)begin
              stateMachine_state <= `UartCtrlRxState_defaultEncoding_IDLE;
            end else begin
              if((bitCounter_value == _zz_8_))begin
                stateMachine_state <= `UartCtrlRxState_defaultEncoding_IDLE;
              end
            end
          end
        end
      endcase
    end
  end

  always @ (posedge clk) begin
    if(sampler_tick)begin
      bitTimer_counter <= (bitTimer_counter - (3'b001));
    end
    if(bitTimer_tick)begin
      bitCounter_value <= (bitCounter_value + (3'b001));
    end
    if(bitTimer_tick)begin
      stateMachine_parity <= (stateMachine_parity ^ sampler_value);
    end
    case(stateMachine_state)
      `UartCtrlRxState_defaultEncoding_IDLE : begin
        if(_zz_5_)begin
          bitTimer_counter <= (3'b010);
        end
      end
      `UartCtrlRxState_defaultEncoding_START : begin
        if(bitTimer_tick)begin
          bitCounter_value <= (3'b000);
          stateMachine_parity <= (io_configFrame_parity == `UartParityType_defaultEncoding_ODD);
        end
      end
      `UartCtrlRxState_defaultEncoding_DATA : begin
        if(bitTimer_tick)begin
          stateMachine_shifter[bitCounter_value] <= sampler_value;
          if(_zz_6_)begin
            bitCounter_value <= (3'b000);
          end
        end
      end
      `UartCtrlRxState_defaultEncoding_PARITY : begin
        if(bitTimer_tick)begin
          bitCounter_value <= (3'b000);
        end
      end
      default : begin
      end
    endcase
  end


endmodule

module UartCtrl (
  input      [2:0]    io_config_frame_dataLength,
  input      `UartStopType_defaultEncoding_type io_config_frame_stop,
  input      `UartParityType_defaultEncoding_type io_config_frame_parity,
  input      [19:0]   io_config_clockDivider,
  input               io_write_valid,
  output reg          io_write_ready,
  input      [7:0]    io_write_payload,
  output              io_read_valid,
  input               io_read_ready,
  output     [7:0]    io_read_payload,
  output              io_uart_txd,
  input               io_uart_rxd,
  output              io_readError,
  input               io_writeBreak,
  output              io_readBreak,
  input               clk,
  input               reset 
);
  wire                _zz_1_;
  wire                tx_io_write_ready;
  wire                tx_io_txd;
  wire                rx_io_read_valid;
  wire       [7:0]    rx_io_read_payload;
  wire                rx_io_rts;
  wire                rx_io_error;
  wire                rx_io_break;
  reg        [19:0]   clockDivider_counter;
  wire                clockDivider_tick;
  reg                 io_write_thrown_valid;
  wire                io_write_thrown_ready;
  wire       [7:0]    io_write_thrown_payload;
  `ifndef SYNTHESIS
  reg [23:0] io_config_frame_stop_string;
  reg [31:0] io_config_frame_parity_string;
  `endif


  UartCtrlTx tx ( 
    .io_configFrame_dataLength    (io_config_frame_dataLength[2:0]  ), //i
    .io_configFrame_stop          (io_config_frame_stop             ), //i
    .io_configFrame_parity        (io_config_frame_parity[1:0]      ), //i
    .io_samplingTick              (clockDivider_tick                ), //i
    .io_write_valid               (io_write_thrown_valid            ), //i
    .io_write_ready               (tx_io_write_ready                ), //o
    .io_write_payload             (io_write_thrown_payload[7:0]     ), //i
    .io_cts                       (_zz_1_                           ), //i
    .io_txd                       (tx_io_txd                        ), //o
    .io_break                     (io_writeBreak                    ), //i
    .clk                          (clk                              ), //i
    .reset                        (reset                            )  //i
  );
  UartCtrlRx rx ( 
    .io_configFrame_dataLength    (io_config_frame_dataLength[2:0]  ), //i
    .io_configFrame_stop          (io_config_frame_stop             ), //i
    .io_configFrame_parity        (io_config_frame_parity[1:0]      ), //i
    .io_samplingTick              (clockDivider_tick                ), //i
    .io_read_valid                (rx_io_read_valid                 ), //o
    .io_read_ready                (io_read_ready                    ), //i
    .io_read_payload              (rx_io_read_payload[7:0]          ), //o
    .io_rxd                       (io_uart_rxd                      ), //i
    .io_rts                       (rx_io_rts                        ), //o
    .io_error                     (rx_io_error                      ), //o
    .io_break                     (rx_io_break                      ), //o
    .clk                          (clk                              ), //i
    .reset                        (reset                            )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(io_config_frame_stop)
      `UartStopType_defaultEncoding_ONE : io_config_frame_stop_string = "ONE";
      `UartStopType_defaultEncoding_TWO : io_config_frame_stop_string = "TWO";
      default : io_config_frame_stop_string = "???";
    endcase
  end
  always @(*) begin
    case(io_config_frame_parity)
      `UartParityType_defaultEncoding_NONE : io_config_frame_parity_string = "NONE";
      `UartParityType_defaultEncoding_EVEN : io_config_frame_parity_string = "EVEN";
      `UartParityType_defaultEncoding_ODD : io_config_frame_parity_string = "ODD ";
      default : io_config_frame_parity_string = "????";
    endcase
  end
  `endif

  assign clockDivider_tick = (clockDivider_counter == 20'h0);
  always @ (*) begin
    io_write_thrown_valid = io_write_valid;
    if(rx_io_break)begin
      io_write_thrown_valid = 1'b0;
    end
  end

  always @ (*) begin
    io_write_ready = io_write_thrown_ready;
    if(rx_io_break)begin
      io_write_ready = 1'b1;
    end
  end

  assign io_write_thrown_payload = io_write_payload;
  assign io_write_thrown_ready = tx_io_write_ready;
  assign io_read_valid = rx_io_read_valid;
  assign io_read_payload = rx_io_read_payload;
  assign io_uart_txd = tx_io_txd;
  assign io_readError = rx_io_error;
  assign _zz_1_ = 1'b0;
  assign io_readBreak = rx_io_break;
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      clockDivider_counter <= 20'h0;
    end else begin
      clockDivider_counter <= (clockDivider_counter - 20'h00001);
      if(clockDivider_tick)begin
        clockDivider_counter <= io_config_clockDivider;
      end
    end
  end


endmodule

module LedPwmDemo (
  input               rxd,
  output reg [2:0]    pwm,
  output reg [2:0]    led,
  input               reset,
  input               clk 
);
  wire       [2:0]    _zz_2_;
  wire       `UartStopType_defaultEncoding_type _zz_3_;
  wire       `UartParityType_defaultEncoding_type _zz_4_;
  wire       [19:0]   _zz_5_;
  wire                _zz_6_;
  wire       [7:0]    _zz_7_;
  reg                 _zz_8_;
  wire                _zz_9_;
  wire                _zz_10_;
  wire                _zz_11_;
  wire                _zz_12_;
  wire                _zz_13_;
  wire                _zz_14_;
  wire                _zz_15_;
  wire                _zz_16_;
  wire                _zz_17_;
  wire                _zz_18_;
  wire                _zz_19_;
  wire                _zz_20_;
  wire                _zz_21_;
  wire                _zz_22_;
  wire                uartCtrl_1__io_write_ready;
  wire                uartCtrl_1__io_read_valid;
  wire       [7:0]    uartCtrl_1__io_read_payload;
  wire                uartCtrl_1__io_uart_txd;
  wire                uartCtrl_1__io_readError;
  wire                uartCtrl_1__io_readBreak;
  wire                ledPwm_LEDDON;
  wire                ledPwm_PWMOUT0;
  wire                ledPwm_PWMOUT1;
  wire                ledPwm_PWMOUT2;
  wire                ledDrv_RGB0;
  wire                ledDrv_RGB1;
  wire                ledDrv_RGB2;
  wire                _zz_23_;
  reg        [7:0]    ipAddr;
  reg        [7:0]    ipData;
  reg                 writeEn;
  reg                 blink;
  wire                fsm_wantExit;
  wire       [3:0]    _zz_1_;
  reg        `fsm_enumDefinition_defaultEncoding_type fsm_stateReg;
  reg        `fsm_enumDefinition_defaultEncoding_type fsm_stateNext;
  `ifndef SYNTHESIS
  reg [103:0] fsm_stateReg_string;
  reg [103:0] fsm_stateNext_string;
  `endif


  assign _zz_23_ = (ipAddr[7 : 4] == (4'b0000));
  UartCtrl uartCtrl_1_ ( 
    .io_config_frame_dataLength    (_zz_2_[2:0]                       ), //i
    .io_config_frame_stop          (_zz_3_                            ), //i
    .io_config_frame_parity        (_zz_4_[1:0]                       ), //i
    .io_config_clockDivider        (_zz_5_[19:0]                      ), //i
    .io_write_valid                (_zz_6_                            ), //i
    .io_write_ready                (uartCtrl_1__io_write_ready        ), //o
    .io_write_payload              (_zz_7_[7:0]                       ), //i
    .io_read_valid                 (uartCtrl_1__io_read_valid         ), //o
    .io_read_ready                 (_zz_8_                            ), //i
    .io_read_payload               (uartCtrl_1__io_read_payload[7:0]  ), //o
    .io_uart_txd                   (uartCtrl_1__io_uart_txd           ), //o
    .io_uart_rxd                   (rxd                               ), //i
    .io_readError                  (uartCtrl_1__io_readError          ), //o
    .io_writeBreak                 (_zz_9_                            ), //i
    .io_readBreak                  (uartCtrl_1__io_readBreak          ), //o
    .clk                           (clk                               ), //i
    .reset                         (reset                             )  //i
  );
  SB_LEDDA_IP ledPwm ( 
    .LEDDRST      (reset           ), //i
    .LEDDCLK      (clk             ), //i
    .LEDDCS       (writeEn         ), //i
    .LEDDDEN      (writeEn         ), //i
    .LEDDADDR3    (_zz_10_         ), //i
    .LEDDADDR2    (_zz_11_         ), //i
    .LEDDADDR1    (_zz_12_         ), //i
    .LEDDADDR0    (_zz_13_         ), //i
    .LEDDDAT7     (_zz_14_         ), //i
    .LEDDDAT6     (_zz_15_         ), //i
    .LEDDDAT5     (_zz_16_         ), //i
    .LEDDDAT4     (_zz_17_         ), //i
    .LEDDDAT3     (_zz_18_         ), //i
    .LEDDDAT2     (_zz_19_         ), //i
    .LEDDDAT1     (_zz_20_         ), //i
    .LEDDDAT0     (_zz_21_         ), //i
    .LEDDEXE      (blink           ), //i
    .LEDDON       (ledPwm_LEDDON   ), //o
    .PWMOUT0      (ledPwm_PWMOUT0  ), //o
    .PWMOUT1      (ledPwm_PWMOUT1  ), //o
    .PWMOUT2      (ledPwm_PWMOUT2  )  //o
  );
  SB_RGBA_DRV #( 
    .CURRENT_MODE("0b0"),
    .RGB0_CURRENT("0b111111"),
    .RGB1_CURRENT("0b111111"),
    .RGB2_CURRENT("0b111111") 
  ) ledDrv ( 
    .CURREN      (_zz_22_         ), //i
    .RGBLEDEN    (ledPwm_LEDDON   ), //i
    .RGB0PWM     (ledPwm_PWMOUT2  ), //i
    .RGB1PWM     (ledPwm_PWMOUT0  ), //i
    .RGB2PWM     (ledPwm_PWMOUT1  ), //i
    .RGB0        (ledDrv_RGB0     ), //o
    .RGB1        (ledDrv_RGB1     ), //o
    .RGB2        (ledDrv_RGB2     )  //o
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      `fsm_enumDefinition_defaultEncoding_boot : fsm_stateReg_string = "boot         ";
      `fsm_enumDefinition_defaultEncoding_fsm_READ_ADDR : fsm_stateReg_string = "fsm_READ_ADDR";
      `fsm_enumDefinition_defaultEncoding_fsm_READ_DATA : fsm_stateReg_string = "fsm_READ_DATA";
      `fsm_enumDefinition_defaultEncoding_fsm_WRITE_PWM : fsm_stateReg_string = "fsm_WRITE_PWM";
      default : fsm_stateReg_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      `fsm_enumDefinition_defaultEncoding_boot : fsm_stateNext_string = "boot         ";
      `fsm_enumDefinition_defaultEncoding_fsm_READ_ADDR : fsm_stateNext_string = "fsm_READ_ADDR";
      `fsm_enumDefinition_defaultEncoding_fsm_READ_DATA : fsm_stateNext_string = "fsm_READ_DATA";
      `fsm_enumDefinition_defaultEncoding_fsm_WRITE_PWM : fsm_stateNext_string = "fsm_WRITE_PWM";
      default : fsm_stateNext_string = "?????????????";
    endcase
  end
  `endif

  assign _zz_5_ = 20'h0000c;
  assign _zz_2_ = (3'b111);
  assign _zz_4_ = `UartParityType_defaultEncoding_NONE;
  assign _zz_3_ = `UartStopType_defaultEncoding_ONE;
  assign fsm_wantExit = 1'b0;
  always @ (*) begin
    _zz_8_ = 1'b0;
    case(fsm_stateReg)
      `fsm_enumDefinition_defaultEncoding_fsm_READ_ADDR : begin
        _zz_8_ = 1'b1;
      end
      `fsm_enumDefinition_defaultEncoding_fsm_READ_DATA : begin
        _zz_8_ = 1'b1;
      end
      `fsm_enumDefinition_defaultEncoding_fsm_WRITE_PWM : begin
      end
      default : begin
      end
    endcase
  end

  always @ (*) begin
    writeEn = 1'b0;
    case(fsm_stateReg)
      `fsm_enumDefinition_defaultEncoding_fsm_READ_ADDR : begin
      end
      `fsm_enumDefinition_defaultEncoding_fsm_READ_DATA : begin
      end
      `fsm_enumDefinition_defaultEncoding_fsm_WRITE_PWM : begin
        if(_zz_23_)begin
          writeEn = 1'b1;
        end
      end
      default : begin
      end
    endcase
  end

  assign _zz_1_ = ipAddr[3 : 0];
  assign _zz_10_ = _zz_1_[3];
  assign _zz_11_ = _zz_1_[2];
  assign _zz_12_ = _zz_1_[1];
  assign _zz_13_ = _zz_1_[0];
  assign _zz_14_ = ipData[7];
  assign _zz_15_ = ipData[6];
  assign _zz_16_ = ipData[5];
  assign _zz_17_ = ipData[4];
  assign _zz_18_ = ipData[3];
  assign _zz_19_ = ipData[2];
  assign _zz_20_ = ipData[1];
  assign _zz_21_ = ipData[0];
  always @ (*) begin
    pwm[0] = ledPwm_PWMOUT0;
    pwm[1] = ledPwm_PWMOUT1;
    pwm[2] = ledPwm_PWMOUT2;
  end

  assign _zz_22_ = 1'b1;
  always @ (*) begin
    led[0] = ledDrv_RGB0;
    led[1] = ledDrv_RGB1;
    led[2] = ledDrv_RGB2;
  end

  always @ (*) begin
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      `fsm_enumDefinition_defaultEncoding_fsm_READ_ADDR : begin
        if(uartCtrl_1__io_read_valid)begin
          fsm_stateNext = `fsm_enumDefinition_defaultEncoding_fsm_READ_DATA;
        end
      end
      `fsm_enumDefinition_defaultEncoding_fsm_READ_DATA : begin
        if(uartCtrl_1__io_read_valid)begin
          fsm_stateNext = `fsm_enumDefinition_defaultEncoding_fsm_WRITE_PWM;
        end
      end
      `fsm_enumDefinition_defaultEncoding_fsm_WRITE_PWM : begin
        fsm_stateNext = `fsm_enumDefinition_defaultEncoding_fsm_READ_ADDR;
      end
      default : begin
        fsm_stateNext = `fsm_enumDefinition_defaultEncoding_fsm_READ_ADDR;
      end
    endcase
  end

  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      ipAddr <= 8'h0;
      ipData <= 8'h0;
      blink <= 1'b0;
      fsm_stateReg <= `fsm_enumDefinition_defaultEncoding_boot;
    end else begin
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        `fsm_enumDefinition_defaultEncoding_fsm_READ_ADDR : begin
          if(uartCtrl_1__io_read_valid)begin
            ipAddr <= uartCtrl_1__io_read_payload;
          end
        end
        `fsm_enumDefinition_defaultEncoding_fsm_READ_DATA : begin
          if(uartCtrl_1__io_read_valid)begin
            ipData <= uartCtrl_1__io_read_payload;
          end
        end
        `fsm_enumDefinition_defaultEncoding_fsm_WRITE_PWM : begin
          if(! _zz_23_) begin
            blink <= (ipData != 8'h0);
          end
        end
        default : begin
        end
      endcase
    end
  end


endmodule
