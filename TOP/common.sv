//common
`define DATA_WIDTH 32
`define ADDR_WIDTH 32
`define STRB_WIDTH `DATA_WIDTH/8

typedef enum bit [1:0] {
    FIXED = 2'b00,
    INCR = 2'b01,
    WRAP = 2'b10,
    RSVD = 2'b11
} burst_t;

typedef enum bit [1:0] {
    OKAY = 2'b00,
    EXOKAY = 2'b01,
    SLVERR = 2'b10,
    DECERR = 2'b11
} resp_t;
