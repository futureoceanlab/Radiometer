#ifndef __RADTEENSY
#define __RADTEENSY 0


/*------------------------------------------------------------------------------ 

    Global Includes

------------------------------------------------------------------------------*/

// Timing 
#include <TimeLib.h>
//#include "time.h" // Jake Change

// SdFs
//#include <FreeStack.h>
#include <SdFs.h>
#define   SD_CONFIG SdioConfig(FIFO_SDIO)

#include <Arduino.h>
//#include "FOL-ADIS16209.h"
//#include "FOL-TMP117.h"

// MTP USB
//#include <MTP.h>

/*------------------------------------------------------------------------------ 

    Compiler Options

------------------------------------------------------------------------------*/

#define EMULATOR_ENABLE 1 // Set to 1 line to have teensy run as emulator, generating synthetic data
#define PROFILER_ENABLE 1 // Set to 1 to have profiler replace UTC 

/*------------------------------------------------------------------------------ 

    Global DEFINEs

------------------------------------------------------------------------------*/

#define ONE_THOUSAND      1000
#define ONE_MILLION    1000000
#define ONE_BILLION 1000000000
#define ONE_KiB           1024 // 2^10
#define ONE_MiB        1048576 // 2^20
#define ONE_GiB     1073741824 // 2^30


/*  RingBuffer Memory Size
 
  SIZE_RU   Size of RU for writing to SD, must be a multiple of 512
  N_BUFS    Number of  RUs in RingBuffer.  Data comes in 6B chunks
            so let's fix Buffer size by 6 * largest RU = 192 KiB

      SIZE_RU  512   1024    2048    4096    8192    16384    32768
      N_BUFS   384    192      96      48      24       12        6
  
*/
#define SIZE_RU 512
#define N_BUFS 384


/*  File Storage Size
 We need to pre-allocate file storage to keep write latency low.
 Files should fit an integral number of RUs, for any  RU.  That means
 an integer multiple of largest  possible RU: 32KiB = 2^15B.  
  
 We also want to have an integer number of data records -- don't want to 
 spread data records across files.  Data comes in 8B chunks, so we want
 the file size to be a multiple of both
 
   2^15     Integer number of RUs up to 2^15 = 32KiB 
 * 2^3      Size of payload packets (Don't split across files!)
 ------
   2^18     = 256KiB 

  That makes a minimum of 256 KiB.  Now think about data rates.  At 1kHz, 
  we  will produce about 29MB/hr.  Would be a shame to lose more than an
  hour of data, but flooding with many files also bad.  So let's call it 
  O(5 hours per file),  --> 128MiB.  Note that at our max data rate of 
  40kHz this gives us about 9 files per hour. That's hairy! But we're 
  unlikely to exceed 10kHz, which gives about 2.5 files per hour. Cool.
*/



#define PRE_ALLOCATE_MiBS    128  // 128MiB  
//#define PRE_ALLOCATE_MiBS    256  // 256MiB  
//#define PRE_ALLOCATE_MiBS    512  // 512MiB  
//#define PRE_ALLOCATE_MiBS   1024  // 1GiB
//#define PRE_ALLOCATE_MiBS   2048  // 2GiB
//#define PRE_ALLOCATE_MiBS   4096  // 4GiB

// Number of files to pre-allocate
//    At 10kHz, we eat 216MB per hour 
//    Planned dives are all 6 hours long, plus ~ 2 hours on either end
//    ==> 2.5GB should suffice.
int     N_Files = 2;
#define N_File_Multiplier 2
#define MAX_FILES 100
#define FILENAME_ROOT "FOL_WHOI_Radiometer_"


// Empirically, 1us = 60 * 16.7ns sufficed;  we should be able to get away with a lot less
//#define DTOG_SKIP_16ns_Clicks           60
#define DTOG_SKIP_16ns_Clicks           4

#define MAX_COUNTS_PER_MS            10000000        
#define SERIAL_DATA_TOKEN_INTERVAL    50
#define LOG_CROSSOVER                32768 // 2^15

#define SD_DATA_BUFFER_BYTES         8
#define SD_HEART_BUFFER_BYTES        16
#define PAYLOAD_DELAY_MILLIS      500
#define SD_TOKEN_DATA                0xFC
#define SD_TOKEN_HEART_A             0xFD
#define SD_TOKEN_HEART_B             0xFE
 
