/*
 RadioPi.c
 
 Allan Adams(1,2), Jake Bernstein (1), JunSu Jang (1)
 
 (1)   Future Ocean Lab
 Massachusetts Institute of Technology
 
 (2)   Deep Submergence Lab, AOPE
 Woods Hole Oceanographic Institute
 
 11111111112222222222333333333344444444445555555555666666666677777777778888888888
 
 RadioPi is a Raspberry Pi 3 executable that operates the FOL/WHOI Radiometer.
 Its key responsibilities are:
 1. Capture & timestamp raw photon counts at ~12kHz from the Hamamatsu sensor
 2. Store data to non-volatile storage (initially, SD card)
 3. Provide serial interface for control and heartbeat
 4. Don't fuck up
 
 Tasks 1, 2, & 3 are managed by a custom electronics stack.  Task 4 is up to us.
 
 In a little more detail.....
 
 A. Hardware:
 
 The sensor, a Hamamatsu C13366-1350GD, outputs digital signals over SMB of
 duration 10ns and amplitude ~5V. A photon hit while the comparator is high
 keeps it high, so no 2nd falling edge, ie photon 2 is lost.  There is then a
 ~5ns down time after each fall before the comparator goes active (any hit
 during those 5ns is lost). So we deviate from linearity significantly when
 the odds of two photons hitting within 15ns becomes significant, around 10MHz.
 In  principle, the  most counts we could get per second would be one falling
 edge every 15ns, corresponding to about 67MHz -- in practice,  we will see a
 significant departure from linearity around 25MHz (roughly 15% deviation),
 will maximize count at around 50MHz (and  minimize count resolution) and will
 enter a hole-dominated regime at higher photon rates.  Meanwhile, the sensor
 dark noise is about 2.5 kcps.  So we can expect a dynamic range of about 1E4
 without working too hard, and perhaps upwards of 4E5 if we calibrate the
 super-saturated regime adequately. Calibrating the dark noise gives us
 additional breathing room on the low end, which could win a factor of 2 or so
 if we can integrate long enough to believe the signal.
 
 Detecting each photon is way outside the range of any embedded system we can
 put in a 2500m tube, so we need to coarse grain the raw data feed.  Fast
 bioluminescence flashes can have sub-ms structure, so we'd like to sample at
 10kHz or faster.  Running at our max possible source data rate of 67MHz (15ns),
 a 10kHz counter would face up to 6.7k samples, so we  need a bit depth of at
 least 12.7. We skin that cat by using a fast (95MHz) 5V 12-bit asynchronous
 counter, the TI SN74LV4040, and sampling the counter at a slightly higher
 frequency than 10kHz. This counter has two inputs:
 CLK     falling edges to CLK increment the 12-bit output by 1 with a
 roughly 5-10ns delay
 CLR     Pulling CLR high for at least 5ns clears the 12-bit output
 registers, again with a ~5ns dealay
 Sampling at 12kHz gives us a max of about 49MHz, right at our expected maximum
 hit rate, while 16kHz gives us about 67MHz, our maximum theoretically possible
 result (and thus a small buffer).
 
 (NOTE: You might be tempted to use a 16-bit counter.  The trouble is that all
 available 16-bit counters output over 8-bit buses, and thus require read-out
 interfaces that are twice as fast, significantly complicating the rest of the
 electronics stack. The SN74LV4040 series is a beautiful family of counters
 for our purposes, and 12 bit well suffices.)
 
 To avoid latency while reading the counter (odds are it will take longer
 than 15ns to read the data in!), we then feed the counter's 12-bit output
 into a (5V-tolerant) 3.3V 16-bit Transparent D-type Latch (TI SN74LVTH162373).
 This has the  additional advantage of providing a (5V-tolerant) 3.3V interface
 to our Pi, which is good because 5V would fry it. This latch has four inputs:
 !OE1,!OE2   When !OE is HIGH, outputs go silent (high impedance).
 When !OE is LOW, outputs are active.
 LE1, LE2    When LE is HIGH, outputs follow inputs.
 When LE is LOW, outputs hold.
 
 The counting ptocess  is thus:
 HARDWIRE !OE1=!OE2=0 // Latch Output always enabled
 HARDWIRE LE=LE1=LE2  // Treat two 8-bit latches as  a single 16-bit latch
 HARDWIRE HOUT to CLK // Hamamatsu  signal feeds the clock on the counter
 HARDWIRE COUT to LIN // Counter output  feeds the  transparent  latch
 ...
 SET CLR HIGH         // Clear the  counter
 SET CLR LOW          // Start  the  counter
 while(wait(83us)) {
 SET LE LOW       // Hold  the Latch
 SET CLR HIGH     // Clear the counter
 SET CLR LOW      // Reset the counter
 READ LOUT to CACHE  // Someone Else's Problem Now
 SET LE HIGH      // Free the Latch
 }
 
 On top of the counting photons, we need to keep track of which way the system
 is pointing.  To that end we have a precision Tilt sensor, the Honeywell
 HMC6343, on a Sparkfun breakout, accessible via I2C.  We can be pretty casual
 about  precisely  when  we  query, as the tilt should not be changing all
 that fast,
 
 The computational job that remains is to sample the 16-bit latch at 12kHz into
 a data buffer (FAST), store the buffer to non-volatile storage (LAZY), update
 the Tilt-sensor data (also LAZY), and provide Comms (async serial during
 runtime, wifi on deck to pull data) to manage the circus (SLOW). This is well
 within the scope of a headless 4-core RPi3A+ with RT-patched kernel.  We
 implement the counter, latch, SMB, and power electronics and connectors as a
 custom hat on the Pi. Note that we need 12GPIO pins for the data, 2 for LE &
 CLR, 2 for I2C (tilt), and 1 last pin for the Hamamtsu status line, for a
 total of 17GPIO lines.
 
 A note on power.  The radiometer will be fed 12V (up to 20W), but the Pi needs
 5V and the Hamamtsu needs +5V and -5V.   We handle the conversions with a set
 of three LMR12020's, an extremely high-efficiency (>95%) switching-mode buck
 chipset, producing 5V, 5.5V, and -5.5V. The 5V feeds the Pi/hat while the
 +/-5.5V feed a pair of LDOs to generate very low noise +/-5V rails for the
 Hamamatsu. This brings our overall system efficiency down to about 90%.  Total
 power draw should hover somewhere under 6W nominal, with bursts up to perhaps
 10W when all hell breaks loose. :-)
 
 A note on data storage and sampling rates.  We will be storing something like
 48KB/s, which is not that much -- indeed the SD interface should be able to
 handle an  additiional two orders of magnitude.  But there's a catch:
 SD writes happen in large blocksizes -- strictly in multiples of 512b, but
 for us in chunks of 4096B. To avoid the overhead of the SD interface slowing
 things down, we store data into a pair of 4K caches, writing each to disk as
 soon as its full (while data feeds into  the other).  Each block has a 32KiB
 header recording UTC and Tilt.  That leaves 4064B for data.  Each 2B count
 is stored along with a 2B record of usec ellapsed since last count, so each
 sample costs 4B.  That gives us 1016 Samples per block.  Pulling 12 blocks
 per second gives an ultimate sampling rate of 12,192 Hz, corresponding to a
 max data in rate of 50MHz; pulling in 16 blocks per second gives an ultimate
 sampling rate of 16,256 samples/s, corresponding to a max data rate of 67MHz.
 These are precisely the max data rates identified above for the sensor itself.
 
 We could, of course, sample faster if there's a scientific reason to do so.
 The fundamental speed limitation here is how precisely we can do the sampling
 timing, but pushing up to 64kHz should be doable.  If we do choose to
 resolve scales much faster than that, we should either introduce a dedicated
 sampling MCU or just use some FPGA fabric to build the full sampling
 computational pipe.
 
 
 B. Software:
 
 This file contains the source code for an RPi3A+ real-time application that
 operates the radiometer.
 
 For the most part this is a pretty straightforwarrd coding problem, with two
 caveats.  First, there are multiple timing-critical processes with
 conflicting latencies (eg sd card writes come in multiples of 512b/4KB,
 serial comms are timing  sensitive, etc, and meanwhile the phottons never
 stop coming and we can't afford to miss a single edge).  So we need to
 dedicate specific cores to different tasks.  Second, timeing on the Pi is
 poor -- there's no RTC, but more importantly there IS Linux, which means we
 run the risk of involuntary preemption at any moment (not to mention the
 overhead of a bloated OS).  To deal with all this we run a headless
 distribution of Raspbian with a real-time-patched kernel and exploit the
 POSIX OMP library for parallel core management, giving the photon-counting
 routine a dedicated  realtime  core.  Timing on that core is handled by
 queries to a monotonic high resolution timer and nanosleep call to avoid
 spinning wheels when logging is paused.
 
 
 
 C.  Formatting and Protocols
 
 Metadata File Header Format  (ASCII):
 "Future Ocean Lab Radiometer Data File \r\n"
 "Software Version: FOL_RAD_VV"
 " .....\r\n"
 "Data Rate: SAMPLES_PER_SEC  \r\n"
 "Data Block Size: 4096  \r\n"
 "Data Format: Microseconds [2B] Photon  Count [2B]   \r\n"
 "Data Header Size: 32B  \r\n"
 "Data Header Format: \"@@...(18 times)...@@\" EpochTime[4B] NanoSeconds[4B] Tilt[6B] \r\n"
 " .....\r\n"
 "CRUISE NAME, SHIP NAME, etc \r\n"
 "YYYY:MM:DD HH:MM:SS \r\n"
 
 
 Data Chunk Header Format (binary):
 "@@...(18 times)...@@" EpochTimeUTC[4B] NanoSeconds[4B] Tilt[6B]
 32 Bytes [= 18+14]
 
 Data Point Format:
 [2B: uint16_t time since last measurement in usec] [2B: padded 12bit photon count]
 4 Bytes
 
 Heartbeat Message Format
 “RAD.VV yyyy:mm:dd  hh:mm:ssZ DDDDDDDDDD HHHHH PPPPP RRRRR \r\n"
 
 */


