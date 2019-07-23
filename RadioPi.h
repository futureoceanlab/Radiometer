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
#include <time.h>
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

#define FOL_RAD_VV 0.1              //  Radiometer Software Version
#define DATA_BLOCK_SIZE 4096        // Number of Bytes per data block written to storage
// SD writes are  made in  chunks of  512B
// More efficient to spread data over 4KB
#define DATA_HEADER_SIZE 32         // Number  of Bytes in the Header of each Data Block
#define DATA_CHUNK_SIZE 4           // Number of Bytes per Data Chunk inside the Data Block: 2B time + 2B Data
#define SAMPLES_PER_SEC = 12192     // Samples per second: this ensures precisely 12 blocks per sec
//#define SAMPLES_PER_SEC = 16256     // Samples per second: this ensures precisely 16 blocks per sec
#define ONE_BILLION 1000000000L
#define ONE_MILLION 1000000L

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

// HMC6343 Definitions
#define I2CBUS 1                    // Which bus: 0 [GPIO 0,1] or 1 [GPIO 2,3]
#define HMC6343_ADDRESS 0x19        // Address of the hmc6343 = 0x32 >> 1
//#define HMC6343_ADDRESS 0x32        // Address of the hmc6343 itself (for write -- read would be 0x33)
#define ACCELEROMETER_REG 0x40      // Accelerometer
#define MAGNETOMETER_REG 0x45       // Magnetometer
#define HEADING_REG 0x50            // Heading
#define TEMP_REG 0x55               // Temperature





/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                            Type Definitions                                 %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

/* Typedef ******************************************************/
// global timer definitions
//typedef struct {
//    uint16_t ax;
//    uint16_t ay;
//    uint16_t az;
//    uint16_t mx;
//    uint16_t my;
//    uint16_t mz;
//    uint16_t heading;
//    uint16_t pitch;
//    uint16_t roll;
//    uint16_t T;
//} tTilt;

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
void Count_Photons();
void Log_Data();
void Serial_Comms();

// File IO
int OpenFiles();
int CloseFiles(uint16_t BlocksWritten);

// GPIO ACCESS
int  InitGPIO(void);
void CloseGPIO(void);
void UpdateTilt(void);
int  OpenSerialPort(void);

// TILT Helper  Functions
void TiltReadReg(uint8_t register,int *,int *,int *);
void TiltReadAcc(tTilt *t);
void TiltReadMag(tTilt *t);
void TiltReadHeading(tTilt *t);
void TiltReadTemp(tTilt *t);


// Helper Routines
void SetSystemLowPower(void);
void Sleep_ns(int);
#define Sleep_us(A)  Sleep_ns(1000*A)
#define Sleep_ms(A)  Sleep_ns(1000000*A)




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
static volatile uint8_t fLogData=FALSE;
  // Switched by: SERIAL_CORE   Read by: WRITE CORE (wait while FALSE)
static volatile uint8_t fCaptureData=FALSE;
  // Switched by WRITE_CORE   Read by READ_CORE (wait while FALSE)
static volatile uint8_t fBufferFull=FALSE;
  // Prevents  Collisions on Data Buffers
  // Switched ON by READ CORE (wait while ON)   Switched OFF by WRITE_CORE (wait while OFF)
static volatile uint8_t fCloseFiles=FALSE;
  // Tells WRITE_CORE to close  all open files.
  // Switched ON by SERIAL_CORE (wait til OFF), SWITCHED OFF by WRITE_CORE

// Timing Variables
const uint16_t Nw = (DATA_BLOCK_SIZE - DATA_HEADER_SIZE)/DATA_CHUNK_SIZE;

// Other Global Variables
static int hI2C; // I2C  File Handle for Tilt sensor

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

const char msgError[]     = "Error... \r\n";
const char msgOff[]       = "Stopping Photon Count... \r\n";
const char msgWiFiOn[]    = "WiFi On \r\n";
const char msgWiFiOff[]   = "WiFi Off \r\n";
const char msgHelp[]      = "Piss Off \r\n";
const char msgStatus[]    = "The System is Down...\r\n";
const char msgLove[]      = "It's what makes a Subaru a Subaru!\r\n";
const char msgNotRad[]    = "RAD ... You talking to me? \r\n";
const char msgPoweringDown[]  = "Preparing to Power Down... \r\n";
const char msgPoweredDown[]   = "Ready to Power Down, you Monster... \r\n";




#endif /* RadioPi_h */
