//
//  TiltTest.h
//  
//
//  Created by allan adams on 7/18/19.
//

#ifndef TiltTest_h
#define TiltTest_h

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/signal.h>
#include <sys/errno.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <pigpio.h>


#define ONE_BILLION 1000000000L
#define ONE_MILLION 1000000L


void Sleep_ns(int);
#define Sleep_us(A)  Sleep_ns(1000*A)
#define Sleep_ms(A)  Sleep_ns(1000000*A)


#ifndef HMC6343_H

/* Typedef ******************************************************/
// global timer definitions
typedef struct {
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

#define HMC6343_H
//Defines the addresses for the various registers on the HMC6343
#define I2CBUS 1                    // Which bus: 0 [GPIO 0,1] or 1 [GPIO 2,3]
#define HMC6343_ADDRESS 0x19        // Address of the hmc6343 itself
//#define HMC6343_ADDRESS 0x32        // Address of the hmc6343 itself (for write -- read would be 0x33)
#define ACCELEROMETER_REG 0x40      // Accelerometer
#define MAGNETOMETER_REG 0x45       // Magnetometer
#define HEADING_REG 0x50            // Heading
#define TEMP_REG 0x55               // Temperature
void TiltReadReg(uint8_t register,int *,int *,int *);
void TiltReadAcc(tTilt *t);
void TiltReadMag(tTilt *t);
void TiltReadHeading(tTilt *t);
void TiltReadTemp(tTilt *t);
#endif    /* COORDINATE_H */


/* Global Variables **********************************************/
static volatile tTilt    Tilt;
static int hI2C;

/* Function  Declarations..... */
void  Log_Data(void);
void  UpdateTilt(void);
int   InitGPIO(void);
void  CloseGPIO(void);






#include <sys/select.h>
#include <stropts.h>

int _kbhit() {
    static const int STDIN = 0;
    static uint8_t initialized = 0;
    
    if (! initialized) {
        // Use termios to turn off line buffering
        struct termios term;
        tcgetattr(STDIN, &term);
        term.c_lflag &= ~ICANON;
        tcsetattr(STDIN, TCSANOW, &term);
        setbuf(stdin, NULL);
        initialized = 1;
    }
    
    int bytesWaiting;
    ioctl(STDIN, FIONREAD, &bytesWaiting);
    return bytesWaiting;
}



#endif /* TiltTest_h */