#include "RadioPi.h"


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                                 Main()                                      %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */
int main() {

    // SetSystemLowPower();
    
    InitGPIO();
    
	// TODO: Wait until ON signal has been received
    #pragma omp places(cores) proc_bind(spread)
    #pragma omp parallel num_threads(3)
    {
        #pragma omp single nowait
        {
            Log_Data();
		}
		#pragma omp single nowait
		{
            Count_Photons();
		}
		#pragma omp single
		{
            Serial_Comms();
		}
    }
	printf("0:finished\n");
    return 0;
}



/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                             Count_Photons()                                 %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */
void  Count_Photons() {
    struct timespec t, to, dt, tn;
    uint32_t RawData=0;
    uint16_t ObsPhotonCount=0, ObsTime=0;
    uint16_t DataHeader[16];
    uint16_t iBlock=0;
    uint32_t BlockPhotonCount=0;
    uint32_t SecPhotonCount=0;
    int fClocksInitialized=FALSE;
    static uint32_t Mask[2];
    
    Mask[1] = ((1 << 10) -1) << Lpins[0];
    Mask[2] = ((1 <<  2) -1) << Lpins[10];
    
    strncopy((char *)DataHeader,"@@@@@@@@@@@@@@@@@",18); // NOTE: Include one termination '\0' so that  it's  clearly  readable as an ascii  string

    dt.tv_sec = 0;
    dt.tv_nsec = ONE_BILLION / SAMPLES_PER_SEC; // Nanoseconds per sample
    
    while(){ // eternal loop

        while(fCaptureData){ // Capture a new Buffer and Swap when ready

            if(!fClocksInitialized)  { // First data sample, initialise clocks etc
                /*    Reset the counter and toggle the latch:    */
                gpioWrite(PIN_LATCHEN,      0);  // Pull the latch down to hold data
                gpioWrite(PIN_COUNTCLEAR,   1);  // Reset Counter. Need to hold pin high at least 5us, ~200MHz
                gpioWrite(PIN_COUNTCLEAR,   0);  // Happily (sic) the Pi can only toggle a pin at < 87MHz.
                clock_gettime(CLOCK_REALTIME, &t); // Record time Count began anew;
                gpioWrite(PIN_LATCHEN,      1);  // Release the Latch
                
                timespecadd(t,dt,tn); // tn = t + dt;
                to=t;
                fClocksInitialized=TRUE;
            }

            // Fill DataHeader = Array of 16 uint16_t with Time and  Tilt Data
            memcopy(DataHeader+9,&to.tv_sec,4);
            memcopy(DataHeader+11,&to.tv_nsec,4);
            DataHeader[13]=Tilt.heading;
            DataHeader[14]=Tilt.pitch;
            DataHeader[15]=Tilt.roll;
            
            // Write DataHeader to Buffer
            memcopy(pNewData,DataHeader,32);
            
            for(i=0; i<Nw; i++) {

                // Spin until time for next data sample
                do {
                    clock_gettime(CLOCK_REALTIME, &t))
                } while(timespeccmp(t,tn,<))
                
                ////////////////////////////////////////////////////////////
                ////////////////////////////////////////////////////////////
                // Begin  Critical Code
                /*    Read data from the latch    */
                gpioWrite(PIN_LATCHEN,      0);  // Pull the latch down to hold data
                gpioWrite(PIN_COUNTCLEAR,   1);  // Reset Counter. Need to hold pin high at least 5us, ~200MHz
                gpioWrite(PIN_COUNTCLEAR,   0);  // Happily (sic) the Pi can only toggle a pin at < 87MHz.  We good.
                clock_gettime(CLOCK_REALTIME, &t)
                RawData = gpioRead_Bits_0_31();  // Pull the data & reorder bits as needed
                gpioWrite(PIN_LATCHEN,      1);  // Release the Latch!
                // Now reorder the relevant bits into a photon count in 5 operations...
                ObsPhotonCount =    ( (RawData & NMask[0]) >> 4 ) |
                                    ( (RawData & NMask[1]) >> 6 ) ;
                
                // End Critical Code
                // Release the Kracken!!!
                ////////////////////////////////////////////////////////////
                ////////////////////////////////////////////////////////////

                timespecsub(t,to,to); // to = t-to;
                ObsTime  =  (to.tv_nsec/1000) & ((1 << 16)-1); // extract the 16 LSB of the number of usec since last eval
                to = t;

                //    [Write 2B (usec since last data) and 2B (Data) to buffer];
                pNewData[2*i+16] = ObsTime;
                pNewData[2*i+17] = ObsPhotonCount;
                BlockPhotonCount += ObsPhotonCount;
                
                timespecadd(tn,dt,tn); // tn = tn+dt, increement sample clock
            }  // for(i=0; i<Nw; i++,tn_ns+=dt)
            // Buffer Filled, time to swap buffer...
            
            
            while(fBufferFull){}; // Hang until OldData has been written and released by Storage thread
            pTmpData = pNewData;
            pNewData = pOldData;
            pOldData = pTmpData;
            fBufferFull  = TRUE; // set flag telling thread 2 a DataBlock is ready in the Buffer to store
            
            LastBlockPhotonCount = BlockPhotonCount;
            BlockPhotonCount = 0;
            SecPhotonCount += LastBlockPhotonCount;
            if(iBlock==11) {iBlock=0;LastSecPhotonCount=SecPhotonCount;SecPhotonCount=0;};

        }  // while(fCaptureData)

        Sleep_ms(1); // Sleep for 1 ms before checking again

        fClocksInitialized = FLASE;

    } // while()
    
}


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                               Log_Data()                                    %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */
void  Log_Data() {
    // File Variables
    FILE *pDataFile,*pMetaFile;
    const char sFileRoot="FOL_RAD_";
    uint8_t fFilesOpen=FALSE;
    uint32_t BlocksWritten=0;

    while(){
        while(fLogData)  {
            
            if(!fFilesOpen) {OpenFiles(); fFilesOpen=TRUE; BlocksWritten = 0;}
            if(!CaptureData) {fCaptureData=TRUE;};
            
            while(!fBufferFull) {Sleep_ms(1)};
            
                // Write pOldData to SD card
            fwrite(pOldData, 1, DATA_BLOCK_SIZE, pDataFile);
            fflush(pDataFile);
            fBufferFull = FALSE;
            BlocksWritten++;
            
            // Pull New Tilt Data from I2C
            UpdateTilt();
        }  //  while(fLogData)
        
        fBufferFull  = FALSE;
        fCaptureData = FALSE;
        fBufferFull  = FALSE;
        
        if(fCloseFiles&&fFilesOpen) {
            CloseFiles(BlocksWritten);
            fCloseFiles=FALSE;
            fFilesOpen=FALSE;
        }; // if(fCloseFiles&&fFilesOpen)
        
        Sleep_ms(1); // Sleep for 1 ms before checking again

    } // while()
}


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                             Serial_Comms()                                  %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */
/*  Serial Comms Interface Specification:

 1. Serial Interface:
 RS232 19200 8N1
 
 2. Upon startup, system will output a greeting on the serial line:
 ==> "Radiometer RAD.VV starting up... \r\n"
 VV               Version (2 ascii symbols)
 Followed shortly thereafter by a state data dump for the record:
 ==> "RAD Setup Data: [comma separated string] \r\n”
 
 3. To begin data recording and set clock:
 <== “RAD ON yyyy:mm:dd hh:mm:ss.sss \r\n”
 Response:
 ==> “RAD ON yyyy:mm:dd hh:mm:ss.sss \r\n” followed by 1Hz data stream
 OR
 ==> “RAD ERROR: <MESSAGE STRING> \r\n” and no heartbeat
 
 4. To pause data recording:
 <== “RAD OFF \r\n”
 Response:
 ==> “RAD OFF \r\n”  followed by cessation of 1Hz data stream
 
 5. 1Hz Heartbeat ASCII Format:
 ==> “RAD.VV yyyy:mm:dd  hh:mm:ss DDDDDDDDDD HHHHH PPPPP RRRRR \r\n"
 OR
 ==> “RAD ERROR: <MESSAGE STRING> \r\n"
 VV               Version
 yyyy:mm:dd       year:month:day
 hh:mm:ss         UTC
 DDDDDDDDDD       Photon count during  previous second  (uint32_t)
 HHHHH            Heading (in 1/10s of degrees)
 PPPPP            Pitch (in 1/10s of degrees)
 RRRRR            Roll (in 1/10s of degrees)
 
 6. To  prepare the system to PowerDown:
 <== "RAD Power Down\r\n"
 Response:
 ==> "RAD Powering Down... \r\n"
 <<wait>>
 ==> "RAD Ready to  power  down. \r\n"
 
 7. To turn  WIFI On
 <== "RAD WiFi On\r\n"
 Response:
 ==> "RAD WiFi On\r\n"
 
 8. To turn  WIFI Off
 <== "RAD WiFi Off\r\n"
 Response:
 ==> "RAD WiFi Off \r\n"
 
 9. For help with commands:
 <== "RAD Help \r\n"
 Response:
 ==> "<LIST OF COMMANDS> \r\n"
*/
void Serial_Comms()  {
    struct termios options;
    char Rbuffer[64],Wbuffer[64];
    
    int bytes,n,hSerial;
    const char WS[2] = " ";
    char *token;
    uint16_t tyear,tmonth,tday,thour,tminute,tsec;

    // system("sudo systemctl stop serial-getty@ttyAMA0.service");

    hSerial = OpenSerialPort();

    while() {
        ioctl(hSerial, FIONREAD, &bytes);
        
        if(bytes!=0){
            n = read(hSerial, Rbuffer, 64);
            token = strtok(Rbuffer, WS);
            
            // Make sure the msg is intended for the Radiometer
            if(strcmp(token,RadToken)==0) {
                token = strtok(NULL,WS);
                // ON
                if(strcmp(token,OnToken)==0) {
                    n = sscanf{Rbuffer,"ON %u:%u:%u %u:%u:%u \r\n",&tyear,&tmonth,&tday,&thour,&tminute,&tsec};
                    if(n==6) {
                        /* Set Time */
                    }
                    // Get Time
                    // FILL BUFFER sprintf(Wbuffer,"Starting Photon Count at %u:%u:%u %u:%u:%u \r\n",);
                    fLogData=TRUE;
                    write(hSerial, Wbuffer,strlen(Wbuffer));
                }
                // OFF
                else if(strcmp(token,OffToken)==0) {
                    fLogData=FALSE;
                    write(hSerial, msgOff,strlen(msgOff));
                }
                // WIFI
                else if(strcmp(token,WiFiToken)==0) {
                    token = strtok(NULL,WS);
                    // WIFI ON
                    if(strcmp(token,OnToken)==0) {
                        system(cmdWiFiOn);
                        write(hSerial, msgWiFiOn,strlen(msgWiFiOn));
                    }
                    // WIFI  OFF
                    else if(strcmp(token,OffToken)==0) {
                        system(cmdWiFiOff);
                        write(hSerial, msgWiFiOff,strlen(msgWiFiOff));
                    }
                }
                // POWERDOWN
                else if(strcmp(token,PowerToken)==0) {
                    fLogData=FALSE;
                    fCloseFiles=TRUE;
                    write(hSerial, msgPoweringDown,strlen(msgPoweringDown));
                    // Do  Stuff as needed
                    sleep(5);
                    // Make sure  you're ready TO  DIE!!!
                    while(!log_terminated || !count_terminated){}
                    write(hSerial, msgPoweredDown,strlen(msgPoweredDown));

                }
                // HELP
                else if(strcmp(token,HelpToken)==0) {
                    write(hSerial, msgHelp,strlen(msgHelp));
                }
                // STATUS
                else if(strcmp(token,StatusToken)==0) {
                    write(hSerial, msgStatus,strlen(msgStatus));
                }
                // LOVE
                else if(strcmp(token,LoveToken)==0) {
                    write(hSerial, msgLove,strlen(msgLove));
                }
            } // if(strcmp(token,RadToken)==0)
            else {
                write(hSerial, msgNotRad,strlen(msgNotRad));
            }
        } // if(bytes!=0)
    } // while()
    close(hSerial);
}