#define SERIAL_ 
#define SERIAL_BUFFER_DATA_BYTES        2
#define SERIAL_BUFFER_DHEAD_BYTES       12
#define SERIAL_BUFFER_HEART_BYTES       24
#define SERIAL_TOKEN_DATA               0x00FF00FF
#define SERIAL_TOKEN_HEART_START        0x00FE00FE
#define SERIAL_TOKEN_HEART_STOP         0x00FD00FD

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

#define CMD_SET_DIVE_DURATION     0
#define CMD_SET_DIVE_SAMPLE_RATE  1
#define CMD_START_LOGGING         2
#define CMD_STOP_LOGGING          3
#define CMD_SHUTDOWN              4
#define CMD_FILE_LS               5
#define CMD_FILE_CD               6
#define CMD_FILE_RM               7
#define CMD_FILE_FORMAT           8
#define CMD_HELP_MENU             9

#define CMD_SET_DIVE_TXT_MSG      10
#define CMD_HAMAMATSU_ON          11
#define CMD_HAMAMATSU_OFF         12
#define CMD_BEGIN_MTP_USB_MODE    13
#define CMD_BACK_TO_MENU          14

#define CLI_CMD_MAX_CHARS         128


#define TRUE  (1==1)
#define FALSE (!TRUE)

#define SERIALN Serial // Jake changed!
#define SERIALD Serial1
#define SERIALBAUD 38400 // Jake changed!
//#define ANNOUNCE_PINGS 

#define FOL_RAD_VV 0.3              //  Radiometer Software Version


/*------------------------------------------------------------------------------ 

    Glocabl Defines: Timing

------------------------------------------------------------------------------*/

#define NOP1 "nop\n\t"
#define NOP2 "nop\n\t""nop\n\t"
#define NOP3 "nop\n\t""nop\n\t""nop\n\t"
#define NOP4 "nop\n\t""nop\n\t""nop\n\t""nop\n\t"
#define NOP5 "nop\n\t""nop\n\t""nop\n\t""nop\n\t""nop\n\t"
#define NOP6 "nop\n\t""nop\n\t""nop\n\t""nop\n\t""nop\n\t""nop\n\t"

#define P1 __asm__(NOP1)
#define P2 __asm__(NOP2)
#define P3 __asm__(NOP3)
#define P4 __asm__(NOP4)
#define P5 __asm__(NOP5)
#define P6 __asm__(NOP6)


// P1-5 are 100-500 ns pauses, tested with an oscilloscope (2 second
// display persistence) and a Teensy 3.2 compiling with
// Teensyduino/Arduino 1.8.1, "faster" setting
#if F_CPU == 240000000
#define PAUSE_10ns  __asm__()
#define PAUSE_20ns  __asm__()
#define PAUSE_30ns  __asm__()
#define PAUSE_40ns  __asm__()
#define PAUSE_50ns  __asm__()
#define PAUSE_60ns  __asm__()
#define PAUSE_70ns  __asm__()
#define PAUSE_80ns  __asm__()
#define PAUSE_90ns  __asm__()
#define PAUSE_100ns __asm__()
%#define P5 __asm__(NOP6 NOP6 NOP6 NOP6 NOP6 NOP6 NOP6 NOP4 NOP3)
#endif



// P1    6.1 ns  6.1  
// P2   11.8 ns  5.9
// P3   17.4 ns  5.8
// P4   22.9 ns  5.7
// P5   28.5 ns  5.7
// P6   34.0 ns  5.7 ASYMPTOPE TO 5.555555 = 1000 / 180
#if F_CPU == 180000000
#define PAUSE_10ns  __asm__(NOP2) // 11.111
#define PAUSE_20ns  __asm__(NOP4) // 22.222
#define PAUSE_30ns  __asm__(NOP5) // 27.777
#define PAUSE_40ns  __asm__(NOP6 NOP1) // 38.885
#define PAUSE_50ns  __asm__(NOP6 NOP3) // 49.995
#define PAUSE_60ns  __asm__(NOP6 NOP5) // 61.105
#define PAUSE_70ns  __asm__(NOP6 NOP6 NOP1) // 72.215
#define PAUSE_80ns  __asm__(NOP6 NOP6 NOP3) // 83.325
#define PAUSE_90ns  __asm__(NOP6 NOP6 NOP4) // 88.88
#define PAUSE_100ns __asm__(NOP6 NOP6 NOP6) // 100
//#define P1 __asm__(NOP4 NOP4)
//#define P2 __asm__(NOP6 NOP6 NOP6)
//#define P3 __asm__(NOP6 NOP6 NOP6 NOP6 NOP3)
//#define P4 __asm__(NOP6 NOP6 NOP6 NOP6 NOP6 NOP4 NOP4)
//#define P5 __asm__(NOP6 NOP6 NOP6 NOP6 NOP6 NOP6 NOP6 NOP4 NOP3)
#endif

