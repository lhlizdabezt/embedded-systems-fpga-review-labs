#import "../config.typ": callout, note, tbl, cellhead, cell, cellleft

= MASTER, BUS, SLAVE — KHÁI NIỆM VÀ CHỨC NĂNG

== Tổng quan kiến trúc Avalon Bus

Trong một hệ thống nhúng được xây dựng theo mô hình SoPC, các khối phần cứng không kết nối trực tiếp với nhau bằng dây dẫn rời, mà giao tiếp với nhau thông qua một hạ tầng truyền thông gọi là *Avalon Bus*. Hạ tầng này được sinh tự động bởi công cụ Qsys (Platform Designer) khi sinh viên kéo các IP vào hệ thống và nối các port với nhau. Trên Avalon Bus, mỗi khối phần cứng đóng một trong hai vai trò: *Master* — khởi tạo các giao tác đọc/ghi, hoặc *Slave* — đáp ứng các giao tác đó. Avalon Bus Module nằm ở giữa, đảm nhiệm việc định tuyến, giải mã địa chỉ, đồng bộ thời gian và xử lý cạnh tranh khi nhiều Master cùng truy cập một Slave.

Mô hình ba thành phần Master – Bus – Slave là cách trừu tượng hóa giúp người thiết kế tách bạch hai mối quan tâm. Một là *điều khiển luồng dữ liệu*: khối nào ra lệnh, khối nào phục vụ, khi nào cần đợi. Hai là *kết nối vật lý*: phần này được công cụ tự lo, người thiết kế chỉ cần khai báo địa chỉ, độ rộng dữ liệu và vài thuộc tính của port. Nhờ tách bạch như vậy, hệ thống có thể được mở rộng bằng cách bổ sung thêm IP mà không phải vẽ lại toàn bộ sơ đồ kết nối.

Theo manual Avalon Bus, cần phân biệt *bus cycle* và *bus transfer*. Bus cycle là một chu kỳ clock của bus, tính từ cạnh lên này đến cạnh lên kế tiếp. Bus transfer là một thao tác đọc hoặc ghi một đối tượng dữ liệu; một transfer có thể chỉ mất một bus cycle, hoặc kéo dài nhiều bus cycle nếu có fixed wait state hoặc `waitrequest`.

#callout([Quy ước trong tài liệu], [
  Tài liệu sử dụng quy ước tín hiệu Avalon-MM thường gặp: `address`, `byteenable_n` cho địa chỉ và mặt nạ byte; `read_n`, `write_n` cho yêu cầu đọc/ghi active-low trong manual; `chipselect` để chọn Slave; `readdata`, `writedata` cho dữ liệu hai chiều; `waitrequest` để Slave/Bus yêu cầu Master kéo dài transfer. Trong Platform Designer, cùng signal type có thể khai báo active-high hoặc active-low. Vì vậy IP HEX buổi 4 dùng `iWrite` active-high, còn manual cũ thường vẽ `write_n` active-low.
])

== Master: khái niệm và chức năng

*Master* là khối phần cứng có khả năng *khởi tạo giao tác* trên Avalon Bus. Trong các project thực hành, Master phổ biến nhất là CPU Nios II — chính là khối chạy chương trình C của sinh viên. Khi chương trình C thực hiện một câu lệnh ghi địa chỉ ánh xạ I/O (ví dụ `IOWR_ALTERA_AVALON_PIO_DATA(...)`), Nios II sẽ phát ra một giao tác ghi trên port Master của nó. Ngoài CPU, các khối DMAC và một số IP truyền thông tốc độ cao cũng đóng vai trò Master vì chúng có thể tự sinh ra địa chỉ và yêu cầu truy cập bộ nhớ mà không cần CPU can thiệp từng byte.

Chức năng chính của Master gồm bốn nhóm:

- *Sinh địa chỉ và byteenable*: Master quyết định ô nhớ hoặc thanh ghi nào sẽ bị đọc/ghi, cùng với mặt nạ byte hợp lệ trong word.
- *Phát tín hiệu điều khiển*: Master kích hoạt `read_n` hoặc `write_n` để báo cho Bus biết loại giao tác đang yêu cầu.
- *Cấp/nhận dữ liệu*: với giao tác ghi, Master đặt dữ liệu lên `writedata`; với giao tác đọc, Master nhận `readdata` từ Slave.
- *Tuân thủ tín hiệu đợi*: nếu Slave hoặc Bus phát `waitrequest`, Master phải giữ nguyên các tín hiệu địa chỉ/điều khiển cho đến khi `waitrequest` về 0; đây là điểm phân biệt Master "biết đợi" với một mạch điều khiển đơn giản.

