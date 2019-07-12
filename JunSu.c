#include <omp.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>
#include <sys/signal.h>
#include <sys/errno.h>
#include <wiringPi.h>

// ring buffer size: 16KB
#define BUF_SIZE (1<<14)


/* Typedef ******************************************************/
// global timer definitions
struct timer_def {
	int type;
	struct sigevent evp;
	struct itimerspec timeout;
};

struct tilt_def {
	uint16_t heading;
	uint16_t pitch;
	uint16_t roll;
};


/* Function Declartion ******************************************/
// Signal handlers
void count_photon();
void tx_serial();
//void terminate_elegantly();

// Timer setup for counter and serial tx
void set_counter_timer();
void set_tx_timer();

// High-level features
void log_data();
void count_photon_handler();

// Helper Fn
void time_add_val(struct timespec *t1, struct timespec *t2);

/* Global Variables **********************************************/
// ring buffer
uint16_t r_buf[BUF_SIZE];
uint16_t *r_start = r_buf;
uint16_t *r_end = r_buf;
uint16_t u_idx = 0;
struct tilt_def* cur_tilt;
uint16_t cur_count;

// counter and tx timerid
int clock_id = CLOCK_REALTIME;
timer_t c_timerid, t_timerid;

// global flags
uint8_t terminate_log = 0, terminate_count = 0;
uint8_t log_terminated = 0, count_terminated = 0;
uint8_t tx_now = 0;

/* MAIN **********************************************************/
int main() {
	if (wiringPiSetup() == -1) return 1;
	pinMode(5, OUTPUT);

	// TODO: Wait until ON signal has been received
    #pragma omp parallel num_threads (3)
    {
        #pragma omp single nowait
        {
            count_photon_handler();
		}
		#pragma omp single nowait
		{
			log_data();
		}
		#pragma omp single
		{
			set_tx_timer();
			// Process incoming serial signal
			int i = 0;
			while (i < 5) { //!terminate) {
				sleep(1);
				/*if (tx_now) {
					// TODO: write data to serial
					printf("FISH!\n");
					tx_now = 0;
				}
				i++;*/
			}
			printf("1: terminate\n");
			terminate_count = 1;
			terminate_log = 1;

			while(!log_terminated || !count_terminated){}
			printf("1: terminated for real\n");
		}
    }
	printf("0:finished\n");
    return 0;
}


// photon counter handler
void count_photon_handler() {
	//set_counter_timer();
    printf("2: Hello\n");
	int i = 0;
	double usec;
	struct timespec c_start, c_end;
	while (!terminate_count) {
		clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &c_start);
		digitalWrite(5, !digitalRead(5));
		//TODO: count photon using GPIO read
		cur_count++;
		*r_end = u_idx;
		//r_end++;
		r_end = (uint16_t *)((uint32_t)r_buf + ((uint32_t)r_end - (uint32_t)r_buf + 2) % BUF_SIZE);
		*r_end = cur_count;
		r_end = (uint16_t *)((uint32_t)r_buf + ((uint32_t)r_end - (uint32_t)r_buf + 2) % BUF_SIZE);
		//r_end++;
		u_idx = (u_idx + 1) % BUF_SIZE;
		clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &c_end);
		usec = (c_end.tv_sec - c_start.tv_sec)*1e6 + (c_end.tv_nsec - c_start.tv_nsec)/1e3;
		while (usec < 100){
			clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &c_end);
			usec = (c_end.tv_sec - c_start.tv_sec)*1e6 + (c_end.tv_nsec - c_start.tv_nsec)/1e3;
		}
	}
	//timer_delete(c_timerid);
	printf("2: Bye \n");
	count_terminated = 1;
    return;
}


// Data logging handler
void log_data() {
	printf("3: Hello\n");
	/*char test_dat[1<<12]; //4kB dummy data
	memset(test_dat, '?', 1<<12); 
	for (int i = 0; i < 300; i++) {
		FILE * fp;
		fp = fopen("test.txt", "a");

		fwrite(test_dat, 1<<12, 1, fp);
		fclose(fp);

		// 4KB/4 = 1k data per second  --> write happens every
		// 10kHz / 1k samples = 10Hz expected write
		usleep(100000);
	}

	while (!terminate_log){}
	printf("3: Bye\n");
	return;*/
	uint32_t n = 1;
	FILE * fp;
	char *name;
	asprintf(&name, "test%d.bin",n); 
	fp = fopen(name, "a");

	while (!terminate_log) {
		// Handle the case when r_end is smaller than r_start by adding
		// BUF_SIZE and then taking the modulus
		uint32_t data_size = ((uint32_t) r_end + BUF_SIZE - (uint32_t) r_start) % BUF_SIZE;
		while ((data_size < (1 << 12)) && (!terminate_log)){
			data_size = ((uint32_t) r_end + BUF_SIZE - (uint32_t) r_start) % BUF_SIZE;
		}
		printf("data_size: %d\n", data_size);

		uint16_t *temp_end = (uint16_t*)((uint8_t *)r_buf + (((uint32_t)r_start - (uint32_t)r_buf + (1<<12)) % BUF_SIZE));
		// TODO: Take measurement of headings

		if (temp_end > r_start) {
			uint32_t size = (uint32_t)(temp_end-r_start);
			fwrite(r_start, 2, size, fp);
		} else {
			fwrite(r_start, 1, (BUF_SIZE-(uint32_t)(r_start - r_buf)*sizeof(uint16_t)), fp);
			fwrite(r_buf, 2, temp_end-r_buf, fp);
		}
		// TODO: write meta data
		// TODO: write heading data
		fflush(fp);
		r_start = temp_end;
	}
	fclose(fp);

	log_terminated = 1;
	printf("3:Bye\n");
}


