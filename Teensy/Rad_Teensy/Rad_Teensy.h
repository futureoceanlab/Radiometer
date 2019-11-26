#ifndef __RADTEENSY
#define __RADTEENSY 0


// Timing 
#include <TimeLib.h>
#include "time.h"

// SdFs
//#include <FreeStack.h>
#include <SdFs.h>
#define SD_CONFIG SdioConfig(FIFO_SDIO)

// FS includes of dubious value
//#include <FsVolume.h>
//#include <FsFile.h>
//#include <MinimumSerial.h>
//#include <FsConfig.h>
//#include <BlockDeviceInterface.h>
//#include <BlockDevice.h>
//#include <SysCall.h>




/*------------------------------------------------------------------------------ 

    Global DEFINEs

------------------------------------------------------------------------------*/

//  SIZE_RU   Size of RU for writing to  SD
//  N_BUFS    number of  RUs in RingBuffer --  chosen to make 192KiB
//
#define SIZE_RU 512
#define N_BUFS 384
//#define SIZE_RU 1024
//#define N_BUFS 192
//#define SIZE_RU 2048
//#define N_BUFS 96
//#define SIZE_RU 4096
//#define N_BUFS 48
//#define SIZE_RU 8192
//#define N_BUFS 24
//#define SIZE_RU 16384
//#define N_BUFS 12
//#define SIZE_RU 32768
//#define N_BUFS 6



// We need to pre-allocate file storage to keep write latency low.
// Files should fit an integral number of RUs. To simplify, make them 
// integer multiples of 32KiB = 2^15.  To really simplify, make them 
// integer multiples of 1MiB = 2^20 = 32*(32KiB)
//
#define ONE_THOUSAND      1000
#define ONE_MILLION    1000000
#define ONE_BILLION 1000000000
#define ONE_KiB           1024
#define ONE_MiB        1048576
#define ONE_GiB     1073741824

//#define PRE_ALLOCATE_MiBS    128  // 128MiB  
#define PRE_ALLOCATE_MiBS    256  // 256MiB  
//#define PRE_ALLOCATE_MiBS    512  // 512MiB  
//#define PRE_ALLOCATE_MiBS   1024  // 1GiB
//#define PRE_ALLOCATE_MiBS   2048  // 2GiB
//#define PRE_ALLOCATE_MiBS   4096  // 4GiB

// Number of files to pre-allocate
//    At 10kHz, we eat 216MB per hour 
//    Planned dives are all 6 hours long, plus ~ 2 hours on either end
//    ==> 2.5GB should suffice.
#define N_Files 10
#define FILENAME_ROOT "FOL_WHOI_Radiometer_"

const size_t File_Length = PRE_ALLOCATE_MiBS * ONE_MiB;

//// Possible sampling rates, 240MHz:
//uint16_t Ns[]={ 1000,
//                2000,
//                4000,
//                8000,
//               10000,
//               16000,
//               24000,
//               32000};

// Possible sampling rates, 250MHz:
uint16_t Ns[]={ 1000,
                2000,
                4000,
                8000,
               10000,
               16000,
               25000,
               40000};

uint8_t Current_Ns = 0; // Ns[Current_Ns]

#define UTC_BUFFER_BYTES  16
#define PAYLOAD_BYTES    12

// Global Error Codes
#define ERR_FILE_WRITE_FAILED     -1
#define ERR_OUT_OF_FILES          -2
#define ERR_BUFFER_FULL           -3
#define ERR_FILE_OPEN_FAILED      -4
#define ERR_FILE_PREALLOC_FAILED  -5

#define ERR_MSG_FILE_WRITE_FAILED     "File Write Failed!"
#define ERR_MSG_OUT_OF_FILES          "Out of Files!"
#define ERR_MSG_BUFFER_FULL           "Buffer Full!"
#define ERR_MSG_FILE_OPEN_FAILED      "File Open Failed!"
#define ERR_MSG_FILE_PREALLOC_FAILED  "File Pre-Allocation Failed"

