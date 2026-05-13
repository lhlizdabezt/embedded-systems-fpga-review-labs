#include <stdio.h>
#include "system.h"
#include "io.h"
#include "altera_avalon_timer_regs.h"
#include "sys/alt_irq.h"

/* Mảng mã 7 đoạn active-low
 * IP HEX của bạn chỉ lấy [6:0], nên 0x40, 0x79... là ổn
 */
const unsigned char seg7[10] = {
    0x40, // 0
    0x79, // 1
    0x24, // 2
    0x30, // 3
    0x19, // 4
    0x12, // 5
    0x02, // 6
    0x78, // 7
    0x00, // 8
    0x10  // 9
};

volatile unsigned int g_sec  = 0;
volatile unsigned int g_min  = 0;
volatile unsigned int g_hour = 0;

/* Cờ báo đã đủ 1 giây */
volatile unsigned int tick_1s = 0;

/* Ghi 1 chữ số ra HEX
 * offset 0 = HEX0, 1 = HEX1, ..., 5 = HEX5
 */
void write_hex(unsigned int offset, unsigned int digit)
{
    IOWR(HEX_0_0_BASE, offset, (unsigned int)seg7[digit]);
}

/* Cập nhật toàn bộ 6 HEX */
void update_display(void)
{
    write_hex(0, g_sec  % 10);   /* HEX0: giây đơn vị */
    write_hex(1, g_sec  / 10);   /* HEX1: giây chục   */

    write_hex(2, g_min  % 10);   /* HEX2: phút đơn vị */
    write_hex(3, g_min  / 10);   /* HEX3: phút chục   */

    write_hex(4, g_hour % 10);   /* HEX4: giờ đơn vị  */
    write_hex(5, g_hour / 10);   /* HEX5: giờ chục    */
}

/* Hàm tăng thời gian lên 1 giây */
void clock_tick(void)
{
    g_sec++;

    if (g_sec >= 60) {
        g_sec = 0;
        g_min++;
    }

    if (g_min >= 60) {
        g_min = 0;
        g_hour++;
    }

    if (g_hour >= 24) {
        g_hour = 0;
    }
}

/* Khởi tạo Timer tạo ngắt mỗi 1 giây */
void timer_init(void)
{
    unsigned int period = 50000000 - 1;  /* 1 giây với CLOCK_50 = 50 MHz */

    /* Stop Timer trước khi cấu hình */
    IOWR_ALTERA_AVALON_TIMER_CONTROL(
        TIMER_0_BASE,
        ALTERA_AVALON_TIMER_CONTROL_STOP_MSK
    );

    /* Ghi chu kỳ đếm 32 bit vào periodl và periodh */
    IOWR_ALTERA_AVALON_TIMER_PERIODL(
        TIMER_0_BASE,
        period & 0xFFFF
    );

    IOWR_ALTERA_AVALON_TIMER_PERIODH(
        TIMER_0_BASE,
        (period >> 16) & 0xFFFF
    );

    /* Xóa cờ timeout cũ nếu có */
    IOWR_ALTERA_AVALON_TIMER_STATUS(
        TIMER_0_BASE,
        ALTERA_AVALON_TIMER_STATUS_TO_MSK
    );

    /* Bật chế độ continuous, bật interrupt, start timer */
    IOWR_ALTERA_AVALON_TIMER_CONTROL(
        TIMER_0_BASE,
        ALTERA_AVALON_TIMER_CONTROL_CONT_MSK |
        ALTERA_AVALON_TIMER_CONTROL_ITO_MSK  |
        ALTERA_AVALON_TIMER_CONTROL_START_MSK
    );
}

/* ISR Timer: cứ mỗi 1 giây sẽ nhảy vào đây */
void timer_isr(void *context)
{
    tick_1s = 1;

    /* Xóa cờ ngắt TO */
    IOWR_ALTERA_AVALON_TIMER_STATUS(
        TIMER_0_BASE,
        ALTERA_AVALON_TIMER_STATUS_TO_MSK
    );
}

int main(void)
{
    printf("=== Dong ho SoC - HEX IP + Switch IP + Timer 1s ===\n");

    update_display();

    timer_init();

    alt_ic_isr_register(
        TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID,
        TIMER_0_IRQ,
        timer_isr,
        NULL,
NULL
    );

    while (1)
    {
        unsigned int sw   = (unsigned int)IORD(SWITCHES_0_BASE, 0);
        unsigned int mode = (sw >> 8) & 0x3;   /* SW[9:8] */

        if (mode == 0)
        {
            /* Chế độ 00: đồng hồ chạy bình thường */
            if (tick_1s)
            {
                tick_1s = 0;

                clock_tick();
                update_display();
            }
        }
        else
        {
            /* Chế độ thiết lập: đồng hồ dừng */
            tick_1s = 0;

            if (mode == 1)
            {
                /* SW[9:8] = 01: chỉnh GIÂY bằng SW[5:0] */
                unsigned int val = sw & 0x3F;

                if (val > 59) {
                    val = 59;
                }

                g_sec = val;
            }
            else if (mode == 2)
            {
                /* SW[9:8] = 10: chỉnh PHÚT bằng SW[5:0] */
                unsigned int val = sw & 0x3F;

                if (val > 59) {
                    val = 59;
                }

                g_min = val;
            }
            else
            {
                /* SW[9:8] = 11: chỉnh GIỜ bằng SW[4:0] */
                unsigned int val = sw & 0x1F;

                if (val > 23) {
                    val = 23;
                }

                g_hour = val;
            }

            update_display();
        }
    }

    return 0;
}
