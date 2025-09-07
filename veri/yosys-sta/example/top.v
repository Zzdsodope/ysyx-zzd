module top(
    input clk,
    input rst,
    input ps2_clk,
    input ps2_data,
    output[7:0] seg0,seg1,seg2,seg3,seg4,seg5,seg6,seg7
  );
  reg [7:0] ps2out;
  reg [23:0] ps2segin ;
  reg ps2ready,ps2next,ps2over;
  ps2_keyboard ps2keyboard(.clk(clk),
                           .clrn(~rst), //低电平复位
                           .ps2_clk(ps2_clk),
                           .ps2_data(ps2_data),
                           .data(ps2out),
                           .ready(ps2ready),
                           .nextdata_n(ps2next),
                           .overflow(ps2over)
                          );

  /***************************三段式状态机*******************************/

  parameter stateRead = 4'b0001;
  parameter stateNotify = 4'b0010; //拉低nextdata_n,通知读取完毕
  parameter stateNotify2 = 4'b0100;//拉低nextdata_n,通知读取完毕
  parameter stateIdle = 4'b1000;
  reg [3:0] state_current,state_next;
  //同步状态转移
  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      state_current<=stateIdle;
    end
    else
    begin
      state_current<=state_next;
    end
  end
  //异步改变状态
  always @(*)
  begin
    case (state_current)
      stateIdle:
      begin
        state_next=(ps2ready==1'b1)?stateRead:stateIdle;
      end
      stateRead:
      begin
        state_next=stateNotify;
      end
      stateNotify:
      begin
        state_next=stateNotify2;
      end
      stateNotify2:
      begin
        state_next=stateIdle;
      end
      default:
        state_next=stateIdle;
    endcase
  end
  //每个状态的输出
  always @(posedge clk)
  begin
    case (state_current)
      stateIdle:
      begin
        ps2next<=1;//默认拉高
      end
      stateNotify:
      begin
        ps2next<=0;//总线拉低
      end
      stateNotify2:
      begin
        ps2next<=0;//总线拉低
      end
      stateRead:
      begin
        ps2segin[23:0] <={ps2segin[15:0],ps2out[7:0]};//保存读取的最后三个值
      end
      default:
      begin
        ps2next<=1;//默认拉高
      end
    endcase
  end
  /*********************************************************************/

  /**
  * 如果读取到的最后三个值是 (A,0XF0,A)形式，则是断码，关闭数码管显示
  * (eg:有bug,找了很久没有找出来，程序复位时，segen的值是1，不是0
  * 经过排查，为 if 语句出错，但找不到原因。)
  **/
  reg segen  ; //数码管控制端口
  always @(*)
  begin
    if ((ps2segin[15:8]==8'hf0)
        &&ps2segin[7:0]==ps2segin[23:16])
    begin
      segen = 0;
    end
    else if (ps2segin == 0)
    begin
      segen = 0;
    end
    else
    begin
        segen =1;
    end
  end

    /*当按下键盘时，segen = 1,数码管亮
  * 松开键盘时，segen = 0,数码管灭
  * 通过捕获 segen 的上升沿，或下降沿，即可获取按下键盘的次数
  */
  reg [3:0 ]segcountl ,segcounth;
  always @(negedge segen)
  begin
    if (segcountl==4'd9)
    begin
      segcounth <= segcounth +4'd1;
      segcountl <= 4'd0;
    end
    else
    begin
      segcountl <= segcountl +4'd1;
    end
  end
  /* 键盘扫描码显示 */
  seg seglow1 (.in(ps2segin[3:0]), .out(seg0),.en(segen));
  seg seghigh1 (.in(ps2segin[7:4]), .out(seg1),.en(segen));
  /* 键盘 ASCII 码显示 */
  reg  [7:0]ascii;
  toASCII ps2ascii(.addr(ps2segin[7:0]),.val(ascii));

  seg seglow2 (.in(ascii[3:0]), .out(seg2),.en(segen));
  seg seghigh2 (.in(ascii[7:4]), .out(seg3),.en(segen));

  /* 没有用到，不显示 */
  seg seglow3 (.in(ps2segin[19:16]), .out(seg4),.en(1'd0));
  seg seghigh3 (.in(ps2segin[23:20]), .out(seg5),.en(1'd0));

  /* 计数显示 */
  seg segnuml (.in(segcountl), .out(seg6),.en(1'd1));
  seg seghnumh (.in(segcounth), .out(seg7),.en(1'd1));

endmodule

module ps2_keyboard(clk,clrn,ps2_clk,ps2_data,data,
                    ready,nextdata_n,overflow);
    input clk,clrn,ps2_clk,ps2_data;
    input nextdata_n;
    output [7:0] data;
    output reg ready;
    output reg overflow;     // fifo overflow
    // internal signal, for test
    reg [9:0] buffer;        // ps2_data bits
    reg [7:0] fifo[7:0];     // data fifo
    reg [2:0] w_ptr,r_ptr;   // fifo write and read pointers
    reg [3:0] count;  // count ps2_data bits
    // detect falling edge of ps2_clk
    reg [2:0] ps2_clk_sync;

    always @(posedge clk) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (clrn == 0) begin // reset
            count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready<= 0;
        end
        else begin
            if ( ready ) begin // read to output next data
                if(nextdata_n == 1'b0) //read next data
                begin
                    r_ptr <= r_ptr + 3'b1;
                    if(w_ptr==(r_ptr+1'b1)) //empty
                        ready <= 1'b0;
                end
            end
            if (sampling) begin
              if (count == 4'd10) begin
                if ((buffer[0] == 0) &&  // start bit
                    (ps2_data)       &&  // stop bit
                    (^buffer[9:1])) begin      // odd  parity
                    fifo[w_ptr] <= buffer[8:1];  // kbd scan code
                    w_ptr <= w_ptr+3'b1;
                    ready <= 1'b1;
                    overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
                end
                count <= 0;     // for next
              end else begin
                buffer[count] <= ps2_data;  // store ps2_data
                count <= count + 3'b1;
              end
            end
        end
    end
    assign data = fifo[r_ptr]; //always set output data

endmodule

module seg (
    input [3:0] in,    // 4-bit 输入（0~F）
    output reg [7:0] out, // 7-segment 输出（a~g + 小数点）
    input en           // 使能信号（1=显示，0=关闭）
);

always @(*) begin
    if (en) begin
        case (in)
            4'b0000: out = 8'b00000011; // 0 → a=0(亮),b=0,c=0,d=0,e=0,f=0,g=1(灭),dp=1(灭)
            4'b0001: out = 8'b10011111; // 1
            4'b0010: out = 8'b00100101; // 2
            4'b0011: out = 8'b00001101; // 3
            4'b0100: out = 8'b10011001; // 4
            4'b0101: out = 8'b01001001; // 5
            4'b0110: out = 8'b01000001; // 6
            4'b0111: out = 8'b00011111; // 7
            4'b1000: out = 8'b00000001; // 8
            4'b1001: out = 8'b00001001; // 9
            4'b1010: out = 8'b00010001; // A
            4'b1011: out = 8'b11000001; // B
            4'b1100: out = 8'b01100011; // C
            4'b1101: out = 8'b10000101; // D
            4'b1110: out = 8'b01100001; // E
            4'b1111: out = 8'b01110001; // F
            default: out = 8'b11111111; // 默认全灭
        endcase
    end else begin
        out = 8'b11111111; // 使能关闭时，数码管全灭
    end
end

endmodule

module toASCII (
    input [7:0] addr,  // PS/2 扫描码（通码，如 0x1C = 'A'）
    output reg [7:0] val // 输出的 ASCII 码
);

always @(*) begin
    case (addr)
        // 字母键（大写，假设未处理 Shift 键）
        8'h1C: val = 8'h41; // A
        8'h32: val = 8'h42; // B
        8'h21: val = 8'h43; // C
        8'h23: val = 8'h44; // D
        8'h24: val = 8'h45; // E
        8'h2B: val = 8'h46; // F
        8'h34: val = 8'h47; // G
        8'h33: val = 8'h48; // H
        8'h43: val = 8'h49; // I
        8'h3B: val = 8'h4A; // J
        8'h42: val = 8'h4B; // K
        8'h4B: val = 8'h4C; // L
        8'h3A: val = 8'h4D; // M
        8'h31: val = 8'h4E; // N
        8'h44: val = 8'h4F; // O
        8'h4D: val = 8'h50; // P
        8'h15: val = 8'h51; // Q
        8'h2D: val = 8'h52; // R
        8'h1B: val = 8'h53; // S
        8'h2C: val = 8'h54; // T
        8'h3C: val = 8'h55; // U
        8'h2A: val = 8'h56; // V
        8'h1D: val = 8'h57; // W
        8'h22: val = 8'h58; // X
        8'h35: val = 8'h59; // Y
        8'h1A: val = 8'h5A; // Z

        // 数字键（主键盘区）
        8'h45: val = 8'h30; // 0
        8'h16: val = 8'h31; // 1
        8'h1E: val = 8'h32; // 2
        8'h26: val = 8'h33; // 3
        8'h25: val = 8'h34; // 4
        8'h2E: val = 8'h35; // 5
        8'h36: val = 8'h36; // 6
        8'h3D: val = 8'h37; // 7
        8'h3E: val = 8'h38; // 8
        8'h46: val = 8'h39; // 9

        // 其他符号（示例）
        8'h0E: val = 8'h60; // `（波浪号）
        8'h4E: val = 8'h2D; // -（减号）
        8'h55: val = 8'h3D; // =（等号）
        8'h5D: val = 8'h5C; // \（反斜杠）

        default: val = 8'h00; // 未知按键返回 NULL
    endcase
end

endmodule
