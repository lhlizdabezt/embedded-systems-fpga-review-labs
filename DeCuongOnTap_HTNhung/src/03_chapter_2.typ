#import "../config.typ": callout, note, tbl, cellhead, cell, cellleft

= QUY TRÌNH THIẾT KẾ MỘT HỆ THỐNG NHÚNG DÙNG SoPC

== Quan điểm tổng thể

Một hệ thống nhúng dùng SoPC luôn được phân thành hai nửa song song: nửa *phần cứng* được tổng hợp xuống FPGA dưới dạng cấu hình bitstream, và nửa *phần mềm* chạy trên CPU mềm (Nios II) bên trong FPGA. Hai nửa này gặp nhau ở "biên giới" là không gian địa chỉ ánh xạ I/O: phần cứng quy định Slave nào nằm ở base address nào, phần mềm sử dụng đúng các base address đó để đọc/ghi thanh ghi.

Vì vậy, quy trình thiết kế cũng có hai luồng. Luồng phần cứng dùng Quartus Prime kết hợp với Qsys (Platform Designer) để xếp đặt CPU, IP và bộ nhớ. Luồng phần mềm dùng Nios II Software Build Tools (Eclipse) để viết chương trình C, build BSP từ hệ thống Qsys vừa sinh, và nạp lên CPU đã được tổng hợp. Khi sinh viên thay đổi hệ thống Qsys, BSP phải được sinh lại để các macro địa chỉ phần mềm khớp với phần cứng.

#callout([Nguyên tắc bám đề cương], [
  Đề cương yêu cầu *nắm rõ ràng cách thiết kế phần cứng và chương trình phần mềm*. Vì vậy phần ôn tập sau đây trình bày song song hai luồng, và mỗi project ở chương sau cũng sẽ được mô tả theo cùng cấu trúc: phần cứng — phần mềm.
])

== Bước 1 — Khởi tạo project Quartus

Project Quartus là vỏ bọc ngoài cùng. Sinh viên chọn họ FPGA, đời chip, gói chân và đặt thư mục project. Tại bước này, Quartus chưa biết gì về Avalon Bus; nó chỉ biết một top-level entity sẽ được sinh ra. Vai trò chính của Quartus là *tổng hợp toàn bộ hệ thống* sau khi Qsys đã sinh ra IP, gắn các pin của top-level vào chân FPGA, và nạp file `.sof` xuống kit.

== Bước 2 — Xây dựng hệ thống trong Qsys (Platform Designer)

Đây là bước quan trọng nhất ở phía phần cứng. Trong Qsys, sinh viên thực hiện các thao tác sau:

- *Thêm CPU*: chọn Nios II/e (economy), Nios II/s (small) hoặc Nios II/f (fast) tùy yêu cầu. Cấu hình kích thước instruction cache, data cache, vị trí reset vector và exception vector — hai vector này phải nằm trong vùng nhớ hợp lệ (on-chip memory hoặc SDRAM).
- *Thêm bộ nhớ*: thường là on-chip memory để chứa code và stack cho các bài tập đơn giản; nếu chương trình lớn thì dùng SDRAM controller.
- *Thêm các IP I/O*: PIO cho LED/Switch/HEX; Timer cho đếm thời gian; UART/JTAG UART cho gỡ lỗi; DMAC cho truyền dữ liệu khối. Với bài HEX buổi 3, sáu LED bảy đoạn có thể được tạo bằng sáu PIO output riêng `HEX0` đến `HEX5`.
- *Thêm IP tự viết (nếu cần)*: được đóng gói qua Component Editor với tệp HDL và mô tả interface Avalon-MM Slave. Với bài HEX buổi 4, IP `HEX` có `chipselect`, `address[2:0]`, `write`, `writedata[31:0]` và sáu output conduit `hex0` ... `hex5`.
- *Kết nối Master – Slave*: nhấp vào lưới Connections để nối port Master của CPU với port Slave của các IP. Kết nối DMAC (vốn vừa là Master vừa là Slave) cần đặc biệt cẩn thận.
- *Gán base address*: dùng "Assign Base Addresses" để Qsys tự gán, hoặc tự nhập tay nếu cần địa chỉ cố định cho phần mềm có sẵn.
- *Gán IRQ*: với các IP có ngắt (Timer, UART), số IRQ phải duy nhất trên cùng một CPU.
- *Generate*: Qsys sinh ra một module Verilog/VHDL chứa toàn bộ hệ thống và đường Bus, kèm tệp `.qsys` và thư mục con chứa tất cả IP.

