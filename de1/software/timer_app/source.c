#include <stdio.h>
#include <unistd.h>
#include "system.h"                   // Nơi chứa các BASE_ADDRESS của Qsys
#include "altera_avalon_pio_regs.h"   // Thư viện hỗ trợ IORD và IOWR

// Bảng mã LED 7 đoạn (Anode chung)
const int hex_table[10] = {0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78, 0x00, 0x10};

// Hàm cập nhật màn hình
void update_display(int h, int m, int s) {
    IOWR_ALTERA_AVALON_PIO_DATA(HEX0_BASE, hex_table[s % 10]);
    IOWR_ALTERA_AVALON_PIO_DATA(HEX1_BASE, hex_table[s / 10]);

    IOWR_ALTERA_AVALON_PIO_DATA(HEX2_BASE, hex_table[m % 10]);
    IOWR_ALTERA_AVALON_PIO_DATA(HEX3_BASE, hex_table[m / 10]);

    IOWR_ALTERA_AVALON_PIO_DATA(HEX4_BASE, hex_table[h % 10]);
    IOWR_ALTERA_AVALON_PIO_DATA(HEX5_BASE, hex_table[h / 10]);
}

int main() {
    int hours = 0, minutes = 0, seconds = 0;
    int switches;
    int mode, value;

    //printf("Yo! Nios II Digital Clock is running...\n");

    while (1) {
        // Đọc trạng thái 10 Switch (Tên macro này lấy từ system.h)
        switches = IORD_ALTERA_AVALON_PIO_DATA(SWITCH1_BASE);

        mode = switches & 0x03;         // SW[1:0] là Mode
        value = (switches >> 2) & 0xFF; // SW[9:2] là Value

        if (mode == 0) {
            // MODE 0 (Chạy bình thường)
            usleep(1000000);
            seconds++;
            if (seconds >= 60) {
                seconds = 0; minutes++;
                if (minutes >= 60) {
                    minutes = 0; hours++;
                    if (hours >= 24) hours = 0;
                }
            }
        } else {
            // CÁC CHẾ ĐỘ SETUP
            if (mode == 1) seconds = (value > 59) ? 59 : value;
            else if (mode == 2) minutes = (value > 59) ? 59 : value;
            else if (mode == 3) hours = (value > 23) ? 23 : value;
            usleep(50000);
        }

        update_display(hours, minutes, seconds);
    }
    return 0;
}
