#import "../config.typ": callout, note, tbl, cellhead, cell

= BỐN PROJECT THỰC HÀNH

== Hướng dẫn ôn theo project

Bốn project trong đề cương đều có chung một bài toán "đồng hồ giờ – phút – giây" hoặc biến thể, nhưng mỗi project tập trung vào một khía cạnh khác nhau. Sự khác biệt nằm ở cách giải quyết hai bài toán phụ: (1) đếm thời gian một giây, và (2) tổ chức thanh ghi điều khiển giờ/phút/giây. Cách phân chia này giúp người học so sánh dễ dàng các kỹ thuật: dùng IP có sẵn so với tự viết IP, dùng vòng lặp CPU so với dùng Timer, dùng truyền byte/byte so với dùng DMAC.

#callout([Khung trả lời cho mỗi project], [
  Khi vấn đáp một project, sinh viên nên trình bày theo bốn mục cố định: (1) sơ đồ khối phần cứng trong Qsys; (2) bảng địa chỉ và mục đích từng Slave; (3) thuật toán cập nhật giờ/phút/giây; (4) ý chính của chương trình C. Khung này áp dụng đồng nhất cho cả bốn project, chỉ thay đổi chi tiết bên trong.
])

== Prj1 — Làm quen với HEX bằng sáu IP PIO và `usleep`

=== Mục tiêu phần cứng

Project đầu tiên trong slide của giảng viên là bài "làm quen với HEX trên DE10 Standard". Phần cứng chỉ dùng IP có sẵn trong Platform Designer: CPU Nios II, on-chip memory, JTAG UART và sáu khối PIO output tương ứng `HEX0` đến `HEX5`. Mỗi PIO là một Avalon-MM Slave riêng; CPU Nios II là Master duy nhất, phát lệnh ghi đến từng base address `HEX0_BASE`, `HEX1_BASE`, ..., `HEX5_BASE`.

Trên DE10 Standard, mỗi LED bảy đoạn dùng mã active-low. Vì vậy số 0 không ghi bằng giá trị nhị phân 0, mà ghi bằng mã đoạn tương ứng. Slide của thầy dùng bảng mã 8 bit gồm cả bit dấu chấm thập phân: 0 là `0xC0`, 1 là `0xF9`, 2 là `0xA4`, 3 là `0xB0`, 4 là `0x99`, 5 là `0x92`, 6 là `0x82`, 7 là `0xF8`, 8 là `0x80`, 9 là `0x90`.

