// {"dataWidth":16,"addrWidth":3,"betaWidth":6,"nCordics":7,"corrector":0,"scale":0}
module nco (
    // per node (target / initiator)
    input              clk,
    input              reset_n,
    input       [31:0] t_angle_dat,
    input              t_angle_req,
    output             t_angle_ack,
    output      [31:0] i_nco_dat,
    output             i_nco_req,
    input              i_nco_ack
);
// per edge
wire      [31:0] dat0, dat0_nxt;
wire      [67:0] dat1, dat1_nxt;
wire      [67:0] dat2, dat2_nxt;
wire      [67:0] dat3, dat3_nxt;
wire      [67:0] dat4, dat4_nxt;
wire      [67:0] dat5, dat5_nxt;
wire      [67:0] dat6, dat6_nxt;
wire      [67:0] dat7, dat7_nxt;
wire      [67:0] dat8, dat8_nxt;
wire      [31:0] dat9;
// per node
// node:0 is target port
assign dat0_nxt = t_angle_dat;

// node:1 macro nco_lut

// Look-Up stage
/*
{JSON.stringify(lut, null, 4)}
*/

reg [31:0] ncolut;

always @*
casez (node1_addr)
0 : ncolut = {16'd3215, 16'd65453};
1 : ncolut = {16'd9615, 16'd64823};
2 : ncolut = {16'd15923, 16'd63568};
3 : ncolut = {16'd22077, 16'd61702};
4 : ncolut = {16'd28018, 16'd59241};
5 : ncolut = {16'd33690, 16'd56209};
6 : ncolut = {16'd39037, 16'd52636};
7 : ncolut = {16'd44009, 16'd48556};
endcase

wire [31:0] node1_angle;
wire [2:0] node1_phase;
wire [2:0] node1_addr;
wire [17:0] node1_reSwap;
wire [17:0] node1_imSwap;


assign node1_angle = dat0;
assign node1_phase = node1_angle[31:29]; //3 bit phase
assign node1_addr = node1_phase[0]?~node1_angle[28:26]:node1_angle[28:26];
//re = 15:0  im = 31:16
assign node1_reSwap[17:16]=2'b0;
assign node1_imSwap[17:16]=2'b0;
assign node1_reSwap[15:0] = node1_phase[0]^node1_phase[1] ? ncolut[31:16]:ncolut[15:0];
assign node1_imSwap[15:0] = node1_phase[0]^node1_phase[1] ? ncolut[15:0]:ncolut[31:16];

assign dat1_nxt[17:0] = node1_phase[2]^node1_phase[1]?~node1_reSwap:node1_reSwap;
assign dat1_nxt[35:18] = node1_phase[2]?~node1_imSwap:node1_imSwap;
assign dat1_nxt[61:36] = node1_angle[25:0];

// node:2 macro nco_cordic

// CORDIC stage 0
/*
{
    "sigma": 20,
    "shift": 5
}
*/

wire [25:0] beta0;
wire [25:0] beta_calc0;
wire [17:0] re0,im0,re_shift0,im_shift0;


assign  beta0 = dat1[25:0];

assign re0=dat1[17:0];
assign im0=dat1[35:18];

//assign re_shift0={{5{re0[17]}},re0 >> 5};
//assign im_shift0={{5{im0[17]}},im0 >> 5};

assign re_shift0=$signed(re0) >> 5;
assign im_shift0=$signed(im0) >> 5;

assign beta_calc0 = beta0[25]?beta0+20:beta0-20;
assign dat2_nxt[17:0] = beta0[25]?re0-im_shift0 : re0+im_shift0;
assign dat2_nxt[35:18] = beta0[25]?im0+re_shift0 : im0-re_shift0;
assign dat2_nxt[61:36] = beta_calc0;


// node:3 macro nco_cordic

// CORDIC stage 1
/*
{
    "sigma": 10,
    "shift": 6
}
*/

wire [25:0] beta1;
wire [25:0] beta_calc1;
wire [17:0] re1,im1,re_shift1,im_shift1;


assign  beta1 = dat2[25:0];

assign re1=dat2[17:0];
assign im1=dat2[35:18];

//assign re_shift1={{6{re1[17]}},re1 >> 6};
//assign im_shift1={{6{im1[17]}},im1 >> 6};

assign re_shift1=$signed(re1) >> 6;
assign im_shift1=$signed(im1) >> 6;

