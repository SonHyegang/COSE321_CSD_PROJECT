// ------------------------------------------
//  Author: Hyegang Son
//          Computer Science & Engineering
//          College of Informatics, Korea Univ.
//          2019320121
//  Date:   2023.06.04.
// ------------------------------------------
/*//---------------------------------------------------------------------------------
	[Note]
	1. PT(Private Timer) Setup
		http://esca.korea.ac.kr/teaching/cose321_CSD/lectures/CSD-Lec6-Timers.pptx
		333MHz = 333X2^20Hz = 349,175,808 Hz

		(PRESCALER_value+1)X(Load_value+1)/PERIPHCLK = 0.001s
		(PRESCALER_value+1)X(Load_value+1) = 333*2^10

		Online divisor calculator :https://docinfo.kr/gcd-calculator/
		PRESCALER_value+1 = 111 	=> PRESCALER_value = 110
		Load_value+1 = 3,072 		=> Load_value = 3,071 = 0xBFF

	[Reference]
	1. Lab_interrupt_private_timer, uart_hello_using_macro
	2. Assignment_about the impact of cache on performacne
	3. Lecture note_Lec2 ARM Instructions, Lec5 UART, Lec9 Interrupts
	4. https://developer.arm.com/documentation/ddi0406/b/System-Level-Architecture/Virtual-Memory-System-Architecture--VMSA-/CP15-registers-for-a-VMSA-implementation/c12--Vector-Base-Address-Register--VBAR-
*///---------------------------------------------------------------------------------

#include "csd_zynq_peripherals.h"
#include "uart_init.s"

.extern task1_c, task2_c, task3_c
#define	TIMER_INITIAL	0xBFF

.align 5

.extern uart_print
csd_vector_table:
	b .
	b .
	b .
	b .
	b .
	b .
	b csd_IRQ_ISR
	b .

.global main
main:


// 1. System Initialization in supervisor mode

	// Disable interrupt: CPSR'I = 1
	cpsID 	i
	cps		#0x13	// supervisor mode
// ---------------------------
// 1-1. Stack setup for each mode - Begin
// ---------------------------
	cps 	#0x12	   	       // IRQ mode
	ldr		r13,=irq_stack_top // Stack pointer setup for IRQ mode

	cps 	#0x13		          // supervisor mode
	ldr		r13,=svc_stack_top // Stack pointer setup for SVC mode
// ---------------------------
// 1-1. Stack setup for each mode - End
// ---------------------------


// ---------------------------
// 1-2. Generic Interrupt Controller (GIC) setup - Begin
// 1-3. Private Timer setup - Begin
// ---------------------------
	// Set VBAR (Vector Base Address Register) to my vector table
	ldr     r0, =csd_vector_table
	mcr     p15, 0, r0, c12, c0, 0
	dsb
	isb

	// CPU Interface ID Register
	ldr 	r0, =GICC_IIDR
	ldr 	r3, [r0]

	// CPU Controller Type Register
	ldr 	r0, =GICD_TYPER
	ldr 	r3, [r0]

	// CPU Binary Pointer Register
	ldr 	r0, =GICC_BPR
	ldr 	r3, [r0]

	// Distributor Control Register
	ldr 	r0, =GICD_CTLR
	ldr 	r1, [r0]
	mov 	r2, #1       // Enable
	orr 	r1, r1, r2
	str 	r1, [r0]
	ldr 	r3, [r0]

	 // Interrupt Set-Enable Register 0
	ldr 	r0, =GICD_ISENABLER0
	ldr 	r1, [r0]
	mov 	r2, #1 << 29   // Enable #29 (Private Timer)
	orr 	r1, r1, r2
	str 	r1, [r0]
	ldr 	r3, [r0]

	// According to specifications,
	// Cortex-A9 supports 5-bit version of priority format [7:3] in secure world
	// ( 0 -> 8 -> 16 -> 24...)

	// Interrupt Priority Register #7
	ldr 	r0, =GICD_PRIOR7
	ldr 	r1, [r0]
	mov 	r2, #0x10 << 8    // Priority 16 for ID# 29 (Private Timer)
	orr 	r1, r1, r2
	str 	r1, [r0]
	ldr		r3, [r0]

	// CPU Interface Control Register
	ldr 	r0, =GICC_CTLR
	ldr 	r1, [r0]
	mov 	r2, #1        // Enable
	orr 	r1, r1, r2
	str 	r1, [r0]
	ldr 	r3, [r0]

 	// CPU Interface Interrupt Priority Mask Register
	ldr 	r0, =GICC_PMR
	ldr 	r1, [r0]
	mov 	r2, #0xFF     // Lowest
	orr 	r1, r1, r2
	str 	r1, [r0]
	ldr 	r3, [r0]
// ---------------------------
// 1-2. Generic Interrupt Controller (GIC) setup - End
// 1-3. Private Timer setup - End
// ---------------------------


// ----------------------------
// 1-4. UART configuration - Begin
// ----------------------------
	UART_init
// ----------------------------
// 1-4. UART configuration - End
// ----------------------------


