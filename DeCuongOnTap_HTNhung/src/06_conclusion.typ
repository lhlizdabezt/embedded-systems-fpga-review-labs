#import "../config.typ": callout, note, tbl, cellhead, cell

= TỔNG KẾT VÀ CHIẾN LƯỢC ÔN TẬP

== Bản đồ kiến thức theo bốn nội dung

Bốn nội dung đề cương không tách rời mà liên kết chặt chẽ. Khái niệm Master, Bus, Slave (Chương 1) là nền tảng để hiểu mọi project; quy trình thiết kế SoPC (Chương 2) là khung làm việc chung cho cả bốn project (Chương 3); và các giản đồ thời gian (Chương 4) chính là hình ảnh hóa cụ thể của những gì đã trừu tượng hóa ở Chương 1. Khi vấn đáp, sinh viên nên trả lời theo trình tự "khái niệm → quy trình → ví dụ project → giản đồ" để câu trả lời có nền lý thuyết và minh họa cụ thể.

#tbl(
  table(
    columns: (3.0cm, 1fr, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Nội dung]], [#cellhead[Cốt lõi]], [#cellhead[Liên kết với phần khác]],
    [Master/Bus/Slave], [#cell[Vai trò, tín hiệu, chu kỳ chờ.]], [#cell[Là nền tảng để đọc giản đồ thời gian.]],
    [Quy trình SoPC], [#cell[Sáu bước; biên giới phần cứng – phần mềm là `system.h`.]], [#cell[Áp dụng cho cả bốn project; mọi đổi Qsys đều cần sinh BSP lại.]],
    [Bốn project], [#cell[PIO HEX, Custom IP HEX, Timer/IRQ, DMAC.]], [#cell[Mỗi project minh họa một khía cạnh của Bus: Slave có sẵn, Slave do mình viết, Slave + IRQ, Master + Slave kết hợp.]],
    [Hình 1 – Hình 11], [#cell[Read/Write, fixed wait, waitrequest, Master vs. Slave Port.]], [#cell[Là minh họa thời gian của các tín hiệu đã giới thiệu ở Chương 1.]],
  ),
  [Bản đồ kiến thức tổng quát],
)

== Lộ trình ôn tập gợi ý

Để ôn tập hiệu quả với thời gian có hạn, có thể chia làm bốn buổi ngắn:

+ *Buổi 1 — Khái niệm và tín hiệu*: đọc lại Chương 1 và Chương 4 song song. Mục tiêu là gọi tên đúng các tín hiệu Avalon và biết ai phát ai nhận.
+ *Buổi 2 — Quy trình thiết kế*: đọc Chương 2; thử kể lại bằng lời sáu bước, lưu ý điểm "biên giới" `system.h`.
+ *Buổi 3 — Bốn project*: đọc Chương 3, vẽ lại sơ đồ khối phần cứng cho từng project trên giấy nháp; viết lại đoạn pseudo-code cho phần phần mềm.
+ *Buổi 4 — Giản đồ thời gian*: lấy đề cương gốc của giảng viên, đối chiếu từng Hình 1 – Hình 11 với phần phân tích trong Chương 4, tự đánh dấu cột thời gian nào ứng với "address valid", "readdata valid", "waitrequest = 1".

#callout([Mẹo trả lời câu hỏi giản đồ], [
  Khi giảng viên đưa một giản đồ, đừng vội bắt đầu giải thích từ cột A. Đầu tiên xác định *Read hay Write*, *có waitrequest hay không*, *bao nhiêu giao tác*. Sau khi định danh đúng, nội dung phân tích từng cột sẽ đi theo khung quen thuộc đã có trong tài liệu.
])

== Những lỗi thường gặp khi vấn đáp

- *Nhầm vai trò tín hiệu*: nói `chipselect` do Master phát thay vì do Bus phát. Đây là lỗi nhỏ về thuật ngữ nhưng dễ bị trừ điểm.
- *Quên tín hiệu được giữ trong khi đợi*: khi `waitrequest = 1`, Master *phải giữ* `address`, `read_n`/`write_n`, `byteenable_n` và nếu là ghi thì giữ cả `writedata`. Quên điểm này dẫn đến hiểu sai giao thức.
- *Lẫn lộn fixed wait state với waitrequest*: hai cơ chế này khác nhau về bản chất. Fixed wait state do Bus chèn theo cấu hình tĩnh; `waitrequest` do Slave phát theo trạng thái thực.
- *Quên sinh BSP sau khi đổi Qsys*: lỗi thực hành thường dẫn đến "code đúng nhưng kit không phản ứng".
- *Nhầm DMAC chỉ là Slave*: thực ra DMAC vừa là Slave (cho CPU cấu hình) vừa là Master (tự sinh giao tác đọc/ghi).
- *Quên xóa cờ TO của Timer trong ISR (Prj3)*: dẫn đến ngắt liên tục, treo CPU.

== Ngân hàng câu hỏi ngắn và ý trả lời

#tbl(
  table(
    columns: (1fr, 1.35fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Câu hỏi]], [#cellhead[Ý trả lời cần có]],
    [Master khác Slave ở đâu?], [#cell[Master chủ động phát địa chỉ và yêu cầu đọc/ghi; Slave thụ động phản hồi khi được Bus chọn bằng `chipselect`.]],
    [Bus làm gì ngoài nối dây?], [#cell[Giải mã địa chỉ, định tuyến tín hiệu, sinh `chipselect`, xử lý arbitration khi nhiều Master và chèn chu kỳ chờ.]],
    [Fixed wait state khác `waitrequest` ở đâu?], [#cell[Fixed wait state là số chu kỳ chờ cấu hình trước; `waitrequest` là tín hiệu động do Slave/interconnect kéo lên khi chưa sẵn sàng.]],
    [`byteenable_n` dùng làm gì?], [#cell[Chỉ ra byte nào trong word có hiệu lực. Vì active-low nên bit 0 nghĩa là byte tương ứng được chọn.]],
    [Tại sao phải sinh lại BSP?], [#cell[Vì BSP sinh `system.h`; nếu Qsys đổi địa chỉ hoặc IRQ mà BSP cũ thì chương trình C dùng thông tin sai.]],
    [Prj2 chứng minh kỹ năng gì?], [#cell[Biết tự viết IP Avalon-MM Slave write-only, khai báo `chipselect/address/write/writedata` trong Component Editor, export conduit `hex0` ... `hex5`, và ghi IP bằng `IOWR(HEX_0_BASE, index, digit)`.]],
    [Prj3 hơn Prj1 ở đâu?], [#cell[Timer phần cứng tạo mốc 1 giây ổn định hơn, CPU không bị busy-wait và có thể xử lý việc khác giữa hai ngắt.]],
    [DMAC vừa Master vừa Slave nghĩa là gì?], [#cell[CPU cấu hình DMAC qua vai trò Slave; sau đó DMAC tự phát giao tác đọc/ghi qua vai trò Master để truyền dữ liệu.]],
    [Khi nào cần `volatile` trong C?], [#cell[Khi biến hoặc địa chỉ có thể thay đổi ngoài luồng lệnh bình thường, ví dụ thanh ghi phần cứng hoặc biến được ISR cập nhật.]],
    [Nếu `waitrequest = 1`, Master phải làm gì?], [#cell[Giữ nguyên địa chỉ, điều khiển, byteenable và dữ liệu ghi cho đến khi `waitrequest = 0`.]],
  ),
  [Câu hỏi ngắn thường gặp và ý trả lời],
)

== Khung trả lời 2 phút khi bị hỏi một project

Khi giảng viên yêu cầu trình bày một project bất kỳ, có thể trả lời theo khung 2 phút sau:

+ *Mở đầu*: nêu mục tiêu project và IP chính được dùng.
+ *Phần cứng*: chỉ ra CPU Nios II là Master, các IP nào là Slave, có IRQ hoặc DMAC Master phụ hay không.
+ *Memory map*: nói các Slave có base address riêng; phần mềm truy cập qua `system.h`.
+ *Phần mềm*: tóm tắt thuật toán C, vòng lặp chính, ISR hoặc DMA nếu có.
+ *Điểm cần nhớ*: nêu ưu/nhược điểm hoặc lỗi hay gặp của project đó.

#callout([Ví dụ câu kết], [
  Như vậy project này không chỉ là làm đồng hồ chạy, mà là minh họa một kỹ thuật thiết kế hệ thống nhúng: Prj1 là PIO HEX và polling, Prj2 là custom IP HEX, Prj3 là Timer interrupt, Prj4 là DMA có thêm một Master trên Bus.
])

== Checklist cuối trước khi thi

#note([
  Trước khi vào thi, nên tự kiểm tra rằng mình làm được các việc sau:

  + Vẽ lại được sơ đồ Master - Bus - Slave và ghi tên các tín hiệu chính.
  + Giải thích được read/write, fixed wait state và `waitrequest` mà không nhìn tài liệu.
  + Kể lại được sáu bước thiết kế SoPC từ Quartus đến nạp `.sof` và `.elf`.
  + Với mỗi project, chỉ ra được Master, Slave, bảng địa chỉ, thuật toán phần mềm và điểm trọng tâm.
  + Nhìn một giản đồ thời gian bất kỳ, xác định được Read hay Write, có bao nhiêu chu kỳ chờ và tín hiệu nào phải giữ.
])

== Lời kết

Đề cương ôn tập này được biên soạn trên tinh thần "hiểu rõ vài điểm cốt lõi, thay vì học vẹt nhiều chi tiết rời rạc". Sinh viên chỉ cần nắm vững vai trò của Master, Bus, Slave và bốn cơ chế quản lý chu kỳ chờ là đã đủ để phân tích bất kỳ giản đồ Avalon nào, kể cả giản đồ chưa từng thấy. Khi vấn đáp các project, hãy nhớ trình bày theo bốn mục cố định (sơ đồ khối, bảng địa chỉ, thuật toán, ý chính phần mềm) để câu trả lời có cấu trúc rõ ràng và bao quát.

Chúc sinh viên ôn tập hiệu quả và đạt kết quả tốt trong kỳ thi.