// Signal handler for photon counter @ 10kHz
void count_photon(int signo) {
	switch(signo) {
		case SIGUSR1:
			digitalWrite(5, !digitalRead(5));
			//TODO: count photon using GPIO read
			cur_count++;
			*r_end = u_idx;
			//r_end++;
			r_end = (uint16_t *)((uint32_t)r_buf + ((uint32_t)r_end - (uint32_t)r_buf + 2) % BUF_SIZE);
			*r_end = cur_count;
			r_end = (uint16_t *)((uint32_t)r_buf + ((uint32_t)r_end - (uint32_t)r_buf + 2) % BUF_SIZE);
			//r_end++;
			u_idx = (u_idx + 1) % BUF_SIZE;
			//printf("%u", u_idx);
			break;
		case SIGINT:
			timer_delete(c_timerid);
			terminate_count = 1;
			terminate_log = 1;
			printf("bye timer\n");
		default:
			break;
	}
	return;
}


// Signal handler for tx serial communicaiton @ 1Hz
void tx_serial(int signo) {
	switch(signo) {
		case SIGUSR2:
			//TODO: Serial write
			tx_now = 1;
			break;
		default:
			break;
	}
	return;
}


// Adapted from
// www3.physnet.uni-hamburg.de/physnet/Tru64-Unix/HTML/APS33DTE/DOCU_007.HTM
void set_counter_timer() {
	// timer with 100us interval
	int status;
	struct timer_def timer_val = {TIMER_ABSTIME, {0, SIGUSR1}, {0, 100000}};
	struct timespec current_time;
	struct sigaction sig_act;
	sigset_t mask;

	// Initialize the sigaction structure for the handler
	sigemptyset(&mask);
	sig_act.sa_handler = (void *)count_photon;
	sig_act.sa_flags = 0;
	sigemptyset(&sig_act.sa_mask);

	// create timer instance
	timer_create(clock_id, &timer_val.evp, &c_timerid);
	sigaction(timer_val.evp.sigev_signo, &sig_act, 0);
	sigaction(SIGINT, &sig_act, NULL);

	// Set the time with interval
	clock_gettime(CLOCK_REALTIME, &current_time);
	time_add_val(&timer_val.timeout.it_value, &current_time);
	timer_settime(c_timerid, timer_val.type, &timer_val.timeout, NULL);
}


void set_tx_timer() {
	// timer with 1sec interval
	int status;
	struct timer_def timer_val = {TIMER_ABSTIME, {0, SIGUSR2}, {1, 0}};
	struct timespec current_time;
	struct sigaction sig_act;
	sigset_t mask;

	// Initialize the sigaction structure for the handler
	sigemptyset(&mask);
	sig_act.sa_handler = (void *)tx_serial;
	sig_act.sa_flags = 0;
	sigemptyset(&sig_act.sa_mask);

	// create timer instance
	timer_create(clock_id, &timer_val.evp, &t_timerid);
	sigaction(timer_val.evp.sigev_signo, &sig_act, 0);
	sigaction(SIGINT, &sig_act, NULL);

	// Set the time with interval
	clock_gettime(CLOCK_REALTIME, &current_time);
	time_add_val(&timer_val.timeout.it_value, &current_time);
	timer_settime(t_timerid, timer_val.type, &timer_val.timeout, NULL);
}


// Adds two time t1 and t2 appropriately
void time_add_val(struct timespec *t1, struct timespec *t2) {
	t1->tv_sec += t2->tv_sec;
	t1->tv_nsec += t2->tv_nsec;
	if(t1->tv_nsec < 0) {
		t1->tv_sec--;
		t1->tv_nsec += 1000000000;
	}
	if (t1->tv_nsec >= 1000000000) {
		t1->tv_sec++;
		t1->tv_nsec -=1000000000;
	}
}
