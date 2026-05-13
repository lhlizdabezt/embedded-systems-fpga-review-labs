#include <stdio.h>
#include "system.h"
#include "io.h"
#include "unistd.h"

const unsigned char seg7[10] = {
    0x40, 0x79, 0x24, 0x30, 0x19,
    0x12, 0x02, 0x78, 0x00, 0x10
};

void update_display(void)
{
    unsigned int s = IORD(SEC_REG_0_BASE,  0);
    unsigned int m = IORD(MIN_REG_0_BASE,  0);
    unsigned int h = IORD(HOUR_REG_0_BASE, 0);

    IOWR(HEX_0_BASE, 0, seg7[s % 10]);
    IOWR(HEX_0_BASE, 1, seg7[s / 10]);
    IOWR(HEX_0_BASE, 2, seg7[m % 10]);
    IOWR(HEX_0_BASE, 3, seg7[m / 10]);
    IOWR(HEX_0_BASE, 4, seg7[h % 10]);
    IOWR(HEX_0_BASE, 5, seg7[h / 10]);
}

void adjust_time(void)
{
    static unsigned int mode_prev  = 0;
    static unsigned int val_prev   = 0xFFFFFFFF;
    static unsigned int mode_stable_count = 0;

    unsigned int sw   = IORD(SWITCHES_0_BASE, 0);
    unsigned int mode = (sw >> 8) & 0x3;

    /* Đếm số lần đọc liên tiếp cùng mode */
    if (mode != mode_prev)
    {
        mode_prev          = mode;
        mode_stable_count  = 0;
        val_prev           = 0xFFFFFFFF;
        return;  /* chờ mode ổn định */
    }

    mode_stable_count++;

    /* Chỉ xử lý sau khi mode ổn định 5 lần liên tiếp (~5ms) */
    if (mode_stable_count < 5) return;

    if (mode == 0x0) return;  /* chạy bình thường */

    /* Tách BCD */
    unsigned int high   = (sw >> 4) & 0xF;
    unsigned int low    =  sw       & 0xF;
    unsigned int val    = high * 10 + low;
    unsigned int sw_low8 = sw & 0xFF;

    if (sw_low8 != val_prev)
    {
        val_prev = sw_low8;

        if (mode == 0x1)
        {
            unsigned int s = val;
            if (s > 59) s = 59;
            IOWR(SEC_REG_0_BASE, 0, s);
        }
        else if (mode == 0x2)
        {
            unsigned int m = val;
            if (m > 59) m = 59;
            IOWR(MIN_REG_0_BASE, 0, m);
        }
        else if (mode == 0x3)
        {
            unsigned int h = val;
            if (h > 23) h = 23;
            IOWR(HOUR_REG_0_BASE, 0, h);
        }
    }
}

void check_reset_key(void)
{
    static unsigned int key_prev = 1;

    unsigned int key = IORD(KEY_READER_0_BASE, 0) & 0x1;

    if (key == 0 && key_prev == 1)
    {
        IOWR(SEC_REG_0_BASE,  0, 0);
        IOWR(MIN_REG_0_BASE,  0, 0);
        IOWR(HOUR_REG_0_BASE, 0, 0);
        printf("Reset!\n");
    }

    key_prev = key;
}

int main(void)
{
    printf("=== Dong ho SoC - project2 (usleep, no timer) ===\n");

    IOWR(SEC_REG_0_BASE,  0, 0);
    IOWR(MIN_REG_0_BASE,  0, 0);
    IOWR(HOUR_REG_0_BASE, 0, 0);

    update_display();

    unsigned int ms_count = 0;

    while (1)
    {
        check_reset_key();
        adjust_time();
        update_display();

        usleep(1000);  /* 1 usleep duy nhất mỗi vòng */
        ms_count++;

        if (ms_count >= 1000)
        {
            ms_count = 0;

            unsigned int sw   = IORD(SWITCHES_0_BASE, 0);
            unsigned int mode = (sw >> 8) & 0x3;

            if (mode == 0x0)
            {
                unsigned int s = IORD(SEC_REG_0_BASE,  0);
                unsigned int m = IORD(MIN_REG_0_BASE,  0);
                unsigned int h = IORD(HOUR_REG_0_BASE, 0);

                s++;
                if (s >= 60) { s = 0; m++; }
                if (m >= 60) { m = 0; h++; }
                if (h >= 24)   h = 0;

                IOWR(SEC_REG_0_BASE,  0, s);
                IOWR(MIN_REG_0_BASE,  0, m);
                IOWR(HOUR_REG_0_BASE, 0, h);
            }
        }
    }

    return 0;
}