#note([
  Một port Master không bắt buộc phải là CPU. Khi sinh viên tự viết một IP có khả năng đọc bộ nhớ ngoài (ví dụ một mạch quét bảng tra), IP đó cũng được khai báo là Master trong Qsys. Điểm chung là khả năng *chủ động* sinh ra địa chỉ.
])

== Slave: khái niệm và chức năng

*Slave* là khối phần cứng *đáp ứng thụ động* các giao tác từ Master. Trong các project thực hành, Slave bao gồm các IP PIO điều khiển LED, HEX, Switch; các IP Timer; vùng nhớ on-chip RAM/ROM; các thanh ghi của IP tự viết. Slave không tự khởi tạo giao tác mà chỉ phản ứng khi Bus dẫn tín hiệu đến port của nó.

Trên port Slave, các tín hiệu thường gặp gồm `chipselect`, `address`, `byteenable_n`, `read_n`, `write_n`, `readdata`, `writedata` và tùy chọn `waitrequest`. Slave nhận biết mình được chọn khi `chipselect = 1`; sau đó nó dựa vào `address` để chọn thanh ghi nội bộ, đọc dữ liệu vào (với write) hoặc xuất dữ liệu ra (với read). Một số Slave đơn giản chỉ cần một chu kỳ để hoàn tất, một số Slave chậm hơn cần nhiều chu kỳ — và đó là lúc các tín hiệu `waitrequest` hoặc số chu kỳ chờ cố định (fixed wait states) được dùng.