/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                             FileIO Function                                 %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */
int   OpenFiles(void)  {
    char *DataName,*MetaName;
    char sFileNameTime[24],sHeaderTime[24],sFileNameTxt[48],sFileNameBin[48];
    time_t rawtime;
    struct tm *timeinfo;
    
    time(&rawtime);
    timeinfo = gmtime(&rawtime);
    
    strftime(sHeaderTime,24,"%F %T",timeinfo); // "YYYY-MM-DD HH:MM:SS"
    strftime(sFileNameTime,24,"%Y_%m_%d_%H_%M_%S",timeinfo); // "YYYY_MM_DD__HH_MM_SS"
    
    strcpy(sFileNameTxt,sFileRoot);
    strcat(sFileNameTxt,sNameTime);
    strcpy(sFileNameBin,sFileNameTxt);
    strcat(sFileNameTxt,".txt");
    strcat(sFileNameBin,".bin");
    
    pDataFile =  fopen(sFileNameBin,"a");
    pMetaFile =  fopen(sFileNameTxt,"a");
    
    fprintf(pMetaFile,"Future Ocean Lab Radiometer Data File \r\n");
    fprintf(pMetaFile,"Software Version: %f",FOL_RAD_VV);
    fprintf(pMetaFile," .....\r\n");
    fprintf(pMetaFile,"Data Rate: %u  \r\n",SAMPLES_PER_SEC);
    fprintf(pMetaFile,"Data Block Size: %u Bytes  \r\n",DATA_BLOCK_SIZE);
    fprintf(pMetaFile,"Data Format: Nanoseconds [2B] Photon  Count [2B]   \r\n");
    fprintf(pMetaFile,"Data Header Size: 32B  \r\n");
    fprintf(pMetaFile,"Data Header Format: \"@@...(18 times)...@@\" EpochTime[4B] NanoSeconds[4B] Tilt[6B] \r\n");
    fprintf(pMetaFile," .....\r\n");
    fprintf(pMetaFile,"%s, %s \r\n",CruiseName,ShipName);
    fprintf(pMetaFile,"File Created %s \r\n",sHeaderTime);
    
}

