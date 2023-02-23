/* This is a very naive Reno implementation, shown as an example on how to develop a new congestion control algorithm with TCP-Linux.
 *
 * See a mini-tutorial about TCP-Linux at: http://netlab.caltech.edu/projects/ns2tcplinux/
 *
 */
#define NS_PROTOCOL "tcp_naive_reno.c"

#include "ns-linux-c.h"
#include "ns-linux-util.h"

static int alpha = 1;
static int beta = 2;
module_param(alpha, int, 0644);
MODULE_PARM_DESC(alpha, "AI increment size of window (in unit of pkt/round trip time)");
module_param(beta, int, 0644);
MODULE_PARM_DESC(beta, "MD decrement portion of window: every loss the window is reduced by a proportion of 1/beta");




// Abrar  
static int beta1_nom = 1;
static int beta1_denom = 10;
static int beta2_nom = 5;
static int beta2_denom = 100;
static int lambda_min = 1;
static int lampbda_max = 3;
static int cwnd_loss = -1;
static int cwnd_degraded = -1;
//static int cwnd_size = -1;

// end 
/* opencwnd */

void tcp_naive_reno_cong_avoid(struct tcp_sock* tp, u32 ack, u32 rtt, u32 in_flight, int flag)
{
	ack = ack;
	rtt = rtt;
	in_flight = in_flight;
	flag = flag;
	// calculating gapCurrent 
	int gap_current = max(cwnd_loss - tp->snd_cwnd, 1U);
	gap_current = gap_current * gap_current;  
	int gap_total = max(cwnd_loss - cwnd_degraded, 1U);
	gap_total = gap_total * gap_total; 
	int lambda = (gap_current * lampbda_max) / gap_total;
	if (lambda < lambda_min) lambda = lambda_min;

	int root = 1;
	int i; 
	for ( i = 1; i * i <= lambda; ++i) {
		root = i; 
	}

	
	lambda = root;
	int avg = (gap_current + gap_total) / 2;
	if (lambda - avg >= lampbda_max && avg > 0 ) {
	 	lambda = lambda - avg;
	 	avg = (avg * 95) / 100;
	}

	

//	int x = tp->snd_cwnd;
	

	alpha = max(1U, lambda / tp->snd_cwnd);
	//printf("%d %d %d\n", lambda, x, alpha);
	//printf(" %d\n ", alpha);
	//printf(" alpha is updated\n");
	
	if (tp->snd_cwnd < tp->snd_ssthresh) {
		tcp_slow_start(tp);
	}
	else {
		if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
			tp->snd_cwnd += alpha;
			tp->snd_cwnd_cnt = 0;
			if (tp->snd_cwnd > tp->snd_cwnd_clamp)
				tp->snd_cwnd = tp->snd_cwnd_clamp;
		}
		else {
			tp->snd_cwnd_cnt += alpha;
		}
	}
}

/* ssthreshold should be half of the congestion window after a loss */
u32 tcp_naive_reno_ssthresh(struct tcp_sock* tp)
{
	//int reduction = tp->snd_cwnd / beta;
	//return max(tp->snd_cwnd - reduction, 2U);
	cwnd_loss = tp->snd_cwnd;
	int reduction = 0;
	if (tp->snd_cwnd < tp->snd_ssthresh) {
		if (beta1_denom != 0)
			reduction = (tp->snd_cwnd * beta1_nom) / beta1_denom;
	}
	else {
		if (beta2_denom != 0)
			reduction = (tp->snd_cwnd * beta2_nom) / beta2_denom;

	}
	cwnd_degraded = tp->snd_cwnd - reduction;
	tp->snd_cwnd = cwnd_degraded;
	//printf(" modification done \n");
	return max(cwnd_degraded - 1, 2U);

}


/* congestion window should be equal to the slow start threshold (after slow start threshold set to half of cwnd before loss). */
u32 tcp_naive_reno_min_cwnd(const struct tcp_sock* tp)
{
	return tp->snd_ssthresh;
}

static struct tcp_congestion_ops tcp_naive_reno = {
		.name = "agileSD",
		.ssthresh = tcp_naive_reno_ssthresh,
		.cong_avoid = tcp_naive_reno_cong_avoid,
		.min_cwnd = tcp_naive_reno_min_cwnd
};

int tcp_naive_reno_register(void)
{
	tcp_register_congestion_control(&tcp_naive_reno);
	return 0;
}
module_init(tcp_naive_reno_register);


