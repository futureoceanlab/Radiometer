//
//  RadioPi.h
//  
//

#ifndef RadioPi_h
#define RadioPi_h


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                              Include  Files                                 %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

#include <omp.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/signal.h>
#include <sys/errno.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <termios.h>
#include <pigpio.h>
//#include <sys/select.h>
//#include <stropts.h>



/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                           Preprocessor Defines                              %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

#define TRUE  (1==1)
#define FALSE (!TRUE)

#define FOL_RAD_VV 0.1              //  Radiometer Software Version

#define DATA_BLOCK_SIZE 4096        // Number of Bytes per data block written to storage
#define DATA_HEADER_SIZE 32         // Number  of Bytes in the Header of each Data Block
#define DATA_CHUNK_SIZE 4           // Number of Bytes per Data Chunk inside the Data Block: 2B time + 2B Data
#define DATA_BLOCKS_PER_SEC 16      // Number of DataBlocks per second
                                    //   12 ==> 12192
                                    //   16 ==> 16256
#define SAMPLES_PER_BLOCK ((DATA_BLOCK_SIZE-DATA_HEADER_SIZE)/DATA_CHUNK_SIZE)
#define SAMPLES_PER_SEC  (SAMPLES_PER_BLOCK * DATA_BLOCKS_PER_SEC)     // Samples per second: this ensures precisely 12 blocks per sec

#define ONE_MILLION 1000000L
#define ONE_BILLION 1000000000L

//  GPIO  Pin Definitions for PiHat
//#define PIN_nOUTEN      21 // Output Enable on the Latch
//#define PIN_LATCHEN     20 // Latch Enable
//#define PIN_COUNTCLEAR  16 // Clear 12-bit Asynch Counter
//#define PIN_HSTATE      18 // Hamamatu State Output
#define PIN_nOUTEN      19 // Output Enable on the Latch
#define PIN_LATCHEN     20 // Latch Enable
#define PIN_COUNTCLEAR  18 // Clear 12-bit Asynch Counter
#define PIN_HSTATE      21 // Hamamatu State Output
const uint16_t Lpins[] = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17};
//#define C_SERIAL 1
#define PIGPIO_SERIAL 1

// HMC6343 Definitions
#define I2CBUS 1                    // Which bus: 0 [GPIO 0,1] or 1 [GPIO 2,3]
#define HMC6343_ADDRESS 0x19        // Address of the hmc6343 = 0x32 >> 1
//#define HMC6343_ADDRESS 0x32        // Address of the hmc6343 itself (for write -- read would be 0x33)
#define ACCELEROMETER_REG 0x40      // Accelerometer
#define MAGNETOMETER_REG 0x45       // Magnetometer
#define HEADING_REG 0x50            // Heading
#define TEMP_REG 0x55               // Temperature


// Timespec Macros from FreeBSD
// https://github.com/freebsd/freebsd/blob/master/sys/sys/time.h
// Converted to use  structs rather than pointers to structs (in a define)
#define	timespecclear(tvp)	(tvp.tv_sec = tvp.tv_nsec = 0)

#define	timespeccmp(tvp, uvp, cmp)		\
	((tvp.tv_sec == uvp.tv_sec) ?		\
	    (tvp.tv_nsec cmp uvp.tv_nsec) :	\
	    (tvp.tv_sec cmp uvp.tv_sec))

#define	timespecadd(ts, us, vs)		            \
	do {								            \
		vs.tv_sec = ts.tv_sec + us.tv_sec;		\
		vs.tv_nsec = ts.tv_nsec + us.tv_nsec;	\
		if (vs.tv_nsec >= 1000000000L) {			\
			vs.tv_sec++;				            \
			vs.tv_nsec -= 1000000000L;			    \
		}							                \
	} while (0)


#define	timespecsub(tsp, usp, vsp)					\
	do {								            \
		vsp.tv_sec = tsp.tv_sec - usp.tv_sec;		\
		vsp.tv_nsec = tsp.tv_nsec - usp.tv_nsec;	\
		if (vsp.tv_nsec < 0) {				        \
			vsp.tv_sec--;				            \
			vsp.tv_nsec += 1000000000L;			    \
		} \
	} while (0)





/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                            Type Definitions                                 %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

/* Typedef ******************************************************/
typedef struct {
    int ax;
    int ay;
    int az;
    int mx;
    int my;
    int mz;
    int heading;
    int pitch;
    int roll;
    int T;
} tTilt;


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                          Function Declarations                              %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

// High-level Tasks
void Count_Photons(void);
int  Log_Data(void);
void Serial_Comms(void);
void Stdio_Comms(void);
void UpdateTilt(void);

// File IO
int  OpenFiles(void);
void CloseFiles(uint16_t BlocksWritten);

// User IO
int  OpenSerial(void);
void CloseSerial(uint16_t BlocksWritten);

// GPIO ACCESS
int  InitGPIO(void);
void CloseGPIO(void);

// TILT Helper  Functions
void TiltReadReg(uint8_t register,int *,int *,int *);
void TiltReadAcc(tTilt *t);
void TiltReadMag(tTilt *t);
void TiltReadHeading(tTilt *t);
void TiltReadTemp(tTilt *t);


// Helper Routines
void Sleep_ns(int);
#define Sleep_us(A)  Sleep_ns(1000*A)
#define Sleep_ms(A)  Sleep_ns(1000000*A)