int   CloseFiles(uint16_t BlocksWritten)  {
    time_t rawtime;
    struct tm *timeinfo;
    char sbuffer[24];
    
    time(&rawtime);
    timeinfo = gmtime(&rawtime);
    
    strftime(sbuffer,24,"%F  %T",timeinfo); // "YYYY-MM-DD HH:MM:SS"
    fprintf(pMetaFile,"File Closed %s after %u 4KiB Blocks Written. \r\n",sbuffer,BlocksWritten);
    
    fflush(pMetaFile);
    fflush(pDataFile);
    
    fclose(pMetaFile)
    fclose(pDataFile)
    
}



/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                           Public GPIO Functions                             %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

int  InitGPIO(void) {
    
    if(gpioInitialise()<0) return 1;

    // FIRST, LET'S GET THE  GPIO PINS SQUARED AWAY
    
    // Set Input pins to input and remove pull-up resistors
    for(i=0;1<12;i++) {
        gpioSetMode(Lpins[i],PI_INPUT);
        gpioSetPullUpDown(Lpins[i], PI_PUD_OFF);
    }
    gpioSetMode(PIN_HSTATE,      PI_INPUT);
    gpioSetPullUpDown(PIN_HSTATE,PI_PUD_OFF);
    
    //  Set ouput Pins to Output
    gpioSetMode(PIN_nOUTEN,     PI_OUTPUT);
    gpioSetMode(PIN_LATCHEN,    PI_OUTPUT);
    gpioSetMode(PIN_COUNTCLEAR, PI_OUTPUT);
    
    // Initialize pin states:
    gpioWrite(PIN_nOUTEN,       0);
    gpioWrite(PIN_LATCHEN,      1);
    gpioWrite(PIN_COUNTCLEAR,   1);
    gpioWrite(PIN_COUNTCLEAR,   0);
    
    // GET THE I2C LINES PREPARED
    hI2C = i2cOpen(I2CBUS, HMC6343_ADDRESS, 0);
    
    return 0;
}