#tbl(
  table(
    columns: (5.0cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Mục]], [#cellhead[Lưu ý khi thi]],
    [Reset vector], [#cell[Trỏ vào on-chip memory hoặc SDRAM đã có chứa code; nếu trỏ sai, CPU không khởi động.]],
    [Exception vector], [#cell[Phải nằm trong vùng nhớ hợp lệ; thường để cùng vùng với reset vector.]],
    [Base address], [#cell[Mỗi Slave phải có dải địa chỉ riêng, không trùng. Sau khi gán xong, ghi nhớ để dùng trong phần mềm thông qua macro `_BASE` của BSP.]],
    [IRQ number], [#cell[Đặt sao cho mức ưu tiên hợp lý: thiết bị thời gian (Timer) thường có IRQ thấp, các IP cần đáp ứng nhanh để IRQ thấp hơn.]],
    [Clock domain], [#cell[Hệ thống đơn giản dùng một clock duy nhất; nếu có IP chạy clock khác, phải khai báo clock crossing.]],
  ),
  [Các chi tiết quan trọng cần kiểm tra trước khi Generate Qsys],
)

== Bước 3 — Tích hợp Qsys vào top-level và gán pin

Sau khi Qsys generate, sinh viên trở về Quartus và tạo một top-level (file `.v`/`.vhd` hoặc Block Diagram). Top-level này thực chất chỉ làm một việc: instantiate module Qsys vừa sinh, nối các port external (LED, Switch, HEX, clock, reset) ra chân vật lý. Bước gán pin được thực hiện qua Pin Planner và phụ thuộc vào sơ đồ kit thực tế (DE2-115, DE10-Lite, DE0-Nano, …). Sai pin là lỗi phổ biến và rất khó nhìn ra trên kit, vì hệ thống vẫn chạy bên trong nhưng không có hiển thị.

== Bước 4 — Tổng hợp và nạp bitstream

Quartus thực hiện Analysis & Synthesis, Fitter, Assembler, Timing Analyzer, sinh ra `.sof`. Sinh viên dùng Programmer để nạp `.sof` xuống FPGA qua JTAG. Khi cần lưu cấu hình vào EPCS để chạy không cần JTAG, có thể chuyển sang `.jic`. Trong phạm vi học phần, hầu hết bài thực hành chỉ cần nạp `.sof`.

== Bước 5 — Sinh BSP và viết chương trình phần mềm

Phía phần mềm dùng Nios II Software Build Tools for Eclipse (hoặc command-line). Quy trình điển hình:

+ Tạo Application và BSP from Template, chọn template "Hello World Small" hoặc "Hello World" tùy IP cần.
+ Trong BSP Editor, tắt các tính năng không cần thiết để giảm dung lượng (newlib reduced, không dùng C++, không dùng floating point).
+ Sinh BSP — Eclipse sinh `system.h` chứa các macro `*_BASE`, `*_IRQ`, `*_DATA_WIDTH`. Đây là cầu nối duy nhất giữa phần mềm và phần cứng.
+ Viết file C, dùng các macro `IORD_*` và `IOWR_*` của HAL hoặc gọi trực tiếp `*((volatile int*)BASE) = …`.
+ Build, nạp xuống CPU bằng "Run As → Nios II Hardware".

```c
// Ví dụ ghi/đọc thanh ghi PIO trong chương trình C
#include "system.h"
#include "altera_avalon_pio_regs.h"

int main(void) {
  unsigned int sw_value = IORD_ALTERA_AVALON_PIO_DATA(SW_BASE);
  IOWR_ALTERA_AVALON_PIO_DATA(LED_BASE, sw_value);
  return 0;
}
```

#note([
  Bất kỳ thay đổi nào của Qsys đều cần *sinh lại BSP* và *build lại Application*. Đây là lỗi rất hay gặp khi sinh viên đổi base address rồi quên sinh BSP, dẫn đến chương trình ghi vào địa chỉ sai và "không thấy gì xảy ra trên kit".
])

== Bước 6 — Kiểm thử và gỡ lỗi

Việc kiểm thử nên đi từ đơn giản đến phức tạp. Trước hết, kiểm tra xem CPU đã chạy chưa bằng cách `printf` ra JTAG UART. Sau đó kiểm tra từng IP riêng lẻ: LED có sáng đúng giá trị không, Switch có đọc đúng không, HEX có hiển thị đúng không. Cuối cùng mới kết hợp toàn bộ logic. Khi gặp lỗi, có ba điểm cần soi:

- *Phần cứng Qsys*: kết nối Master – Slave có đúng không, IRQ có trùng không.
- *Pin assignment*: chân external có nối đúng vào kit không.
- *Phần mềm*: có dùng đúng macro `_BASE` từ `system.h` không, có quên sinh lại BSP không.

== Luồng riêng cho bài Custom IP HEX của thầy

File `Custome_IP_hex.pdf` nhấn mạnh một chuỗi thao tác thực hành rất cụ thể cho buổi 4. Khi vấn đáp, sinh viên nên kể được luồng này theo đúng thứ tự thay vì chỉ nói chung chung "tạo IP rồi chạy":

+ Viết module Verilog `HEX` với các port `iClk`, `iRst_n`, `iChipSelect`, `iAddress[2:0]`, `iWrite`, `iWriteData[31:0]`, `oHex0` ... `oHex5`.
+ Mở Component Editor, thêm file HDL, ánh xạ signal type: `chipselect`, `address`, `write`, `writedata`, `clk`, `reset_n`, và sáu output `conduit_end`.
+ Thêm component `hex_0` vào Platform Designer, nối `clock_sink`, `reset_sink`, nối Avalon-MM Slave của `hex_0` với data master của Nios II, export conduit `hex`.
+ Generate HDL, sau đó chọn *Generate Testbench System* nếu cần mô phỏng.
+ Sinh BSP lại để `system.h` có macro `HEX_0_BASE`, rồi viết C dùng `IOWR(HEX_0_BASE, index, digit)`.
+ Nếu chạy mô phỏng, thêm các tín hiệu vào waveform và dùng lệnh `run 500 ms` để quan sát.

#callout([Điểm phân biệt buổi 3 và buổi 4], [
  Buổi 3 dùng sáu PIO có sẵn, phần mềm tự ghi mã đoạn active-low cho từng HEX. Buổi 4 dùng một custom IP duy nhất, phần mềm ghi chữ số 0 đến 9 vào offset 0 đến 5, còn HDL trong IP tự giải mã ra sáu ngõ `oHex`.
])