int _kbhit() {
    static const int __STDIN = 0;
    static uint8_t initialized = 0;

    if (! initialized) {
        // Use termios to turn off line buffering
        struct termios term;
        tcgetattr(__STDIN, &term);
        term.c_lflag &= ~ICANON;
        tcsetattr(__STDIN, TCSANOW, &term);
        setbuf(stdin, NULL);
        initialized = 1;
    }

    int bytesWaiting;
    ioctl(__STDIN, FIONREAD, &bytesWaiting);
    return bytesWaiting;
}




/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                            Global Variables                                 %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

// Data Buffers -- Need to  be global to share across threads,
//      and volitile  to force update  across threads
static volatile uint16_t  B1[2048],  B2[2048];// Two Data Buffers, 4096B each
static volatile uint16_t *pNewData, *pOldData, *pTmpData;  // To swap buffers elegantly.
static volatile tTilt     Tilt;
static volatile uint32_t  LastSecPhotonCount=0;
static volatile uint32_t  LastBlockPhotonCount=0;

// Global Flags - A minimalist mutex semaphore
static volatile uint8_t fBufferFull=FALSE;
  // Prevents  Collisions on Data Buffers
  // Switched ON by READ CORE (wait while ON)   Switched OFF by WRITE_CORE (wait while OFF)
static volatile uint8_t fShutDown=FALSE;
  // Flag telling all processes to run or shutdown.
  // Read by everyone, Written by Serial_Comms ONLY
static volatile uint8_t fHeartbeatReady=FALSE;
  // Flag letting Counter tell Serial that there's a heartbeat ready to go

// Timing Variables
const uint16_t Nw = (DATA_BLOCK_SIZE - DATA_HEADER_SIZE)/DATA_CHUNK_SIZE;

// Other Global Variables
static int hI2C; // I2C  File Handle for Tilt sensor
static FILE *pDataFile,*pMetaFile;

// SERIAL Messages
const char RadToken[]     = "RAD";
const char OnToken[]      = "ON";
const char OffToken[]     = "OFF";
const char WiFiToken[]    = "WIFI";
const char PowerToken[]   = "POWERDOWN";
const char HelpToken[]    =  "HELP";
const char StatusToken[]  = "STATUS";
const char LoveToken[]    = "LOVE";

const char cmdWiFiOn[]    = "sudo ifconfig wlan0 up";
const char cmdWiFiOff[]   = "sudo ifconfig wlan0 down";

const char msgError[]     = "RAD Error... \r\n";
const char msgErrorOn[]   = "RAD Error: On Command Failed! \r\n";
const char msgErrorStringBuffer[]   = "RAD Error: Buffer Parse in CLI...  \r\n";
const char msgErrorStringBufferOverflow[]   = "RAD Error: Buffer Overflow in CLI...  \r\n";
const char msgOff[]       = "RAD Stopping Photon Count... \r\n";
const char msgWiFiOn[]    = "RAD WiFi On \r\n";
const char msgWiFiOff[]   = "RAD WiFi Off \r\n";
const char msgHelp[]      = "RAD Piss Off \r\n";
const char msgStatus[]    = "RAD The System is Down...\r\n";
const char msgLove[]      = "RAD It's what makes a Subaru a Subaru!\r\n";
const char msgNotRad[]    = "RAD ... You talking to me? \r\n";
const char msgPoweringDown[]  = "Preparing to Power Down... \r\n";
const char msgPoweredDown[]   = "Ready to Power Down, you Monster... \r\n";
const char msgGreetings[]   = "RAD -- Hellow Bigelow!! Hello DeepSee!!  \r\n";





// Stupid Binary  Outputt Tricks

#define FOURBYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c %c%c%c%c%c%c%c%c %c%c%c%c%c%c%c%c %c%c%c%c%c%c%c%c"
#define FOURBYTE_TO_BINARY(data)  \
  (data & (1<<0) ? '1' : '0'), \
  (data & (1<<1) ? '1' : '0'), \
  (data & (1<<2) ? '1' : '0'), \
  (data & (1<<3) ? '1' : '0'), \
  (data & (1<<4) ? '1' : '0'), \
  (data & (1<<5) ? '1' : '0'), \
  (data & (1<<6) ? '1' : '0'), \
  (data & (1<<7) ? '1' : '0'), \
  (data & (1<<8) ? '1' : '0'), \
  (data & (1<<9) ? '1' : '0'), \
  (data & (1<<10) ? '1' : '0'), \
  (data & (1<<11) ? '1' : '0'), \
  (data & (1<<12) ? '1' : '0'), \
  (data & (1<<13) ? '1' : '0'), \
  (data & (1<<14) ? '1' : '0'), \
  (data & (1<<15) ? '1' : '0'), \
  (data & (1<<16) ? '1' : '0'), \
  (data & (1<<17) ? '1' : '0'), \
  (data & (1<<18) ? '1' : '0'), \
  (data & (1<<19) ? '1' : '0'), \
  (data & (1<<20) ? '1' : '0'), \
  (data & (1<<21) ? '1' : '0'), \
  (data & (1<<22) ? '1' : '0'), \
  (data & (1<<23) ? '1' : '0'), \
  (data & (1<<24) ? '1' : '0'), \
  (data & (1<<25) ? '1' : '0'), \
  (data & (1<<26) ? '1' : '0'), \
  (data & (1<<27) ? '1' : '0'), \
  (data & (1<<28) ? '1' : '0'), \
  (data & (1<<29) ? '1' : '0'), \
  (data & (1<<30) ? '1' : '0'), \
  (data & (1<<31) ? '1' : '0')





#endif /* RadioPi_h */
