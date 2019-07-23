//
//  TiltTest.c
//  
//
//  Created by allan adams on 7/18/19.
//

#include "TiltTest.h"


/* MAIN **********************************************************/
int main() {
    printf("Start!\r\n");
    InitGPIO();
    printf("GPIO INITIALIZED\r\n");
    Log_Data();
    printf("0:finished\n");
    return 0;
}

void  Log_Data() {
    // File Variables
    while(!_kbhit())  {
//        printf("About to  query  Tilt...\r\n");
        UpdateTilt();
        printf("Heading: %u; Pitch: %u; Roll: %u \r\n",Tilt.heading,Tilt.pitch,Tilt.roll);
        Sleep_ms(600); // Sleep for 1 ms before checking again
    }  //  while(fLogData)
}


void UpdateTilt(void) {
    static tTilt tmp;

    TiltReadHeading(&tmp);
    
    Tilt.heading=tmp.heading;
    Tilt.pitch=tmp.pitch;
    Tilt.roll=tmp.roll;
}


int  InitGPIO(void) {
    
    if(gpioInitialise()<0) return 1;
    
    // LET'S GET THE I2C LINES PREPARED
    hI2C = i2cOpen(I2CBUS, HMC6343_ADDRESS, 0);
    
    return 0;
}

void CloseGPIO(void) {
    i2cClose(hI2C);
    hI2C = 0;
    gpioTerminate();
}



/**
 *     @function: TiltReadReg()
 *
 *    Polls the appropiate register, processes returned data and returns them to
 *    the appropiate function by reference.
 *
 *     @param uint8_t reg   -       The register on the HMC6343 to be polled
 *     @param int& a      -       first value returned from the HMC
 *     @param int& b      -       second value returned from the HMC
 *     @param int& c      -       third value returned from the HMC
 *     @return              -       Returns a, b and c by passing them as a reference.
 
 
 The I2C slave address byte consists of the 7 most significant bits with the least significant bit zero filled. As described earlier, the default (factory) value is 0x32 and the legal 2I C bounded values are between 0x10 and 0xF6. This slave address is in EEPROM address 0x00. Users can change the slave address by writing to this location. Any address updates will become effective after the next power up or after a reset command.
 
 Note: The SparkFun Code used 0x19 -- that's just plain wierd. Did they reset?
 
 
 */
void TiltReadReg(uint8_t reg, int *a,int *b,int *c) {
    
    static uint8_t highByte=0, lowByte=0;
    
//    printf("About to  i2cWriteByte\r\n");
    i2cWriteByte(hI2C, reg);
//    printf("Done \r\n");

    Sleep_ms(2);  // Give the chip 2ms to update and reply; it requests at least 1ms
    
//    printf("About  to read two bytes... \r\n");
    highByte = i2cReadByte(hI2C);
    lowByte  = i2cReadByte(hI2C);
//    printf("Done \r\n");
    *a = ((highByte << 8) | lowByte);
    
    highByte = i2cReadByte(hI2C);
    lowByte  = i2cReadByte(hI2C);
    *b = ((highByte << 8) | lowByte);
    
    highByte = i2cReadByte(hI2C);
    lowByte  = i2cReadByte(hI2C);
    *c = ((highByte << 8) | lowByte);
    
    return;
}



void TiltReadAcc(tTilt *t) {
    static int roll, pitch, yaw;
    TiltReadReg(ACCELEROMETER_REG, &roll, &pitch, &yaw);
    t->ax = roll ;
    t->ay = pitch ;
    t->az = yaw ;
    return;
}
void TiltReadMag(tTilt *t) {
    static int magX, magY, magZ;
    TiltReadReg(MAGNETOMETER_REG, &magX, &magY, &magZ);
    t->mx = magX ;
    t->my = magY ;
    t->mz = magZ ;
    return;
}
void TiltReadHeading(tTilt *t) {
    static int h, p, r;
    TiltReadReg(HEADING_REG, &h, &p, &r);
    t->heading = h;
    t->pitch = p ;
    t->roll = r ;
    return;
}
void TiltReadTemp(tTilt *t) {
    static int T,p,r;
    TiltReadReg(TEMP_REG, &T,&p,&r);
    t->T = T / 10;
    return;
    /*  NB: adding pitch and roll pass-by-references let you
     *  also get roll and pitch with this function
     */
}


void Sleep_ns(int nS) { // cross-platform sleep function
    struct timespec SleepyTime;
    SleepyTime.tv_sec  =  nS / ONE_BILLION;
    SleepyTime.tv_nsec =  nS % ONE_BILLION;
    nanosleep(&SleepyTime, NULL);
}