#define LOG_DATA 1
#define RUN_CLI  2

#define TRUE  (1==1)
#define FALSE (!TRUE)

#define FOL_RAD_VV 0.1              //  Radiometer Software Version


/*------------------------------------------------------------------------------ 

    Glocabl Variables: Pins

------------------------------------------------------------------------------*/

/*       00 01 02 03 04 05 06 07   08 09 10 11 12 13 14 15   16 17 18 19 20 21 22 23   24 25 26 27 28 29 30 31 
 *       
 *  A                   25                     03 04 26 27   28 39                           42    40 41
 *  B    16 17 19 18 49 50               31 32               00 01 29 30 43 46 44 45
 *  C    15 22 23 09 10 13 11 12   35 36 37 38  
 *  D    02 14 07 08 06 20 21 05   47 48    55 53 52 51 54
 *  E                                    56 57                                         33 34 24
 */

// INPUT PINS: CMOD
const byte pin_PortC[]   = {15, 22, 23, 9, 10, 13, 11, 12};  // C(00:07) Byte 1
const byte pin_PortD[]   = { 2, 14,  7, 8,  6, 20, 21,  5};  // D(00:07) Byte 2
const byte pin_Ping      =  34; //  E25  Data redy at falling edge 

// INPUT PINS: OTHER
const byte pin_HamRdy    =   3; //  A12  HIGH: Hamamatsu Ready    LOW: Hamamatsu offline
const byte pin_PwrDwn    =  38; //  C11  HIGH: Power is going down in 10s, burn the files, save Cannoli

// Output Pins
const byte pin_NsSel[]   = {24,25,28}; // E26 A05 A16   Binary NS select lines 
const byte pin_PWM[]     = {35,36,37}; // C08 C09 C10   PWM outtput to stepper motors
const byte pin_Dtog      = 33;  // E24  HIGH: request Pulse count        LOW: request Cycle count
const byte pin_Reset     = 17;  // B01  HIGH: reset FPGA counters        LOW: enable counters
const byte pin_HamPwr    =  4;  // A13  HIGH: Enable Ham Load Switch     LOW: Disable 
const byte pin_CAN0_Lo   = 39;  // A17  HIGH: CAN Low Power Mode ON      LOW: CAN regular mode
const byte pin_KillMePls = 16;  // B00  HIGH: Cmod, T36 load switch off  LOW: DEFAULT 

// COMMS PINS
const byte pin_I2C0_SDA  = 18;  // B03 SDA
const byte pin_I2C0_SCL  = 19;  // B02 SCL 

const byte pin_Ser1_TX   = 26;  // A14 TX
const byte pin_Ser1_RX   = 27;  // A15 RX 

const byte pin_CAN0_TX   = 29;  // B18 TX
const byte pin_CAN0_RX   = 30;  // B19 RX 

const byte pin_SPI1_MOSI =  0;  // B16 MOSI 
const byte pin_SPI1_MISO =  1;  // B17 MISO
const byte pin_SPI1_CS   = 31;  // B10 CS
const byte pin_SPI1_SCK  = 32;  // B11 SCK



/*------------------------------------------------------------------------------ 

            RingBuffer Struct

------------------------------------------------------------------------------*/

typedef struct {
    uint8_t * const _ring;
    size_t Head;  
    size_t Tail;
    volatile size_t Count;
    const size_t Size;
} t_RingBuffer;

typedef t_RingBuffer* hRingBuffer;

#define MAKE_RING_BUFFER(x,y)           \
    uint8_t x##_data_space[y];          \
    t_RingBuffer x = {                  \
        ._ring = x##_data_space,        \
        .Head = 0,                      \
        .Tail = 0,                      \
        .Count = 0,                     \
        .Size = y                       \
    };                                  \
    hRingBuffer h##x = &x;



#endif