void CloseGPIO(void) {
    i2cClose(hI2C);
    hI2C = 0;
}

void UpdateTilt(void) {
    static tTilt tmp;
    
    TiltReadHeading(&tmp);
    
    Tilt.heading=tmp.heading;
    Tilt.pitch=tmp.pitch;
    Tilt.roll=tmp.roll;
}

int OpenSerialPort(void) {
    int sfd = open("/dev/serial0", O_RDWR | O_NOCTTY);
    
    if (sfd == -1) {
        printf("Error no is : %d\n", errno);
        printf("Error description is : %s\n", strerror(errno));
        return (-1);
    };
    
    tcgetattr(sfd, &options);    // Set serial port to 19200 8N1
    cfsetspeed(&options, B19200);
    cfmakeraw(&options);
    options.c_cflag &= ~CSTOPB;
    options.c_cflag |= CLOCAL;
    options.c_cflag |= CREAD;
    options.c_cc[VTIME]=1; //  0.1s  timeout  on  read
    options.c_cc[VMIN]=48; //  min  buffer  to  tinmeout = 48 bytes,  which is much longer  than any  signal  we're likely to  see
    
    tcsetattr(sfd, TCSANOW, &options);
    
    return sfd;
}; // OpenSerialPort



/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                             TILT Functions                                  %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