#tbl(
  table(
    columns: (3.5cm, 3.0cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[IP]], [#cellhead[Vai trò]], [#cellhead[Mục đích]],
    [Nios II], [Master], [#cell[Chạy chương trình C, gọi `IOWR` để ghi mã LED bảy đoạn đến từng PIO.]],
    [On-chip memory], [Slave], [#cell[Chứa code, stack và data; reset vector và exception vector trỏ vào đây.]],
    [`HEX0` ... `HEX5` PIO], [Slave output], [#cell[Mỗi PIO xuất 7 hoặc 8 bit ra một LED bảy đoạn. Sáu PIO này được export ra top-level và gán chân đến `HEX0` ... `HEX5` của kit.]],
    [JTAG UART], [Slave], [#cell[Dùng `printf` để kiểm tra chương trình đã chạy trên Nios II.]],
  ),
  [Sơ đồ khối phần cứng cho Prj1],
)

=== Mã hiển thị và thứ tự các HEX

Phần mềm buổi 3 có hai ý chính. Thứ nhất là tạo mảng `hex_code[10]` để đổi chữ số thập phân sang mã LED bảy đoạn active-low. Thứ hai là ghi từng chữ số ra đúng vị trí HEX bằng `IOWR(BASE, 0, data)`. Theo slide ví dụ 12 giờ 38 phút 12 giây, thứ tự hiển thị là:

- `HEX0`: hàng đơn vị giây.
- `HEX1`: hàng chục giây.
- `HEX2`: hàng đơn vị phút.
- `HEX3`: hàng chục phút.
- `HEX4`: hàng đơn vị giờ.
- `HEX5`: hàng chục giờ.

```c
#include "io.h"
#include "system.h"
#include <unistd.h>

static const unsigned char hex_code[10] = {
  0xC0, // 0
  0xF9, // 1
  0xA4, // 2
  0xB0, // 3
  0x99, // 4
  0x92, // 5
  0x82, // 6
  0xF8, // 7
  0x80, // 8
  0x90  // 9
};

static void display_time(unsigned int hh, unsigned int mm, unsigned int ss) {
  IOWR(HEX0_BASE, 0, hex_code[ss % 10]);
  IOWR(HEX1_BASE, 0, hex_code[ss / 10]);
  IOWR(HEX2_BASE, 0, hex_code[mm % 10]);
  IOWR(HEX3_BASE, 0, hex_code[mm / 10]);
  IOWR(HEX4_BASE, 0, hex_code[hh % 10]);
  IOWR(HEX5_BASE, 0, hex_code[hh / 10]);
}

int main(void) {
  unsigned int hh = 0, mm = 0, ss = 0;

  while (1) {
    display_time(hh, mm, ss);
    usleep(1000000);
    if (++ss == 60) { ss = 0; if (++mm == 60) { mm = 0; if (++hh == 24) hh = 0; } }
  }
}
```

#note([
  Bản chất Prj1 là CPU tự làm mọi việc: đổi số sang mã bảy đoạn, ghi từng PIO và tạo mốc một giây bằng `usleep` hoặc delay phần mềm. Vì CPU bị chiếm trong lúc đợi nên đây vẫn là cách polling/busy-wait; Prj3 mới chuyển sang Timer để tạo mốc thời gian bằng phần cứng.
])

=== Chi tiết cần nắm thêm cho Prj1

Trong Prj1, phần cứng đơn giản nhưng phần mềm phải tự làm khá nhiều việc: tách giá trị giờ/phút/giây thành từng chữ số, đổi chữ số sang mã active-low và ghi đúng thứ tự `HEX0` đến `HEX5`. Nếu giảng viên hỏi sâu, cần nhấn mạnh rằng mỗi PIO chỉ nhận mã đoạn thô; PIO không biết giá trị đó là số nào.

#tbl(
  table(
    columns: (3.4cm, 1fr, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Chi tiết]], [#cellhead[Cần nói được]], [#cellhead[Lỗi dễ gặp]],
    [Mã active-low], [#cell[Bit 0 thường nghĩa là đoạn LED sáng; vì vậy mã số 0 là `0xC0`, không phải `0x00`.]], [#cell[Dùng mã active-high làm LED hiển thị sai hoặc đảo ngược.]],
    [Thứ tự digit], [#cell[`HEX0`, `HEX1` dành cho giây; `HEX2`, `HEX3` dành cho phút; `HEX4`, `HEX5` dành cho giờ.]], [#cell[Đảo hàng chục/hàng đơn vị khiến ví dụ 12:38:12 hiển thị sai vị trí.]],
    [Base address], [#cell[Mỗi PIO có một macro `_BASE` riêng trong `system.h`.]], [#cell[Copy nhầm `HEX0_BASE` cho cả sáu lần ghi.]],
    [`usleep`], [#cell[Tạo delay một giây ở phía phần mềm.]], [#cell[Không có timer hệ thống hoặc cấu hình BSP sai làm delay không đúng như mong muốn.]],
  ),
  [Các điểm thường bị hỏi sâu trong Prj1],
)

Ví dụ tách một giá trị thời gian thành hàng chục và hàng đơn vị:

```c
unsigned int sec_unit = ss % 10;
unsigned int sec_tens = ss / 10;
```

#callout([Ưu và nhược điểm của Prj1], [
  Ưu điểm là rất dễ nhìn thấy quan hệ CPU - Avalon Bus - PIO: mỗi lệnh `IOWR` tạo một giao tác ghi đến một Slave. Nhược điểm là phải dùng sáu PIO riêng, phần mềm phải tự mã hóa LED bảy đoạn và CPU vẫn bị chiếm bởi delay.
])

== Prj2 — Custom IP HEX điều khiển sáu LED bảy đoạn

=== Mục tiêu phần cứng

Theo file `Custome_IP_hex.pdf`, Prj2 tập trung vào việc tự viết một IP tên `HEX` để điều khiển trực tiếp sáu LED bảy đoạn. IP này được đóng gói thành một Avalon-MM Slave write-only có các tín hiệu chính:

- `iClk`, `iRst_n`: clock và reset active-low.
- `iChipSelect`: Bus chọn đúng Slave `hex_0`.
- `iAddress[2:0]`: chọn một trong sáu digit, thường dùng địa chỉ 0 đến 5.
- `iWrite`: yêu cầu ghi active-high theo khai báo trong Component Editor.
- `iWriteData[31:0]`: dữ liệu CPU ghi xuống; IP thường dùng vài bit thấp để lấy chữ số 0 đến 9.
- `oHex0` đến `oHex5`: sáu ngõ ra conduit, mỗi ngõ 7 bit ra LED bảy đoạn.

Điểm khác Prj1 là phần mềm không ghi mã đoạn thô cho từng PIO riêng nữa. Phần mềm chỉ ghi chữ số vào cùng một base address `HEX_0_BASE`, còn custom IP tự giải mã chữ số thành mã LED bảy đoạn và xuất ra `oHex0` ... `oHex5`.

#tbl(
  table(
    columns: (3.1cm, 2.4cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Thành phần]], [#cellhead[Loại interface]], [#cellhead[Mục đích]],
    [`avalon_slave_0`], [Avalon-MM Slave], [#cell[Nhận `chipselect`, `address`, `write`, `writedata` từ Bus. Không cần `read`/`readdata` nếu bài chỉ yêu cầu ghi hiển thị.]],
    [`clock_sink`], [Clock input], [#cell[Nối clock hệ thống `clk_0` cho logic đồng bộ trong IP.]],
    [`reset_sink`], [Reset input], [#cell[Nối reset active-low `iRst_n` để đưa sáu HEX về trạng thái xác định.]],
    [`conduit_end`], [External conduit], [#cell[Export sáu output `hex0` ... `hex5` ra top-level rồi gán chân đến LED bảy đoạn trên kit.]],
  ),
  [Các interface của custom IP HEX trong Component Editor],
)

=== Mã HDL khái quát của IP

Phần HDL cần hai khối rõ ràng. Khối thứ nhất là hàm đổi chữ số 0 đến 9 sang mã bảy đoạn active-low. Khối thứ hai là logic ghi đồng bộ: khi `iChipSelect && iWrite`, IP dùng `iAddress` để chọn `oHex0` ... `oHex5` và dùng `iWriteData[3:0]` làm chữ số cần hiển thị.

```verilog
module HEX(
  input        iClk,
  input        iRst_n,
  input        iChipSelect,
  input  [2:0] iAddress,
  input        iWrite,
  input [31:0] iWriteData,
  output reg [6:0] oHex0,
  output reg [6:0] oHex1,
  output reg [6:0] oHex2,
  output reg [6:0] oHex3,
  output reg [6:0] oHex4,
  output reg [6:0] oHex5
);

function [6:0] seg7;
  input [3:0] digit;
  begin
    case (digit)
      4'd0: seg7 = 7'b1000000;
      4'd1: seg7 = 7'b1111001;
      4'd2: seg7 = 7'b0100100;
      4'd3: seg7 = 7'b0110000;
      4'd4: seg7 = 7'b0011001;
      4'd5: seg7 = 7'b0010010;
      4'd6: seg7 = 7'b0000010;
      4'd7: seg7 = 7'b1111000;
      4'd8: seg7 = 7'b0000000;
      4'd9: seg7 = 7'b0010000;
      default: seg7 = 7'b1111111;
    endcase
  end
endfunction

always @(posedge iClk or negedge iRst_n) begin
  if (!iRst_n) begin
    oHex0 <= 7'b1111111;
    oHex1 <= 7'b1111111;
    oHex2 <= 7'b1111111;
    oHex3 <= 7'b1111111;
    oHex4 <= 7'b1111111;
    oHex5 <= 7'b1111111;
  end else if (iChipSelect && iWrite) begin
    case (iAddress)
      3'd0: oHex0 <= seg7(iWriteData[3:0]);
      3'd1: oHex1 <= seg7(iWriteData[3:0]);
      3'd2: oHex2 <= seg7(iWriteData[3:0]);
      3'd3: oHex3 <= seg7(iWriteData[3:0]);
      3'd4: oHex4 <= seg7(iWriteData[3:0]);
      3'd5: oHex5 <= seg7(iWriteData[3:0]);
      default: ;
    endcase
  end
end

endmodule
```

=== Phần mềm

Trong phần mềm, chỉ cần include `io.h` và `system.h`, sau đó gọi `IOWR(HEX_0_BASE, index, digit)`. Tham số `index` chọn digit cần ghi, còn `digit` là giá trị 0 đến 9. Đây là đúng tinh thần slide buổi 4: cùng một custom IP, một base address, sáu offset.

```c
#include "io.h"
#include "system.h"
#include <stdio.h>

int main(void) {
  printf("Hien thi len Hex hoan tat");

  while (1) {
    IOWR(HEX_0_BASE, 0, 0);
    IOWR(HEX_0_BASE, 1, 1);
    IOWR(HEX_0_BASE, 2, 2);
    IOWR(HEX_0_BASE, 3, 3);
    IOWR(HEX_0_BASE, 4, 4);
    IOWR(HEX_0_BASE, 5, 5);
  }
}
```

Nếu muốn dùng custom IP này để hiển thị đồng hồ như Prj1, phần mềm chỉ thay sáu giá trị 0..5 bằng chữ số của giờ/phút/giây:

```c
static void display_time_custom_ip(unsigned int hh, unsigned int mm, unsigned int ss) {
  IOWR(HEX_0_BASE, 0, ss % 10);
  IOWR(HEX_0_BASE, 1, ss / 10);
  IOWR(HEX_0_BASE, 2, mm % 10);
  IOWR(HEX_0_BASE, 3, mm / 10);
  IOWR(HEX_0_BASE, 4, hh % 10);
  IOWR(HEX_0_BASE, 5, hh / 10);
}
```

#callout([Tại sao tự viết IP], [
  Mục tiêu của Prj2 là chứng minh sinh viên hiểu cách *đóng gói một IP Avalon-MM Slave*: viết HDL, khai báo signal type trong Component Editor, export conduit ra top-level, kết nối CPU Master đến Slave `hex_0`, và truy cập IP từ C bằng macro `_BASE` trong `system.h`.
])

=== Đóng gói IP tự viết trong Component Editor

Khi tự viết IP, phần HDL mới chỉ là lõi logic. Để Platform Designer hiểu đây là một Avalon-MM Slave, sinh viên phải dùng Component Editor khai báo interface, ánh xạ tên port và đặt thông số dữ liệu. Slide buổi 4 thể hiện rõ bảng Signals: `iChipSelect` là `chipselect`, `iAddress` là `address` rộng 3 bit, `iWrite` là `write`, `iWriteData` là `writedata` rộng 32 bit; `oHex0` ... `oHex5` là các output conduit rộng 7 bit.

#tbl(
  table(
    columns: (3.8cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Mục trong Component Editor]], [#cellhead[Ý nghĩa]],
    [Files], [#cell[Thêm file Verilog chứa module `HEX`, kiểm tra tên module đúng với tên entity top.]],
    [Signals], [#cell[Ánh xạ `iChipSelect`, `iAddress`, `iWrite`, `iWriteData`, `iClk`, `iRst_n`, `oHex0` ... `oHex5` đúng signal type.]],
    [Interfaces], [#cell[Gom bốn tín hiệu bus thành `avalon_slave_0`, gom `iClk` thành `clock_sink`, gom `iRst_n` thành `reset_sink`, gom sáu output thành `conduit_end`.]],
    [Address width], [#cell[Dùng 3 bit vì cần chọn tối đa sáu vị trí HEX, tương ứng index 0 đến 5 trong `IOWR`.]],
    [Data width], [#cell[Dùng `writedata` 32 bit theo bus, nhưng IP chỉ cần vài bit thấp để nhận chữ số.]],
    [Export conduit], [#cell[Sáu output `hex0` ... `hex5` phải export ra hệ thống và nối ra chân vật lý của kit.]],
  ),
  [Các mục cần kiểm tra khi đóng gói IP tự viết],
)

=== Simulation và lỗi thường gặp trong buổi 4

Sau khi Generate HDL trong Platform Designer, slide yêu cầu chọn thêm *Generate Testbench System* để tạo môi trường mô phỏng. Khi mở ModelSim/Questa, sinh viên thêm các tín hiệu của IP vào waveform, chạy `run 500 ms` và quan sát `iAddress`, `iWrite`, `iWriteData`, `oHex0` ... `oHex5` thay đổi đúng theo lệnh `IOWR`.

#tbl(
  table(
    columns: (3.7cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Tình huống]], [#cellhead[Cách hiểu/cách xử lý]],
    [Không thấy `HEX_0_BASE`], [#cell[Chưa Generate hệ thống hoặc chưa sinh lại BSP. Mở `system.h` để kiểm tra tên macro đúng với instance `hex_0`.]],
    [Ghi `IOWR` nhưng HEX không đổi], [#cell[Kiểm tra `iChipSelect`, `iWrite`, `iAddress` trong waveform; kiểm tra conduit `hex` đã export và nối pin.]],
    [ModelSim báo không tìm thấy path], [#cell[Kiểm tra lại run configuration của Nios II/ModelSim và đường dẫn thư mục simulation/submodules theo slide sửa lỗi.]],
    [Chương trình C quá lớn], [#cell[Trong BSP Editor có thể bật `enable_small_c_library`, `enable_reduced_device_drivers`, `enable_sim_optimize` như slide gợi ý.]],
  ),
  [Các lỗi thực hành cần nhớ cho Prj2],
)

#note([
  Vì IP buổi 4 là write-only nên việc không có `readdata` không phải lỗi. Avalon cho phép một Slave chỉ khai báo các tín hiệu cần dùng. Điều quan trọng là `iWrite` trong slide là active-high, khác với các ví dụ manual cũ thường dùng tên `write_n` active-low.
])

=== So sánh Prj1 và Prj2

#tbl(
  table(
    columns: (3.0cm, 1fr, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Tiêu chí]], [#cellhead[Prj1]], [#cellhead[Prj2]],
    [Khối hiển thị], [#cell[Sáu PIO riêng `HEX0` ... `HEX5`; phần mềm ghi mã đoạn trực tiếp.]], [#cell[Một custom IP `hex_0`; phần mềm ghi chữ số, HDL tự giải mã ra mã đoạn.]],
    [Base address], [#cell[Mỗi HEX có một `_BASE` riêng.]], [#cell[Một `HEX_0_BASE`, địa chỉ nội bộ 0 đến 5 chọn digit.]],
    [Tín hiệu Avalon cần nhớ], [#cell[PIO là Slave có sẵn, sinh viên chủ yếu thao tác từ C.]], [#cell[Phải tự khai báo `chipselect`, `address`, `write`, `writedata` và conduit output.]],
    [Điểm thi chính], [#cell[Biết dùng IP sẵn có và hiểu mỗi `IOWR` là một giao tác ghi.]], [#cell[Biết tự viết, đóng gói, tích hợp, mô phỏng và gọi IP từ phần mềm.]],
  ),
  [So sánh Prj1 và Prj2],
)

== Prj3 — Đồng hồ dùng Timer cho phần delay một giây

=== Mục tiêu phần cứng

Prj3 thay vòng lặp CPU bằng IP Timer của Altera. Timer được cấu hình ngắt mỗi 1 giây (đặt period = `clock_freq` để Timer đếm xuống và roll-over đúng 1 Hz). Khi Timer hết khoảng đếm, nó phát IRQ về CPU; ISR cập nhật biến giây/phút/giờ và xuất ra HEX. CPU không cần busy-wait nữa, có thể vào trạng thái idle hoặc làm việc khác giữa hai ngắt.

#tbl(
  table(
    columns: (3.5cm, 3.0cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[IP]], [#cellhead[Vai trò]], [#cellhead[Mục đích]],
    [Nios II], [Master], [#cell[Chạy chương trình C, xử lý ngắt từ Timer.]],
    [On-chip memory], [Slave], [#cell[Code, stack, exception vector.]],
    [Interval Timer], [Slave + IRQ], [#cell[Sinh ngắt mỗi 1 giây để cập nhật giờ/phút/giây.]],
    [PIO\_HEX], [Slave (output)], [#cell[Hiển thị thời gian.]],
    [PIO\_SW], [Slave (input)], [#cell[Đọc thiết lập ban đầu.]],
  ),
  [Sơ đồ khối phần cứng cho Prj3],
)

=== Phần mềm dùng ISR

```c
#include "system.h"
#include "altera_avalon_timer_regs.h"
#include "sys/alt_irq.h"

static volatile unsigned int hh, mm, ss;

static void timer_isr(void *context) {
  // Xóa cờ TO của Timer để cho phép ngắt tiếp theo.
  IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_BASE, 0);
  if (++ss == 60) { ss = 0; if (++mm == 60) { mm = 0; if (++hh == 24) hh = 0; } }
}

int main(void) {
  // Cấu hình period 1 Hz, bật continuous + interrupt + start.
  IOWR_ALTERA_AVALON_TIMER_PERIODL(TIMER_BASE, (TIMER_FREQ - 1) & 0xFFFF);
  IOWR_ALTERA_AVALON_TIMER_PERIODH(TIMER_BASE, ((TIMER_FREQ - 1) >> 16) & 0xFFFF);
  IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_BASE, 0x7);
  alt_ic_isr_register(TIMER_IRQ_INTERRUPT_CONTROLLER_ID, TIMER_IRQ, timer_isr, 0, 0);

  while (1) {
    unsigned int hex = (hh << 12) | (mm << 6) | ss;
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_HEX_BASE, hex);
  }
}
```

#note([
  Trong ISR phải xóa cờ TO (timeout) bằng cách ghi 0 vào thanh ghi `STATUS` của Timer. Quên bước này khiến ngắt sẽ liên tục được tái phát, treo CPU.
])

=== Các thanh ghi Timer cần nhớ

IP Interval Timer của Altera là một Slave có nhiều thanh ghi điều khiển. Khi vấn đáp, không cần thuộc mọi bit, nhưng nên nắm được bốn nhóm thanh ghi chính:

#tbl(
  table(
    columns: (3.0cm, 3.0cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Thanh ghi]], [#cellhead[Hướng]], [#cellhead[Ý nghĩa]],
    [`STATUS`], [Read/Write], [#cell[Chứa cờ timeout `TO`. ISR phải xóa cờ này sau khi xử lý ngắt.]],
    [`CONTROL`], [Read/Write], [#cell[Bật interrupt (`ITO`), chế độ continuous (`CONT`), start/stop Timer. Giá trị thường dùng để chạy liên tục có ngắt là `0x7`.]],
    [`PERIODL`], [Write], [#cell[16 bit thấp của chu kỳ đếm. Với clock 50 MHz, period 1 giây thường là 50,000,000 - 1.]],
    [`PERIODH`], [Write], [#cell[16 bit cao của chu kỳ đếm. Phải ghi đủ cả low và high nếu period lớn hơn 16 bit.]],
    [`SNAPL`/`SNAPH`], [Read], [#cell[Đọc giá trị đếm hiện tại khi cần đo thời gian hoặc debug, không bắt buộc trong bài đồng hồ đơn giản.]],
  ),
  [Các thanh ghi Timer thường dùng trong Prj3],
)

=== Trình tự cấu hình ngắt Timer

Thứ tự cấu hình nên làm rõ vì nếu đảo lung tung, chương trình có thể nhận ngắt trước khi biến và ISR sẵn sàng.

+ Khai báo biến thời gian dùng trong ISR là `volatile`.
+ Đọc Switch để lấy giờ/phút/giây ban đầu, chuẩn hóa về khoảng hợp lệ.
+ Ghi `PERIODL` và `PERIODH` để đặt chu kỳ 1 giây.
+ Đăng ký ISR bằng `alt_ic_isr_register(...)`.
+ Xóa cờ timeout cũ trong `STATUS`.
+ Ghi `CONTROL` để bật `ITO`, `CONT` và `START`.
+ Trong vòng `while(1)`, main chỉ hiển thị hoặc xử lý việc phụ; phần tăng giây nằm trong ISR.

#callout([Vì sao biến trong ISR phải volatile], [
  Biến `hh`, `mm`, `ss` được thay đổi trong ISR nhưng lại được đọc ở hàm `main`. Nếu không khai báo `volatile`, compiler có thể giữ giá trị cũ trong thanh ghi CPU và main không nhìn thấy cập nhật mới. Đây là lỗi phần mềm nhưng hậu quả quan sát giống như Timer không chạy.
])

=== So sánh Prj1 và Prj3 về thời gian

#tbl(
  table(
    columns: (3.2cm, 1fr, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Tiêu chí]], [#cellhead[Delay CPU trong Prj1]], [#cellhead[Timer IRQ trong Prj3]],
    [Độ chính xác], [#cell[Phụ thuộc vòng lặp, compiler, tần số CPU.]], [#cell[Phụ thuộc Timer phần cứng, ổn định hơn nhiều.]],
    [Tải CPU], [#cell[CPU bận trong lúc delay.]], [#cell[CPU rảnh giữa hai ngắt.]],
    [Khả năng mở rộng], [#cell[Khó xử lý sự kiện khác đúng lúc.]], [#cell[Dễ thêm nút nhấn, UART hoặc xử lý nền.]],
    [Độ phức tạp], [#cell[Dễ viết, ít cấu hình.]], [#cell[Cần biết IRQ, ISR, thanh ghi Timer.]],
  ),
  [Ưu nhược điểm của hai cách tạo mốc 1 giây],
)

== Prj4 — Hệ thống có dùng DMAC

=== Mục tiêu phần cứng

Prj4 không nhất thiết là một đồng hồ. Mục tiêu chính là minh họa khái niệm *DMA*: chuyển một khối dữ liệu từ vùng nhớ nguồn sang vùng nhớ đích (hoặc tới một thiết bị I/O) mà không cần CPU đọc/ghi từng byte. DMAC là một IP đặc biệt vì nó vừa là *Slave* để CPU đọc/ghi thanh ghi cấu hình, vừa là *Master* để tự sinh địa chỉ truy cập nguồn và đích.

Hệ thống điển hình gồm: CPU, on-chip memory chứa code, một vùng nhớ nguồn (có thể là on-chip memory thứ hai chứa dữ liệu mẫu), một vùng nhớ đích (on-chip memory hoặc PIO output cho LED/HEX), và DMAC. Khi CPU cấu hình DMAC, DMAC sẽ tự đọc nguồn và ghi đích cho đến khi xong khối dữ liệu.

#tbl(
  table(
    columns: (3.5cm, 3.0cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[IP]], [#cellhead[Vai trò]], [#cellhead[Mục đích]],
    [Nios II], [Master], [#cell[Cấu hình DMAC, chờ tín hiệu hoàn tất.]],
    [DMAC], [Master + Slave], [#cell[Slave để CPU ghi cấu hình; Master để tự đọc nguồn và ghi đích.]],
    [On-chip memory SRC], [Slave], [#cell[Vùng nguồn chứa dữ liệu mẫu cần chuyển.]],
    [On-chip memory DST hoặc PIO], [Slave], [#cell[Vùng đích nhận dữ liệu.]],
    [JTAG UART], [Slave], [#cell[`printf` để xác nhận DMA hoàn tất.]],
  ),
  [Sơ đồ khối phần cứng cho Prj4],
)

=== Trình tự chạy DMA điển hình

+ CPU ghi địa chỉ nguồn vào thanh ghi `DMA_SRC` của DMAC.
+ CPU ghi địa chỉ đích vào thanh ghi `DMA_DST`.
+ CPU ghi số byte cần chuyển vào thanh ghi `DMA_LEN`.
+ CPU ghi vào thanh ghi `DMA_CONTROL` để khởi động (bật RUN, chọn chiều, chế độ word/byte, có dùng ngắt khi xong hay không).
+ DMAC tự thực hiện vòng đọc nguồn → ghi đích, cho đến khi đủ số byte. Trong khi đó, DMAC đóng vai trò Master trên Bus.
+ Khi xong, DMAC đặt cờ DONE hoặc phát IRQ. CPU đọc kết quả ở vùng đích.

```c
// Khái quát đoạn cấu hình DMAC bằng macro của HAL Altera
#include "sys/alt_dma.h"
static volatile int dma_done = 0;
static void dma_done_callback(void *context, void *buffer) { dma_done = 1; }

void run_dma(void *src, void *dst, int len) {
  alt_dma_txchan tx = alt_dma_txchan_open("/dev/dma_0");
  alt_dma_rxchan rx = alt_dma_rxchan_open("/dev/dma_0");
  alt_dma_rxchan_prepare(rx, dst, len, dma_done_callback, NULL);
  alt_dma_txchan_send(tx, src, len, NULL, NULL);
  while (!dma_done) { }
}
```

#callout([Vì sao cần DMAC], [
  Khi cần chuyển một khối lớn dữ liệu, ví dụ buffer ảnh hoặc sample âm thanh, nếu để CPU làm `for` từng byte thì CPU bị chiếm hết cho phần truyền dữ liệu. DMAC giải phóng CPU bằng cách tự đảm nhiệm vòng đọc/ghi. Điểm thi chính là *DMAC vừa là Master vừa là Slave*, và quy trình *cấu hình – khởi động – chờ hoàn tất*.
])

=== DMAC vừa là Slave vừa là Master như thế nào?

Một cách giải thích rất dễ hiểu là chia quá trình DMA thành hai pha. Ở pha cấu hình, CPU là Master và DMAC là Slave: CPU ghi địa chỉ nguồn, địa chỉ đích, độ dài và bit start vào các thanh ghi DMAC. Ở pha truyền dữ liệu, DMAC trở thành Master: nó tự phát địa chỉ đọc đến Slave nguồn và địa chỉ ghi đến Slave đích. CPU không còn đọc/ghi từng byte nữa.

#tbl(
  table(
    columns: (3.2cm, 1fr, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Pha]], [#cellhead[Vai trò của CPU]], [#cellhead[Vai trò của DMAC]],
    [Cấu hình], [#cell[Master, ghi thanh ghi điều khiển của DMAC.]], [#cell[Slave, nhận thông số từ CPU.]],
    [Truyền dữ liệu], [#cell[Không trực tiếp truyền từng word; có thể polling hoặc chờ IRQ.]], [#cell[Master, tự đọc nguồn và ghi đích qua Avalon Bus.]],
    [Hoàn tất], [#cell[Đọc cờ DONE hoặc chạy ISR khi có IRQ.]], [#cell[Cập nhật trạng thái, phát IRQ nếu được bật.]],
  ),
  [Hai pha hoạt động của DMAC],
)

=== Các điểm cần chú ý khi dùng DMA

#tbl(
  table(
    columns: (3.5cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Vấn đề]], [#cellhead[Giải thích]],
    [Địa chỉ nguồn/đích], [#cell[Phải là địa chỉ mà DMAC truy cập được trên Avalon Bus. Không phải mọi địa chỉ con trỏ C đều phù hợp nếu vùng đó không nằm trong memory map của hệ thống.]],
    [Độ dài truyền], [#cell[Cần thống nhất đơn vị byte hay word. Một số API nhận số byte, trong khi người học dễ nhầm thành số phần tử.]],
    [Alignment], [#cell[Truyền word thường yêu cầu địa chỉ căn theo 2 hoặc 4 byte. Sai alignment có thể làm truyền chậm hoặc sai dữ liệu.]],
    [Cache], [#cell[Nếu CPU có data cache, dữ liệu CPU thấy và dữ liệu DMAC thấy có thể không đồng nhất. Cần flush/invalidate cache hoặc dùng vùng nhớ không cache khi bài có yêu cầu.]],
    [Polling và IRQ], [#cell[Polling đơn giản nhưng CPU vẫn phải chờ; IRQ tốt hơn khi muốn CPU làm việc khác trong lúc DMA chạy.]],
    [Arbitration], [#cell[DMAC và CPU có thể cùng tranh truy cập memory. Avalon Bus phải trọng tài để quyết định Master nào được phục vụ.]],
  ),
  [Các rủi ro thực tế khi làm Prj4],
)

=== Cách kiểm chứng DMA đã chạy đúng

Khi debug Prj4, không nên truyền ngay một buffer lớn. Nên bắt đầu bằng một mảng nhỏ có mẫu dễ nhận ra, ví dụ `0x11, 0x22, 0x33, 0x44`. Sau khi DMA xong, CPU in vùng đích ra JTAG UART hoặc xuất một vài byte ra LED/HEX. Nếu vùng đích đúng, mới tăng dần độ dài truyền.

```c
unsigned char src[4] = {0x11, 0x22, 0x33, 0x44};
unsigned char dst[4] = {0x00, 0x00, 0x00, 0x00};

run_dma(src, dst, 4);
printf("%02x %02x %02x %02x\n", dst[0], dst[1], dst[2], dst[3]);
```

#note([
  Nếu dùng DMA để đưa dữ liệu ra PIO/HEX, cần nhớ PIO là thiết bị I/O chứ không phải bộ nhớ liên tục. Vì vậy cách cấu hình tăng địa chỉ đích hay giữ cố định địa chỉ đích phải phù hợp với loại thiết bị nhận.
])

== So sánh nhanh bốn project

#tbl(
  table(
    columns: (1.5cm, 1fr, 1fr, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Prj]], [#cellhead[Cách đếm 1 giây]], [#cellhead[Khối điều khiển hiển thị]], [#cellhead[Điểm trọng tâm]],
    [Prj1], [#cell[`usleep` hoặc delay phần mềm trong CPU.]], [#cell[Sáu IP PIO riêng cho `HEX0` ... `HEX5`; phần mềm ghi mã seven-segment active-low.]], [#cell[Làm quen với pipeline Platform Designer → BSP → C → HEX.]],
    [Prj2], [#cell[Có thể dùng lại thuật toán phần mềm của Prj1.]], [#cell[Một custom IP `hex_0`, địa chỉ 0..5 chọn digit, `writedata` chứa chữ số.]], [#cell[Kỹ thuật viết, đóng gói, tích hợp và mô phỏng một Avalon-MM Slave write-only.]],
    [Prj3], [#cell[Timer phát ngắt 1 Hz; CPU cập nhật biến trong ISR.]], [#cell[PIO HEX vẫn từ thư viện.]], [#cell[Cơ chế ngắt (IRQ, ISR), giải phóng CPU khỏi busy-wait.]],
    [Prj4], [#cell[Không tập trung đếm giây; tập trung truyền khối dữ liệu.]], [#cell[Vùng đích là on-chip memory hoặc PIO output.]], [#cell[DMAC là Master + Slave; quy trình cấu hình và chờ hoàn tất.]],
  ),
  [So sánh nhanh đặc điểm bốn project trong đề cương],
)

== Mẫu trả lời vấn đáp cho từng project

#callout([Prj1], [
  Prj1 dùng CPU Nios II làm Master, sáu PIO `HEX0` ... `HEX5` làm Slave. CPU tự đổi chữ số sang mã seven-segment active-low rồi ghi từng PIO bằng `IOWR(HEXx_BASE, 0, data)`. Trọng tâm là biết dùng IP có sẵn, biết thứ tự digit giờ/phút/giây và hiểu mỗi lần `IOWR` là một giao tác ghi Avalon-MM.
])

#callout([Prj2], [
  Prj2 thay sáu PIO bằng một custom IP `HEX` đóng vai trò Avalon-MM Slave write-only. CPU ghi `IOWR(HEX_0_BASE, index, digit)`, trong đó `index` chọn `oHex0` ... `oHex5`, còn `digit` là số 0 đến 9. Trọng tâm là biết viết HDL giải mã `iAddress`, dùng `iChipSelect`, `iWrite`, `iWriteData`, export sáu conduit output, rồi đóng gói IP bằng Component Editor.
])

#callout([Prj3], [
  Prj3 dùng Interval Timer để tạo mốc 1 giây bằng ngắt, thay cho delay CPU. Timer là Slave có IRQ; CPU cấu hình period, đăng ký ISR, bật interrupt và trong ISR xóa cờ timeout rồi cập nhật thời gian. Trọng tâm là hiểu cơ chế IRQ/ISR và lý do Timer chính xác hơn busy-wait.
])

#callout([Prj4], [
  Prj4 dùng DMAC để truyền khối dữ liệu. CPU cấu hình DMAC thông qua các thanh ghi nên lúc này DMAC là Slave; khi bắt đầu truyền, DMAC tự sinh giao tác đọc/ghi trên Bus nên nó là Master. Trọng tâm là quy trình cấu hình nguồn, đích, độ dài, start, chờ DONE/IRQ và hiểu arbitration khi có nhiều Master.
])

== Câu hỏi ôn tập gợi ý

#note([
  + Vẽ sơ đồ khối phần cứng cho từng project. Tại mỗi project, chỉ rõ Master, Slave và lý do chọn IP đó.
  + Trong Prj1, vì sao phải dùng bảng `hex_code[10]` thay vì ghi thẳng số 0 đến 9 ra PIO?
  + Trong Prj2, vì sao custom IP chỉ cần `write`/`writedata` mà không nhất thiết phải có `read`/`readdata`?
  + Trong Prj3, ISR của Timer cần làm gì để đảm bảo ngắt tiếp theo vẫn hoạt động bình thường?
  + Trong Prj4, DMAC vừa là Master vừa là Slave nghĩa là gì? Nêu các thanh ghi cấu hình tối thiểu cho một lượt DMA.
  + So sánh ưu nhược điểm của Prj1 và Prj3 trong việc đếm giây.
  + Nếu Prj2 ghi `IOWR(HEX_0_BASE, 0, 0)` nhưng `HEX0` không đổi, nên kiểm tra `iChipSelect`, `iWrite`, `iAddress`, `iWriteData`, conduit export hay pin assignment trước?
  + Nếu Prj3 Timer có ngắt nhưng HEX không đổi, lỗi có thể nằm ở ISR, biến `volatile`, hay PIO output? Hãy nêu cách khoanh vùng.
])