// ----------------------------
// 1-5. TCB(Task Control Block) setup for each user program - Begin
// 1-6. Stack setup for each user program - Begin
// ----------------------------
	// TCB settings for task1
	ldr 	sp, =task1_TCB_pointer
	ldr		lr, =round_robin_scheduler	// After executing a task, the OS scheduler selects the next task to be performed.

	cps		#0x1f	// Sys mode
	ldr 	sp, =usr_task1_stack_top
	cps		#0x13	// Supervisor mode

	stm		sp, {r0-r14}^
	mrs 	r0, spsr
	bic		r0, r0, #0x80	// Modify SPSR's mode bits
	stmdb	sp, {r0, lr}


	// TCB settings for task2
	ldr 	sp, =task2_TCB_pointer
	ldr		lr, =round_robin_scheduler

	cps		#0x1f 	// Sys mode
	ldr 	sp, =usr_task2_stack_top
	cps		#0x13 	// Supervisor mode

	stm		sp, {r0-r14}^
	mrs 	r0, spsr
	bic		r0, r0, #0x80
	stmdb	sp, {r0, lr}


	// TCB settings for task3
	ldr 	sp, =task3_TCB_pointer
	ldr		lr, =round_robin_scheduler

	cps		#0x1f /// Sys mode
	ldr 	sp, =usr_task3_stack_top
	cps		#0x13 // Supervisor mode

	stm		sp, {r0-r14}^
	mrs 	r0, spsr
	bic		r0, r0, #0x80
	stmdb	sp, {r0, lr}
// ----------------------------
// 1-5. TCB(Task Control Block) setup for each user program - End
// 1-6. Stack setup for each user program - End
// ----------------------------


// 2. Task Scheduling in IRQ mode
	cps		#0x12	// IRQ mode
// ---------------------------
// 2-1. Private Timer setup - Begin
// ---------------------------
 	// Private Timer Load Register
	ldr 	r0, =PRIVATE_LOAD
 	ldr 	r1, =TIMER_INITIAL
 	str 	r1, [r0]

 	// Private Timer Control Register
  	ldr 	r0, =PRIVATE_CONTROL
 	mov 	r1, #110 << 8   // Prescalar
 	orr 	r1, r1, #7     // IRQ Enable, Auto-Reload, Timer Enable
 	str 	r1, [r0]

 	# Enable interrupt
	cpsIE	i
// ----------------------------
// 2-1. Private Timer setup - End
// ----------------------------


// ---------------------------
// 2-2. Task scheduling - Begin
// ---------------------------
 	cps		#0x1f	// Sys mode
 	ldr 	sp, =usr_task1_stack_top

 	cps		#0x12	// IRQ mode
 	ldr		sp, =task1_TCB_pointer

 	cps		#0x13 	// supervisor mode
 	ldr		r0, =current_task_ID	// Initialize task ID
 	mov		r1, #1
 	str		r1, [r0]





// 3. Application programs run in user mode
	cps		#0x10	// User mode

round_robin_scheduler:
	ldr		r0, =current_task_ID
	ldr		r1, [r0]

	cmp		r1, #1
	bleq	task1_c
	cmp		r1, #2
	bleq	task2_c
	cmp		r1, #3
	bleq	task3_c

	b round_robin_scheduler



// ----------------------------
// Interrupt Service Routines (ISRs) - Begin
// ----------------------------
csd_IRQ_ISR:

	stm		sp, {r0-r14}^
	mrs		r0, spsr
	stmdb	sp,	{r0, lr}


 	// Interrupt Ack
  	ldr r0, =GICC_IAR
	ldr r3, [r0]


 	ldr 	r0, =current_task_ID
	ldr		r1,	[r0]

	// Scheduling according to round robin policy
	add		r1, r1, #1
	cmp		r1, #4
	moveq	r1, #1
	str		r1, [r0]

	cmp		r1, #1
	ldreq	sp, =task1_TCB_pointer
	cmp		r1, #2
	ldreq	sp, =task2_TCB_pointer
	cmp		r1, #3
	ldreq	sp, =task3_TCB_pointer


 	// Clear Interrupt Status bit
  	ldr 	r0, =PRIVATE_STATUS
  	mov 	r1, #1
	str 	r1, [r0]

 	// End-of-Interrupt
  	ldr 	r0, =GICC_EOIR
	str 	r3, [r0]

	ldmdb	sp, {r0, lr}
	msr		spsr, r0
	ldm		sp, {r0-r14}^
	subs 	pc, lr, #4

// ----------------------------
// Interrupt Service Routines (ISRs) - End
// ----------------------------

.data
.align 4

irq_stack:     		.space 1024
irq_stack_top:
fiq_stack:     		.space 1024
fiq_stack_top:
svc_stack:     		.space 1024
svc_stack_top:

task1_TCB:			.space 512
task1_TCB_pointer:
task1_TCB_:			.space 512
task2_TCB:			.space 512
task2_TCB_pointer:
task2_TCB_:			.space 512
task3_TCB:			.space 512
task3_TCB_pointer:
task3_TCB_:			.space 512

usr_task1_stack:	.space 1024
usr_task1_stack_top:
usr_task2_stack:	.space 1024
usr_task2_stack_top:
usr_task3_stack:	.space 1024
usr_task3_stack_top:

current_task_ID:	.space 4