/**
 *     @function: TiltReadReg()
 *
 *    Polls the appropiate register, processes returned data and returns them to
 *    the appropiate function by reference.
 *
 *     @param uint8_t reg   -       The register on the HMC6343 to be polled
 *     @param float& a      -       first value returned from the HMC
 *     @param float& b      -       second value returned from the HMC
 *     @param float& c      -       third value returned from the HMC
 *     @return              -       Returns a, b and c by passing them as a reference.
 
 
 The I2C slave address byte consists of the 7 most significant bits with the least significant bit zero filled. As described earlier, the default (factory) value is 0x32 and the legal 2I C bounded values are between 0x10 and 0xF6. This slave address is in EEPROM address 0x00. Users can change the slave address by writing to this location. Any address updates will become effective after the next power up or after a reset command.
 
 Note: The SparkFun Code used 0x19 = 0x32>>1
 
 
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



/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                           Utility Functions                                 %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

// Some power & CPU saving measures...
/* NOTE: Some things  to  place in the system config.txt file to  save power and turn off LEDs:
 
 // For /boot/config.txt
 # Disable Bluetooth  -- THIS WORKS!!!
 dtoverlay=pi3-disable-bt
 # Disable the PWR LED  -- THIS WORKS!!!
 dtparam=pwr_led_trigger=none
 dtparam=pwr_led_activelow=off
 # Disable the Activity LED  -- THIS WORKS!!!
 dtparam=act_led_trigger=none
 dtparam=act_led_activelow=off
 
 */