assign beta_calc1 = beta1[25]?beta1+10:beta1-10;
assign dat3_nxt[17:0] = beta1[25]?re1-im_shift1 : re1+im_shift1;
assign dat3_nxt[35:18] = beta1[25]?im1+re_shift1 : im1-re_shift1;
assign dat3_nxt[61:36] = beta_calc1;


// node:4 macro nco_cordic

// CORDIC stage 2
/*
{
    "sigma": 5,
    "shift": 7
}
*/

wire [25:0] beta2;
wire [25:0] beta_calc2;
wire [17:0] re2,im2,re_shift2,im_shift2;


assign  beta2 = dat3[25:0];

assign re2=dat3[17:0];
assign im2=dat3[35:18];

//assign re_shift2={{7{re2[17]}},re2 >> 7};
//assign im_shift2={{7{im2[17]}},im2 >> 7};

assign re_shift2=$signed(re2) >> 7;
assign im_shift2=$signed(im2) >> 7;

assign beta_calc2 = beta2[25]?beta2+5:beta2-5;
assign dat4_nxt[17:0] = beta2[25]?re2-im_shift2 : re2+im_shift2;
assign dat4_nxt[35:18] = beta2[25]?im2+re_shift2 : im2-re_shift2;
assign dat4_nxt[61:36] = beta_calc2;


// node:5 macro nco_cordic

// CORDIC stage 3
/*
{
    "sigma": 3,
    "shift": 8
}
*/

wire [25:0] beta3;
wire [25:0] beta_calc3;
wire [17:0] re3,im3,re_shift3,im_shift3;


assign  beta3 = dat4[25:0];

assign re3=dat4[17:0];
assign im3=dat4[35:18];

//assign re_shift3={{8{re3[17]}},re3 >> 8};
//assign im_shift3={{8{im3[17]}},im3 >> 8};

assign re_shift3=$signed(re3) >> 8;
assign im_shift3=$signed(im3) >> 8;

assign beta_calc3 = beta3[25]?beta3+3:beta3-3;
assign dat5_nxt[17:0] = beta3[25]?re3-im_shift3 : re3+im_shift3;
assign dat5_nxt[35:18] = beta3[25]?im3+re_shift3 : im3-re_shift3;
assign dat5_nxt[61:36] = beta_calc3;


// node:6 macro nco_cordic

// CORDIC stage 4
/*
{
    "sigma": 1,
    "shift": 9
}
*/

wire [25:0] beta4;
wire [25:0] beta_calc4;
wire [17:0] re4,im4,re_shift4,im_shift4;


assign  beta4 = dat5[25:0];

assign re4=dat5[17:0];
assign im4=dat5[35:18];

//assign re_shift4={{9{re4[17]}},re4 >> 9};
//assign im_shift4={{9{im4[17]}},im4 >> 9};

assign re_shift4=$signed(re4) >> 9;
assign im_shift4=$signed(im4) >> 9;

assign beta_calc4 = beta4[25]?beta4+1:beta4-1;
assign dat6_nxt[17:0] = beta4[25]?re4-im_shift4 : re4+im_shift4;
assign dat6_nxt[35:18] = beta4[25]?im4+re_shift4 : im4-re_shift4;
assign dat6_nxt[61:36] = beta_calc4;


// node:7 macro nco_cordic

// CORDIC stage 5
/*
{
    "sigma": 1,
    "shift": 10
}
*/

wire [25:0] beta5;
wire [25:0] beta_calc5;
wire [17:0] re5,im5,re_shift5,im_shift5;


assign  beta5 = dat6[25:0];

assign re5=dat6[17:0];
assign im5=dat6[35:18];

//assign re_shift5={{10{re5[17]}},re5 >> 10};
//assign im_shift5={{10{im5[17]}},im5 >> 10};

assign re_shift5=$signed(re5) >> 10;
assign im_shift5=$signed(im5) >> 10;

assign beta_calc5 = beta5[25]?beta5+1:beta5-1;
assign dat7_nxt[17:0] = beta5[25]?re5-im_shift5 : re5+im_shift5;
assign dat7_nxt[35:18] = beta5[25]?im5+re_shift5 : im5-re_shift5;
assign dat7_nxt[61:36] = beta_calc5;


// node:8 macro nco_cordic

// CORDIC stage 6
/*
{
    "sigma": 0,
    "shift": 11
}
*/

wire [25:0] beta6;
wire [25:0] beta_calc6;
wire [17:0] re6,im6,re_shift6,im_shift6;


assign  beta6 = dat7[25:0];

assign re6=dat7[17:0];
assign im6=dat7[35:18];