#define PAUSE P1



/*------------------------------------------------------------------------------ 

    Glocabl Variables: Pins

------------------------------------------------------------------------------*/
/*  Teensy Pin - to - Port map
 *        00 01 02 03 04 05 06 07   08 09 10 11 12 13 14 15   16 17 18 19 20 21 22 23   24 25 26 27 28 29 30 31 
 *      ------------------------------------------------------------------------------------------------------- 
 *  A  |                 25                     03 04 26 27   28 39                           42    40 41
 *  B  |  16 17 19 18 49 50               31 32               00 01 29 30 43 46 44 45
 *  C  |  15 22 23 09 10 13 11 12   35 36 37 38  
 *  D  |  02 14 07 08 06 20 21 05   47 48    55 53 52 51 54
 *  E  |                                  56 57                                         33 34 24
 */

// INPUT PINS: CMOD
static const byte pin_PortC[]   = {15, 22, 23, 9, 10, 13, 11, 12};  // C(00:07) Byte 1
static const byte pin_PortD[]   = { 2, 14,  7, 8,  6, 20, 21,  5};  // D(00:07) Byte 2
static const byte pin_Ping      =  34; //  E25  Data redy at falling edge 

// INPUT PINS: OTHER
static const byte pin_HamRdy    =   3; //  A12  HIGH: Hamamatsu Ready    LOW: Hamamatsu offline
static const byte pin_PwrDwn    =  38; //  C11  HIGH: Power is going down in 10s, burn the files, save Cannoli

// Output Pins
static const byte pin_NsSel[]   = {24,25,28}; // E26 A05 A16   Binary NS select lines 
// static const byte pin_PWM[]     = {35,36,37}; // C08 C09 C10   PWM outtput to stepper motors
static const byte pin_PWM[]     = {35,36}; // C08 C09   PWM outtput to stepper motors
static const byte pin_Buzzer    = 37;  // C10  HIGH: Buzzer On                  LOW: Buzzer Off (Prev. 3rd PWM pin)
static const byte pin_Dtog      = 33;  // E24  HIGH: request Pulse count        LOW: request Cycle count
static const byte pin_Reset     = 17;  // B01  HIGH: reset FPGA counters        LOW: enable counters
static const byte pin_HamPwr    =  4;  // A13  HIGH: Enable Ham Load Switch     LOW: Disable 
static const byte pin_CAN0_Lo   = 39;  // A17  HIGH: CAN Low Power Mode ON      LOW: CAN regular mode
static const byte pin_KillMePls = 16;  // B00  HIGH: Cmod, T36 load switch off  LOW: DEFAULT 

// COMMS PINS
static const byte pin_I2C0_SDA  = 18;  // B03 SDA
static const byte pin_I2C0_SCL  = 19;  // B02 SCL 

static const byte pin_Ser1_TX   = 26;  // A14 TX
static const byte pin_Ser1_RX   = 27;  // A15 RX 

static const byte pin_CAN0_TX   = 29;  // B18 TX
static const byte pin_CAN0_RX   = 30;  // B19 RX 

static const byte pin_SPI1_MOSI =  0;  // B16 MOSI 
static const byte pin_SPI1_MISO =  1;  // B17 MISO
static const byte pin_SPI1_CS   = 31;  // B10 CS
static const byte pin_SPI1_SCK  = 32;  // B11 SCK


static const size_t        cpu_clicks_per_us =  F_CPU / 1000000;
static const size_t        cpu_clicks_per_16ns =  F_CPU / 60000000;
static const size_t        DTOG_cycles_delay = DTOG_SKIP_16ns_Clicks * cpu_clicks_per_16ns;


//static const uint16_t      Ns[]={ 1000, 2000, 4000, 8000, 10000, 16000, 24000, 32000}; // Possible sampling rates, 240MHz:
static const uint16_t      Ns[]={ 1000, 2000, 4000, 8000, 10000, 16000, 25000, 40000}; // Possible sampling rates, 250MHz:
static const size_t        File_Length = PRE_ALLOCATE_MiBS * ONE_MiB;
static const size_t        size_Ring = N_BUFS * SIZE_RU;    //



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





/*    Function Declarations
*/

void BuzzerOn();
void BuzzerOff();
void BuzzerHamOpen();
void BuzzerDoom();
void BuzzerShutdown();
void BuzzerDot();
void BuzzerDash();





#endif