void SetSystemLowPower(void) {
    // Kill HDMI, 20mA
    system("sudo tvservice --off");
    // Kill USB, 200mA (also kills Ethernet)
    //     system("echo 0 | sudo tee /sys/devices/platform/soc/3f980000.usb/buspower >/dev/null");
    // Kill Ethernet
    system("sudo ifconfig eth0 down");
    // Kill WiFi, 50mA
    system("sudo ifconfig wlan0 down");
    // Kill  Bluetooth 40mA
    system("sudo systemctl disable bluetooth");
    system("sudo service bluetooth stop");
    // Kill the LEDs (Photons!!!)
    system("sudo sh -c 'echo none > /sys/class/leds/led0/trigger'");
    system("sudo sh -c 'echo none > /sys/class/leds/led1/trigger'");
    system("sudo sh -c 'echo 0 > /sys/class/leds/led1/brightness'");
    system("sudo sh -c 'echo 0 > /sys/class/leds/led0/brightness'");
    // Kill xinetd, the inet server daemon
    //    system("sudo apt-get purge xinetd");
    //    system("sudo apt-get autoremove");
}

void Sleep_ns(int nS) { // cross-platform sleep function
    struct timespec SleepyTime;
    SleepyTime.tv_sec  =  nS / ONE_BILLION;
    SleepyTime.tv_nsec =  nS % ONE_BILLION;
    nanosleep(&SleepyTime, NULL);
}


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                         Code Snippets to Record                             %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