//assign re_shift6={{11{re6[17]}},re6 >> 11};
//assign im_shift6={{11{im6[17]}},im6 >> 11};

assign re_shift6=$signed(re6) >> 11;
assign im_shift6=$signed(im6) >> 11;

assign beta_calc6 = beta6[25]?beta6+0:beta6-0;
assign dat8_nxt[17:0] = beta6[25]?re6-im_shift6 : re6+im_shift6;
assign dat8_nxt[35:18] = beta6[25]?im6+re_shift6 : im6-re_shift6;
assign dat8_nxt[61:36] = beta_calc6;


// node:9 macro saturation

wire [17:0] recalc9,imcalc9;
wire [15:0] redata9,imdata9;

assign recalc9=dat8[17:0];
assign imcalc9=dat8[35:18];

assign dat9[15:0]=^recalc9[17:16]?{recalc9[17],{15{~recalc9[17]}}}:{recalc9[17],recalc9[15:1]};

assign dat9[31:16]=^imcalc9[17:16]?{imcalc9[17],{15{~imcalc9[17]}}}:{imcalc9[17],imcalc9[15:1]};

assign redata9 = dat9[15:0];
assign imdata9 = dat9[31:16];


// node:10 is initiator port
assign i_nco_dat = dat9;

// per edge

// edge:0 EB1
wire en0;
reg [31:0] dat0_r;
always @(posedge clk) if (en0) dat0_r <= dat0_nxt;
assign dat0 = dat0_r;


// edge:1 EB1
wire en1;
reg [67:0] dat1_r;
always @(posedge clk) if (en1) dat1_r <= dat1_nxt;
assign dat1 = dat1_r;


// edge:2 EB1
wire en2;
reg [67:0] dat2_r;
always @(posedge clk) if (en2) dat2_r <= dat2_nxt;
assign dat2 = dat2_r;


// edge:3 EB1
wire en3;
reg [67:0] dat3_r;
always @(posedge clk) if (en3) dat3_r <= dat3_nxt;
assign dat3 = dat3_r;


// edge:4 EB1
wire en4;
reg [67:0] dat4_r;
always @(posedge clk) if (en4) dat4_r <= dat4_nxt;
assign dat4 = dat4_r;


// edge:5 EB1
wire en5;
reg [67:0] dat5_r;
always @(posedge clk) if (en5) dat5_r <= dat5_nxt;
assign dat5 = dat5_r;


// edge:6 EB1
wire en6;
reg [67:0] dat6_r;
always @(posedge clk) if (en6) dat6_r <= dat6_nxt;
assign dat6 = dat6_r;


// edge:7 EB1
wire en7;
reg [67:0] dat7_r;
always @(posedge clk) if (en7) dat7_r <= dat7_nxt;
assign dat7 = dat7_r;


// edge:8 EB1
wire en8;
reg [67:0] dat8_r;
always @(posedge clk) if (en8) dat8_r <= dat8_nxt;
assign dat8 = dat8_r;


// edge:9 EB0

nco_ctrl uctrl (
    .clk(clk),
    .reset_n(reset_n),
    .t_angle_req(t_angle_req),
    .t_angle_ack(t_angle_ack),
    .i_nco_req(i_nco_req),
    .i_nco_ack(i_nco_ack),
    .en0(en0),
    .en1(en1),
    .en2(en2),
    .en3(en3),
    .en4(en4),
    .en5(en5),
    .en6(en6),
    .en7(en7),
    .en8(en8)
);
endmodule // nco

module nco_ctrl (
    // per node (target / initiator)
    input              clk,
    input              reset_n,
    input              t_angle_req,
    output             t_angle_ack,
    output             i_nco_req,
    input              i_nco_ack,
    output             en0,
    output             en1,
    output             en2,
    output             en3,
    output             en4,
    output             en5,
    output             en6,
    output             en7,
    output             en8
);
// per edge
wire             req0, ack0, ack0_0, req0_0;
wire             req1, ack1, ack1_0, req1_0;
wire             req2, ack2, ack2_0, req2_0;
wire             req3, ack3, ack3_0, req3_0;
wire             req4, ack4, ack4_0, req4_0;
wire             req5, ack5, ack5_0, req5_0;
wire             req6, ack6, ack6_0, req6_0;
wire             req7, ack7, ack7_0, req7_0;
wire             req8, ack8, ack8_0, req8_0;
wire             req9, ack9, ack9_0, req9_0;
// node:t_angle target
assign req0 = t_angle_req;
assign t_angle_ack = ack0;