#tbl(
  table(
    columns: (3.5cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Chức năng]], [#cellhead[Mô tả]],
    [Giải mã địa chỉ trong Slave], [#cell[Khi `chipselect = 1`, Slave đọc `address` để chọn đúng thanh ghi nội bộ. Ví dụ thanh ghi giờ ở offset 0, phút ở offset 1, giây ở offset 2.]],
    [Phản hồi đọc], [#cell[Khi `read_n = 0` và `chipselect = 1`, Slave đặt giá trị thanh ghi tương ứng lên đường `readdata`. Master lấy mẫu giá trị này theo thời điểm quy ước trong giao thức.]],
    [Tiếp nhận ghi], [#cell[Khi `write_n = 0` và `chipselect = 1`, Slave chốt giá trị `writedata` vào thanh ghi nội bộ. Một số Slave cho phép chọn byte cần ghi qua `byteenable_n`.]],
    [Phát `waitrequest`], [#cell[Nếu Slave chưa kịp xử lý, nó kéo `waitrequest` lên 1 để Bus thông báo cho Master giữ nguyên giao tác. Khi sẵn sàng, Slave hạ `waitrequest` xuống 0 và quá trình đọc/ghi hoàn tất.]],
    [Sinh ngắt (tùy chọn)], [#cell[Một Slave có thể có line IRQ để báo sự kiện về bộ điều khiển ngắt; ví dụ Timer hết khoảng đếm hoặc PIO phát hiện cạnh tín hiệu vào.]],
  ),
  [Các chức năng cốt lõi của một Slave Avalon-MM],
)

== Bus: khái niệm và chức năng

*Avalon Bus Module* không phải là một sợi dây, mà là một *mạng kết nối có cấu trúc* được Qsys sinh ra. Bus đảm nhiệm bốn chức năng chính.

Thứ nhất, *giải mã địa chỉ ở mức hệ thống*: dựa trên dải địa chỉ Master phát ra, Bus xác định Slave nào sẽ được chọn và đặt `chipselect` của Slave đó. Master không cần biết Slave được gắn ở đâu trên FPGA; nó chỉ cần biết base address mà công cụ đã gán. Manual lưu ý `chipselect` có thể là tín hiệu tổ hợp sinh từ địa chỉ đã đăng ký, nên không nên thiết kế logic bắt cạnh lên của `chipselect` hoặc cạnh xuống của `read_n` làm "xung bắt đầu" duy nhất.

Thứ hai, *định tuyến tín hiệu*: Bus chuyển `address`, `byteenable_n`, `read_n`, `write_n`, `writedata` từ Master sang Slave; chuyển `readdata`, `waitrequest` từ Slave về Master. Khi hệ thống có nhiều Master, Bus còn đảm nhiệm việc *trọng tài (arbitration)* để quyết định Master nào được phục vụ trước khi xảy ra xung đột.

Thứ ba, *đồng bộ thời gian*: Bus chèn các tầng pipeline khi cần để đáp ứng yêu cầu về tần số. Người thiết kế nhìn vào giản đồ thời gian thường thấy một vài cột chu kỳ A, B, C, … có vẻ "thừa"; thực tế đó là độ trễ của Bus và thời gian Slave xử lý.

Thứ tư, *quản lý chu kỳ chờ*: Bus phối hợp giữa số chu kỳ chờ cố định khai báo trong Slave và tín hiệu `waitrequest` động. Nhờ đó Master thấy một giao thức thống nhất, dù Slave chậm hay nhanh.

#callout([Vai trò ba thành phần trong một câu], [
  Master ra lệnh, Slave thực hiện, Bus là cầu nối có quyền trọng tài. Khi đọc giản đồ thời gian, hãy xác định trước tín hiệu nào do Master phát, tín hiệu nào do Slave phát; Bus chỉ chuyển tiếp và có thể chèn thêm chu kỳ.
])

== Luồng một giao tác đọc/ghi đầy đủ

Khi bị hỏi về Master, Bus, Slave, sinh viên không nên chỉ trả lời định nghĩa rời rạc. Cách trả lời an toàn hơn là mô tả trọn vẹn một giao tác đi qua ba thành phần. Một giao tác Avalon-MM luôn có dạng: Master đưa yêu cầu, Bus chọn đúng Slave, Slave phản hồi, sau đó Master kết thúc giao tác. Nếu nhớ được chuỗi này, hầu hết câu hỏi về giản đồ thời gian đều suy ra được.

#tbl(
  table(
    columns: (1.35cm, 1fr, 1fr),
    align: (x, y) => if y == 0 or x == 0 { center } else { left },
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Bước]], [#cellhead[Giao tác đọc]], [#cellhead[Giao tác ghi]],
    [#align(center)[1]], [#cellleft[Master đặt `address`, `byteenable_n` và kéo `read_n = 0`.]], [#cellleft[Master đặt `address`, `byteenable_n`, `writedata` và kéo `write_n = 0`.]],
    [#align(center)[2]], [#cellleft[Bus giải mã địa chỉ, chọn Slave tương ứng bằng `chipselect = 1`.]], [#cellleft[Bus giải mã địa chỉ và cũng đặt `chipselect = 1` cho Slave đích.]],
    [#align(center)[3]], [#cellleft[Slave đọc địa chỉ nội bộ, chuẩn bị dữ liệu và đặt lên `readdata`.]], [#cellleft[Slave kiểm tra `write_n`, `chipselect`, `byteenable_n` rồi chốt `writedata` vào thanh ghi.]],
    [#align(center)[4]], [#cellleft[Nếu chưa có dữ liệu, Slave giữ `waitrequest = 1`; Master phải giữ nguyên yêu cầu.]], [#cellleft[Nếu chưa ghi được, Slave giữ `waitrequest = 1`; Master phải giữ nguyên dữ liệu ghi.]],
    [#align(center)[5]], [#cellleft[Khi `waitrequest = 0`, Master lấy mẫu `readdata` và kết thúc đọc.]], [#cellleft[Khi `waitrequest = 0`, Slave đã nhận dữ liệu; Master rút `write_n` và kết thúc ghi.]],
  ),
  [Chuỗi sự kiện cần nhớ cho giao tác đọc và ghi],
)

#note([
  Điểm mấu chốt: trong Read, dữ liệu quan trọng đi từ Slave về Master qua `readdata`; trong Write, dữ liệu quan trọng đi từ Master sang Slave qua `writedata`. Các tín hiệu còn lại chủ yếu giúp hai bên thống nhất "đang truy cập thanh ghi nào, vào lúc nào, có phải đợi không".
])

== Phân biệt giao thức không có và có waitrequest

Avalon hỗ trợ hai cách quản lý độ trễ của Slave:

- *Fixed wait states*: số chu kỳ chờ được khai báo cố định khi cấu hình Slave trong Qsys. Bus tự động kéo dài giao tác đúng số chu kỳ đó. Cách này đơn giản, phù hợp với Slave có độ trễ ổn định (PIO, thanh ghi cấu hình).
- *Variable wait states với `waitrequest`*: Slave tự kéo `waitrequest` lên/xuống tùy trạng thái. Cách này phù hợp với Slave có thời gian xử lý thay đổi (FIFO, bộ nhớ ngoài, IP truyền thông).

Sự khác biệt giữa hai cách này thể hiện rất rõ ở các giản đồ thời gian Hình 1 – Hình 11 trong đề cương. Hình 1, Hình 5, Hình 8 và Hình 10 minh họa transfer cơ bản không có wait state; Hình 2, Hình 3 và Hình 6 minh họa wait states cố định; Hình 4, Hình 7, Hình 9 và Hình 11 minh họa transfer bị kéo dài bởi `waitrequest`.

== Vai trò của byteenable, chipselect và readdata trong giao tác

Ba tín hiệu thường bị nhầm lẫn khi đọc giản đồ là `byteenable_n`, `chipselect` và `readdata`. Tài liệu tách riêng để sinh viên dễ phân biệt.

#tbl(
  table(
    columns: (3.5cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Tín hiệu]], [#cellhead[Diễn giải]],
    [`address`, `byteenable_n`], [#cell[Master phát ra cùng thời điểm để xác định word và byte cần truy cập. `byteenable_n[i] = 0` nghĩa là byte thứ $i$ trong word có hiệu lực.]],
    [`chipselect`], [#cell[Bus phát ra dành riêng cho Slave được chọn; chỉ một Slave nhận `chipselect = 1` tại một thời điểm. Slave dựa vào tín hiệu này để biết mình đang được giao tiếp.]],
    [`read_n`], [#cell[Master phát ra để báo giao tác là đọc. Active-low: 0 nghĩa là đang yêu cầu đọc.]],
    [`write_n`], [#cell[Tương tự `read_n` nhưng cho ghi.]],
    [`writedata`], [#cell[Dữ liệu Master đặt lên Bus khi ghi. Có hiệu lực kèm với `write_n` và `chipselect`.]],
    [`readdata`], [#cell[Dữ liệu Slave xuất ra khi đọc. Master lấy mẫu vào cuối chu kỳ đọc theo quy ước Avalon.]],
    [`waitrequest`], [#cell[Slave (hoặc Bus) phát ra để giữ giao tác lại. Khi `waitrequest = 1`, Master phải giữ nguyên `address`, `read_n`, `write_n`, `writedata`.]],
  ),
  [Ý nghĩa các tín hiệu chính trong giao thức Avalon-MM],
)

== Địa chỉ, độ rộng dữ liệu và byteenable

Trong các bài tự viết IP, giảng viên rất hay hỏi vì sao IP chỉ cần điều khiển một LED bảy đoạn 7 bit hoặc một chữ số 0-9 nhưng port dữ liệu lại là `writedata[31:0]`. Lý do là Avalon-MM được tổ chức theo độ rộng dữ liệu của Master/Bus để phần mềm truy cập thuận tiện, còn bên trong Slave có thể chỉ dùng một vài bit có nghĩa.

Ví dụ IP HEX buổi 4 khai báo `iWriteData[31:0]`, nhưng để hiển thị một chữ số thì HDL chỉ cần `iWriteData[3:0]`. Nếu phần mềm gọi `IOWR(HEX_0_BASE, 3, 8)`, CPU phát một transfer ghi đến base address của IP; Bus chọn Slave bằng `chipselect`; bên trong IP, `iAddress = 3` chọn `oHex3`, còn `iWriteData[3:0] = 8` được giải mã ra mã LED bảy đoạn cho số 8.

Tín hiệu `byteenable_n[3:0]` cho biết byte nào trong word được phép ghi. Vì hậu tố `_n` nghĩa là active-low, `byteenable_n = 4'b1110` nghĩa là byte thấp nhất có hiệu lực, còn ba byte cao bị che. Với các IP register/control đơn giản như HEX, nhiều bài lab có thể không đưa `byteenable_n` ra HDL; khi đó IP mặc định coi lệnh ghi là ghi cả word và tự dùng các bit cần thiết.

Địa chỉ cũng cần phân biệt hai mức:

- *Base address*: địa chỉ bắt đầu của cả IP trong không gian địa chỉ hệ thống, do Qsys gán. Phần mềm thấy địa chỉ này qua macro như `MY_IP_BASE`.
- *Offset/địa chỉ nội bộ*: địa chỉ con bên trong IP. Với custom IP HEX, index 0 đến 5 trong `IOWR(HEX_0_BASE, index, digit)` được đưa vào `iAddress[2:0]` để chọn `HEX0` đến `HEX5`.

#callout([Cách giải thích khi bị hỏi về offset], [
  CPU không tự đưa trực tiếp "thanh ghi giờ" cho IP. CPU chỉ phát một địa chỉ tuyệt đối. Bus nhìn địa chỉ tuyệt đối đó, chọn đúng IP bằng `chipselect`, rồi đưa phần offset cho IP. IP dùng offset để chọn thanh ghi nội bộ. Vì vậy base address thuộc về hệ thống, còn offset thuộc về thiết kế bên trong Slave.
])

== Quy tắc thiết kế một Avalon-MM Slave tự viết

Một IP tự viết đóng vai trò Slave cần tối thiểu ba phần: phần giao tiếp Bus, phần thanh ghi nội bộ, và phần logic chức năng. Nếu trộn ba phần này quá lẫn lộn, mạch vẫn có thể chạy nhưng rất khó debug khi bị sai địa chỉ hoặc sai thời điểm đọc/ghi.

#tbl(
  table(
    columns: (3.3cm, 1fr, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Quy tắc]], [#cellhead[Nên làm]], [#cellhead[Lỗi hay gặp]],
    [Reset rõ ràng], [#cell[Đặt các thanh ghi về giá trị xác định khi `reset_n = 0`.]], [#cell[Không reset khiến giờ/phút/giây ban đầu là `X` khi mô phỏng hoặc giá trị ngẫu nhiên trên kit.]],
    [Ghi đồng bộ], [#cell[Chốt `writedata` ở cạnh lên clock khi `chipselect && !write_n`.]], [#cell[Ghi trong khối tổ hợp làm sinh latch hoặc ghi sai nhiều lần trong một giao tác.]],
    [Đọc ổn định], [#cell[Xuất `readdata` theo `address`; nếu cần trễ thì dùng wait state hoặc `waitrequest`.]], [#cell[Đổi `readdata` quá muộn khiến Master lấy mẫu sai dữ liệu.]],
    [Không ghi vào read-only], [#cell[Thanh ghi chỉ đọc như Switch chỉ phản ánh input ngoài.]], [#cell[Cho CPU ghi vào Switch register làm mô hình chức năng không đúng với phần cứng thật.]],
    [Xử lý giá trị vượt ngưỡng], [#cell[Chặn giờ > 23, phút/giây > 59 hoặc tự modulo về khoảng hợp lệ.]], [#cell[Cho phép ghi 99 giây rồi carry bị sai khi chạy đồng hồ.]],
  ),
  [Các quy tắc quan trọng khi viết Slave Avalon-MM],
)

== Mẫu trả lời vấn đáp nhanh

Nếu câu hỏi chỉ là "Master, Bus, Slave là gì?", có thể trả lời theo mẫu sau để đủ ý:

#callout([Mẫu trả lời], [
  Trong hệ thống SoPC dùng Avalon-MM, Master là khối chủ động phát giao tác đọc/ghi, ví dụ CPU Nios II hoặc DMAC. Slave là khối bị truy cập, ví dụ PIO, Timer, on-chip memory hoặc IP tự viết; nó phản hồi thông qua `readdata` hoặc nhận `writedata`. Avalon Bus nằm giữa để giải mã địa chỉ, phát `chipselect`, định tuyến tín hiệu, xử lý arbitration nếu có nhiều Master và chèn chu kỳ chờ thông qua fixed wait state hoặc `waitrequest`.
])

== Câu hỏi ôn tập gợi ý

#note([
  Sinh viên nên trả lời được các câu hỏi sau bằng lời, không cần nhìn lại tài liệu:

  + Phân biệt vai trò của Master và Slave; lấy hai ví dụ Master và hai ví dụ Slave trong các project đã làm.
  + Avalon Bus Module thực hiện những chức năng gì? Tại sao không thể nối trực tiếp Master với Slave?
  + Giải thích tín hiệu `chipselect` được sinh ra ở đâu, ai dùng và có vai trò gì.
  + Khi nào Slave dùng fixed wait states, khi nào dùng `waitrequest`?
  + Trong giao tác đọc, Slave đặt dữ liệu lên `readdata` ở thời điểm nào, Master lấy mẫu vào thời điểm nào?
  + Giải thích sự khác nhau giữa base address của IP và offset thanh ghi bên trong IP.
  + Nếu tự viết một Slave mà quên xét `chipselect`, lỗi gì có thể xảy ra?
])