/*
 *    omp_lock_t lBuffers; // Declare a Lock
 *    omp_init_lock(&lBuffers); //  Initialize  a Lock
 *    omp_set_lock(&lBuffers); //  Lock following  block...
 *    // locked code
 *    omp_unset_lock(&lBuffers);  //  Terminate Locked block
 *    //...
 *    omp_destroy_lock(&lck); // free resources used to maintain the Lock.
 */

/*
 #pragma omp flush // Essential for making sure flags are seen  across threads!!!
 #pragma omp atomic // next line, an assignment,  is atomic!
 */


/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %                                                                             %
 %                             Old Wiring Masks                                %
 %                                                                             %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 const uint16_t Lpins = {4, 17, 27, 22, 10, 9, 11, 5, 6, 13, 19, 26};

 static uint32_t Mask[12];
 for(int i=0;i<12;i++)  Mask[i] = ( 1 << Lpins[i] );

 ObsPhotonCount =    (((RawData&Mask[0])!=0)<<0)|
 (((RawData&Mask[1])!=0)<<1)|
 (((RawData&Mask[2])!=0)<<2)|
 (((RawData&Mask[3])!=0)<<3)|
 (((RawData&Mask[4])!=0)<<4)|
 (((RawData&Mask[5])!=0)<<5)|
 (((RawData&Mask[6])!=0)<<6)|
 (((RawData&Mask[7])!=0)<<7)|
 (((RawData&Mask[8])!=0)<<8)|
 (((RawData&Mask[9])!=0)<<9)|
 (((RawData&Mask[10])!=0)<<10)|
 (((RawData&Mask[11])!=0)<<11); // 48  Operations --  yuck!!! @ 1.4GHz that's 48 * .7ns ~ 34ns.  Yuck!


 */