// edge:0 EB1
wire ack0m;
reg req0m;
assign en0 = req0 & ack0;
assign ack0 = ~req0m | ack0m;
always @(posedge clk or negedge reset_n) if (~reset_n) req0m <= 1'b0; else req0m <= ~ack0 | req0;


// edge:0 fork


assign req0_0 = req0m;

assign ack0m = ack0_0;



// edge:1 EB1
wire ack1m;
reg req1m;
assign en1 = req1 & ack1;
assign ack1 = ~req1m | ack1m;
always @(posedge clk or negedge reset_n) if (~reset_n) req1m <= 1'b0; else req1m <= ~ack1 | req1;


// edge:1 fork


assign req1_0 = req1m;

assign ack1m = ack1_0;



// edge:2 EB1
wire ack2m;
reg req2m;
assign en2 = req2 & ack2;
assign ack2 = ~req2m | ack2m;
always @(posedge clk or negedge reset_n) if (~reset_n) req2m <= 1'b0; else req2m <= ~ack2 | req2;


// edge:2 fork


assign req2_0 = req2m;

assign ack2m = ack2_0;



// edge:3 EB1
wire ack3m;
reg req3m;
assign en3 = req3 & ack3;
assign ack3 = ~req3m | ack3m;
always @(posedge clk or negedge reset_n) if (~reset_n) req3m <= 1'b0; else req3m <= ~ack3 | req3;


// edge:3 fork


assign req3_0 = req3m;

assign ack3m = ack3_0;



// edge:4 EB1
wire ack4m;
reg req4m;
assign en4 = req4 & ack4;
assign ack4 = ~req4m | ack4m;
always @(posedge clk or negedge reset_n) if (~reset_n) req4m <= 1'b0; else req4m <= ~ack4 | req4;


// edge:4 fork


assign req4_0 = req4m;

assign ack4m = ack4_0;



// edge:5 EB1
wire ack5m;
reg req5m;
assign en5 = req5 & ack5;
assign ack5 = ~req5m | ack5m;
always @(posedge clk or negedge reset_n) if (~reset_n) req5m <= 1'b0; else req5m <= ~ack5 | req5;


// edge:5 fork


assign req5_0 = req5m;

assign ack5m = ack5_0;



// edge:6 EB1
wire ack6m;
reg req6m;
assign en6 = req6 & ack6;
assign ack6 = ~req6m | ack6m;
always @(posedge clk or negedge reset_n) if (~reset_n) req6m <= 1'b0; else req6m <= ~ack6 | req6;


// edge:6 fork


assign req6_0 = req6m;

assign ack6m = ack6_0;



// edge:7 EB1
wire ack7m;
reg req7m;
assign en7 = req7 & ack7;
assign ack7 = ~req7m | ack7m;
always @(posedge clk or negedge reset_n) if (~reset_n) req7m <= 1'b0; else req7m <= ~ack7 | req7;


// edge:7 fork


assign req7_0 = req7m;

assign ack7m = ack7_0;



// edge:8 EB1
wire ack8m;
reg req8m;
assign en8 = req8 & ack8;
assign ack8 = ~req8m | ack8m;
always @(posedge clk or negedge reset_n) if (~reset_n) req8m <= 1'b0; else req8m <= ~ack8 | req8;


// edge:8 fork


assign req8_0 = req8m;

assign ack8m = ack8_0;



// edge:9 EB0
wire ack9m, req9m;
assign req9m = req9;
assign ack9 = ack9m;


// edge:9 fork


assign req9_0 = req9m;

assign ack9m = ack9_0;


// node:1 join nco_lut
assign req1 = req0_0;
assign ack0_0 = ack1;
// node:2 join nco_cordic
assign req2 = req1_0;
assign ack1_0 = ack2;
// node:3 join nco_cordic
assign req3 = req2_0;
assign ack2_0 = ack3;
// node:4 join nco_cordic
assign req4 = req3_0;
assign ack3_0 = ack4;
// node:5 join nco_cordic
assign req5 = req4_0;
assign ack4_0 = ack5;
// node:6 join nco_cordic
assign req6 = req5_0;
assign ack5_0 = ack6;
// node:7 join nco_cordic
assign req7 = req6_0;
assign ack6_0 = ack7;
// node:8 join nco_cordic
assign req8 = req7_0;
assign ack7_0 = ack8;
// node:9 join saturation
assign req9 = req8_0;
assign ack8_0 = ack9;
// node:10 initiator
assign i_nco_req = req9_0;
assign ack9_0 = i_nco_ack;
endmodule // nco_ctrl