== Quan hệ giữa file phần cứng và file phần mềm

Một điểm dễ mất điểm khi vấn đáp là không nói được file nào sinh ra từ bước nào. Trong SoPC, mỗi file có vai trò riêng, không nên gom chung thành "Quartus sinh hết".

#tbl(
  table(
    columns: (4.0cm, 3.6cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Thành phần]], [#cellhead[Sinh/tạo ở đâu]], [#cellhead[Vai trò khi chạy hệ thống]],
    [`.qsys`], [#cell[Platform Designer]], [#cell[Lưu cấu hình hệ thống: CPU, memory, PIO, Timer, DMAC, địa chỉ, IRQ, kết nối Master-Slave.]],
    [Module Qsys `.v`/`.vhd`], [#cell[Generate HDL trong Qsys]], [#cell[Là khối phần cứng tổng hợp xuống FPGA, chứa Avalon interconnect và các IP.]],
    [Top-level HDL], [#cell[Người thiết kế viết hoặc dùng schematic]], [#cell[Instantiate hệ thống Qsys và nối port external ra clock, reset, LED, SW, HEX.]],
    [`.qsf`], [#cell[Quartus project]], [#cell[Chứa pin assignment, clock constraint, file source được thêm vào project.]],
    [`.sof`], [#cell[Quartus Assembler]], [#cell[Bitstream nạp xuống FPGA qua JTAG. Nếu thiếu bước này, phần cứng mới chưa tồn tại trên kit.]],
    [`system.h`], [#cell[BSP Generator]], [#cell[Chứa macro địa chỉ và IRQ để chương trình C truy cập đúng phần cứng.]],
    [`.elf`], [#cell[Nios II SBT/Eclipse]], [#cell[Chương trình phần mềm nạp vào CPU Nios II sau khi FPGA đã có phần cứng tương ứng.]],
  ),
  [Các file quan trọng trong luồng thiết kế SoPC],
)

#callout([Câu nói an toàn khi mô tả luồng build], [
  Luồng đúng là: thiết kế Qsys và top-level trước, compile Quartus để nạp `.sof`, sau đó sinh BSP từ phần cứng mới, build application để có `.elf`, cuối cùng nạp `.elf` lên CPU Nios II. Nếu đổi Qsys nhưng chỉ build lại C thì chương trình vẫn đang chạy trên phần cứng hoặc địa chỉ cũ.
])

== Checklist trước khi bấm Generate và Compile

Trước khi Generate Qsys, nên kiểm tra theo danh sách sau. Đây là các lỗi nhỏ nhưng thường làm mất rất nhiều thời gian trong phòng lab.

#tbl(
  table(
    columns: (4.2cm, 1fr, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Mục kiểm tra]], [#cellhead[Câu hỏi tự kiểm]], [#cellhead[Hậu quả nếu sai]],
    [Clock/reset], [#cell[Tất cả IP có nối cùng clock và reset phù hợp chưa? Reset active-high hay active-low?]], [#cell[CPU không chạy, Timer không đếm, IP tự viết giữ trạng thái sai.]],
    [Memory cho CPU], [#cell[Instruction master và data master của Nios II có nối đến bộ nhớ chứa code chưa?]], [#cell[Nạp `.elf` được nhưng CPU không fetch lệnh đúng.]],
    [Reset/exception vector], [#cell[Hai vector có trỏ vào on-chip memory hoặc SDRAM hợp lệ không?]], [#cell[CPU treo ngay sau reset hoặc không xử lý được ngắt.]],
    [Base address], [#cell[Các Slave có dải địa chỉ không trùng nhau không?]], [#cell[CPU ghi một IP nhưng IP khác bị chọn, kết quả quan sát sai.]],
    [IRQ], [#cell[Mỗi IP phát ngắt có số IRQ riêng và đã nối vào interrupt receiver của CPU chưa?]], [#cell[ISR không bao giờ chạy hoặc chạy sai nguồn ngắt.]],
    [Export port], [#cell[PIO/Custom IP cần ra chân kit đã export chưa? Tên port có rõ ràng không?]], [#cell[Compile được nhưng top-level không có tín hiệu để nối ra LED/SW/HEX.]],
    [Pin Planner], [#cell[Tên port top-level có đúng với bảng chân kit không?]], [#cell[Mạch bên trong đúng nhưng hiển thị ngoài kit không đúng.]],
  ),
  [Checklist lỗi phần cứng thường gặp],
)

== Cách debug theo triệu chứng

Khi hệ thống không chạy, nên debug theo triệu chứng quan sát được thay vì sửa mò. Bảng sau giúp khoanh vùng nhanh.

#tbl(
  table(
    columns: (4.0cm, 1fr, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Triệu chứng]], [#cellhead[Nguyên nhân có khả năng cao]], [#cellhead[Cách kiểm tra]],
    [Không in được `printf`], [#cell[JTAG UART chưa thêm, CPU chưa chạy, reset vector sai, chưa nạp `.sof`.]], [#cell[Nạp lại `.sof`, kiểm tra JTAG UART trong Qsys, thử template Hello World.]],
    [LED/HEX không đổi], [#cell[Sai base address, quên sinh BSP, sai pin, PIO chưa export.]], [#cell[Mở `system.h` xem macro `_BASE`, dùng `printf` in giá trị đang ghi, kiểm tra Pin Planner.]],
    [Đọc Switch luôn bằng 0], [#cell[PIO input chưa nối port ngoài, sai hướng PIO, sai pin.]], [#cell[Kiểm tra cấu hình PIO là input, port đã export và nối trong top-level.]],
    [Timer ngắt liên tục], [#cell[Quên xóa cờ timeout trong ISR hoặc period quá nhỏ.]], [#cell[Trong ISR ghi 0 vào `STATUS`, in biến đếm ngắt để xem tần suất.]],
    [ISR không chạy], [#cell[Chưa enable interrupt trong Timer, chưa đăng ký ISR, IRQ chưa nối hoặc sai macro IRQ.]], [#cell[Kiểm tra control register, `alt_ic_isr_register`, `TIMER_IRQ` trong `system.h`.]],
    [DMA không xong], [#cell[Sai địa chỉ nguồn/đích, sai length, chưa prepare kênh RX trước TX, vùng nhớ không cho DMAC truy cập.]], [#cell[In địa chỉ buffer, kiểm tra alignment, thử length nhỏ trước.]],
  ),
  [Khoanh vùng lỗi theo triệu chứng khi chạy trên kit],
)

== Biên giới phần cứng - phần mềm trong chương trình C

Trong phần mềm C, các macro trong `system.h` không phải là "biến" bình thường mà là địa chỉ phần cứng. Khi gọi `IOWR_32DIRECT(BASE, OFFSET, DATA)`, CPU phát một giao tác ghi trên Avalon Bus. Khi gọi `IORD_32DIRECT(BASE, OFFSET)`, CPU phát một giao tác đọc và đợi dữ liệu trả về. Từ góc nhìn C, đó chỉ là một dòng lệnh; từ góc nhìn phần cứng, đó là đầy đủ chuỗi Master - Bus - Slave.

```c
// Hai cách truy cập cùng một thanh ghi Avalon-MM
IOWR_32DIRECT(MY_IP_BASE, 0x0, 12);        // Ghi thanh ghi offset 0
int value = IORD_32DIRECT(MY_IP_BASE, 0x4); // Đọc thanh ghi offset 4

// Dạng con trỏ volatile tương đương
volatile unsigned int *reg0 = (volatile unsigned int *)(MY_IP_BASE + 0x0);
*reg0 = 12;
```

#note([
  Từ khóa `volatile` rất quan trọng khi truy cập thanh ghi phần cứng bằng con trỏ. Nếu không có `volatile`, compiler có thể tối ưu bỏ lần đọc/ghi vì tưởng đó là vùng nhớ bình thường, trong khi thực tế mỗi lần đọc/ghi đều tạo giao tác trên Bus.
])

== Tóm tắt quy trình

#tbl(
  table(
    columns: (1.35cm, 5.8cm, 1fr),
    align: (x, y) => if y == 0 or x == 0 { center } else { left },
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Bước]], [#cellhead[Tên]], [#cellhead[Đầu ra]],
    [#align(center)[1]], [#cellleft[Khởi tạo Quartus project]], [#cellleft[File `.qpf` cùng cấu hình họ FPGA.]],
    [#align(center)[2]], [#cellleft[Thiết kế hệ thống Qsys]], [#cellleft[Module hệ thống Avalon, file `.qsys`, danh sách Slave và base address.]],
    [#align(center)[3]], [#cellleft[Top-level và gán pin]], [#cellleft[Top-level instantiate hệ thống Qsys; bảng pin assignment khớp kit.]],
    [#align(center)[4]], [#cellleft[Tổng hợp và nạp]], [#cellleft[File `.sof` được nạp vào FPGA qua JTAG.]],
    [#align(center)[5]], [#cellleft[Sinh BSP và viết phần mềm]], [#cellleft[`system.h`, ứng dụng C đã build, file `.elf` chạy trên Nios II.]],
    [#align(center)[6]], [#cellleft[Kiểm thử và gỡ lỗi]], [#cellleft[Hệ thống chạy đúng yêu cầu, kết quả quan sát được trên kit.]],
  ),
  [Sáu bước thiết kế hệ thống nhúng dùng SoPC],
)

== Câu hỏi ôn tập gợi ý

#note([
  + Liệt kê sáu bước thiết kế hệ thống nhúng dùng SoPC. Bước nào là bước "biên giới" giữa phần cứng và phần mềm?
  + Vai trò của Qsys (Platform Designer) là gì? Khi nào cần Generate lại Qsys?
  + Tệp `system.h` được sinh ra từ đâu, chứa thông tin gì, dùng làm gì trong phần mềm?
  + Khi đổi base address của một Slave trong Qsys, cần làm gì ở phía phần mềm để chương trình hoạt động trở lại?
  + Tại sao reset vector và exception vector phải trỏ vào vùng nhớ hợp lệ?
])
