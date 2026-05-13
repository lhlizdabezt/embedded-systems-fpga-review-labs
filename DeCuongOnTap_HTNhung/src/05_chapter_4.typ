#import "../config.typ": callout, note, figbox, tbl, cellhead, cell, cellleft, timing_signals

= PHÂN TÍCH HOẠT ĐỘNG CỦA MASTER, BUS, SLAVE TRÊN HÌNH 1 – HÌNH 11

== Cách đọc giản đồ thời gian Avalon

Toàn bộ Hình 1 – Hình 11 trong đề cương được đọc theo manual Avalon Bus cũ của Altera. Nửa trên của hình thường là sơ đồ khối Peripheral → Master Port → Avalon Bus Module → Slave Port → Peripheral; nửa dưới là giản đồ thời gian các tín hiệu chính như `clk`, `address`, `byteenable_n`, `read_n` hoặc `write_n`, `chipselect`, `readdata` hoặc `writedata`, và có thể có `waitrequest`. Các cột thời gian được đánh nhãn A, B, C, D, … để tiện chỉ ra ranh giới sự kiện.

Khi đọc giản đồ, hãy giữ ba câu hỏi:

+ *Tín hiệu này do ai phát ra?* — Master hay Slave hay Bus tạo ra. Ví dụ `address`, `read_n`, `write_n`, `writedata` do Master phát; `chipselect` do Bus phát; `readdata`, `waitrequest` do Slave phát.
+ *Tín hiệu này có hiệu lực ở chu kỳ nào?* — quan sát cạnh xuống/cạnh lên của clk, đối chiếu với cột thời gian.
+ *Có chu kỳ chờ không?* — chu kỳ chờ thể hiện qua việc `address`, `chipselect`, `read_n`/`write_n` được giữ không đổi qua nhiều chu kỳ. Nếu có `waitrequest`, đó là chờ "động"; nếu không có thì là chờ "tĩnh" theo cấu hình Slave.

#callout([Quy ước cột thời gian trong tài liệu này], [
  Vì các Hình 1 – Hình 11 nằm trong đề cương gốc, tài liệu chỉ mô tả ý nghĩa từng cột A, B, C, … chứ không vẽ lại giản đồ. Khi đọc manual, cần chú ý Hình 8 đến Hình 11 là góc nhìn *Master Port*, còn Hình 1 đến Hình 7 là góc nhìn *Slave Port*.
])

== Cách nhận dạng nhanh một giản đồ Avalon chưa biết

Khi gặp một giản đồ mới, có thể nhận dạng theo bốn bước. Cách này giúp tránh trả lời lan man khi giảng viên hỏi bất kỳ Hình 1 - Hình 11 hoặc vẽ thêm một biến thể.

#tbl(
  table(
    columns: (1.35cm, 5.3cm, 1fr),
    align: (x, y) => if y == 0 or x == 0 { center } else { left },
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Bước]], [#cellhead[Cần quan sát]], [#cellhead[Kết luận rút ra]],
    [#align(center)[1]], [#cellleft[Tín hiệu điều khiển đang active là `read_n` hay `write_n`?]], [#cellleft[`read_n = 0` là giao tác đọc; `write_n = 0` là giao tác ghi.]],
    [#align(center)[2]], [#cellleft[Đường dữ liệu xuất hiện là `readdata` hay `writedata`?]], [#cellleft[`readdata` đi từ Slave về Master; `writedata` đi từ Master sang Slave.]],
    [#align(center)[3]], [#cellleft[Có tín hiệu `waitrequest` không? Nếu có, nó ở mức 1 bao lâu?]], [#cellleft[Có chu kỳ chờ động; Master phải giữ nguyên tín hiệu cho đến khi `waitrequest = 0`.]],
    [#align(center)[4]], [#cellleft[Nếu không có `waitrequest`, địa chỉ/control bị giữ qua bao nhiêu chu kỳ?]], [#cellleft[Đó là số fixed wait state do cấu hình Slave/Bus chèn vào.]],
    [#align(center)[5]], [#cellleft[Có bao nhiêu lần địa chỉ đổi sang giá trị mới?]], [#cellleft[Mỗi lần địa chỉ mới thường là một giao tác mới; nếu đổi ngay sau khi xong giao tác trước thì là back-to-back.]],
  ),
  [Quy trình nhận dạng một giản đồ thời gian Avalon],
)

#callout([Mẹo đếm chu kỳ chờ], [
  Với fixed wait state, hãy đếm số chu kỳ giữa lúc `address` và `read_n`/`write_n` có hiệu lực đến trước lúc dữ liệu được lấy mẫu hoặc được chốt. Với `waitrequest`, chỉ cần đếm số chu kỳ `waitrequest = 1`; trong toàn bộ khoảng đó Master chưa được kết thúc giao tác.
])

== Bảng ai phát tín hiệu trong giản đồ

Một giản đồ Avalon có nhiều đường tín hiệu nên rất dễ nhầm nguồn phát. Bảng sau giúp trả lời nhanh câu hỏi "tín hiệu này do ai tạo ra?".

#tbl(
  table(
    columns: (3.0cm, 3.2cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Tín hiệu]], [#cellhead[Nguồn phát chính]], [#cellhead[Ghi chú khi đọc giản đồ]],
    [`address`], [Master], [#cell[Bus có thể chuyển đổi hoặc cắt bớt thành offset trước khi đưa tới Slave.]],
    [`byteenable_n`], [Master], [#cell[Đi kèm địa chỉ để chỉ byte hợp lệ trong word. Active-low.]],
    [`read_n`], [Master], [#cell[Active-low; khi bằng 0 nghĩa là đang yêu cầu đọc.]],
    [`write_n`], [Master], [#cell[Active-low; khi bằng 0 nghĩa là đang yêu cầu ghi.]],
    [`writedata`], [Master], [#cell[Phải ổn định trong toàn bộ giao tác ghi, nhất là khi `waitrequest = 1`.]],
    [`chipselect`], [Bus/interconnect], [#cell[Được sinh ra sau khi Bus giải mã địa chỉ và chọn đúng Slave.]],
    [`readdata`], [Slave], [#cell[Chỉ có ý nghĩa trong giao tác đọc và phải hợp lệ trước lúc Master lấy mẫu.]],
    [`waitrequest`], [Slave hoặc interconnect], [#cell[Kéo lên 1 để yêu cầu Master giữ giao tác.]],
  ),
  [Nguồn phát của các tín hiệu trong giản đồ Avalon-MM],
)

== Hình 1 — Slave Read cơ bản (zero wait state)

=== Bối cảnh

Hình 1 minh họa giao tác đọc đơn giản nhất: Slave đáp ứng ngay trong chu kỳ kế tiếp, không cần chèn thêm chu kỳ chờ. Đây là dạng giao thức quen thuộc với các Slave có độ trễ nội bộ không đáng kể, ví dụ thanh ghi PIO đơn giản. Sơ đồ khối phía trên cho thấy Master Port phát `Address`, `Data`, `Control` vào Avalon Bus Module; Bus phát ra `address, byteenable_n`, `read_n`, `chipselect`, `readdata` đối diện với Slave Port.

=== Phân tích từng cột

#timing_signals([
  *Cột A* — chu kỳ nghỉ trước giao tác. `address`, `read_n`, `chipselect` ở mức không hoạt động (read\_n = 1, chipselect = 0). Bus và Slave không làm gì.

  *Cột B* — Master phát địa chỉ và byteenable\_n; `read_n` xuống 0; Bus giải mã và đặt `chipselect` lên 1 cho đúng Slave.

  *Cột C* — Slave nhận diện được giao tác đọc (chipselect = 1, read\_n = 0). Slave xuất giá trị thanh ghi tương ứng lên `readdata`.

  *Cột D* — Master lấy mẫu `readdata` ở cạnh lên clk. Đây cũng là thời điểm dữ liệu được CPU coi là "đã có".

  *Cột E* — Master kết thúc giao tác; `read_n` về 1, `chipselect` về 0. Hệ thống quay lại trạng thái nghỉ.
])

#figbox([Đặc điểm cần nhớ về Hình 1], [
  Hình 1 là tham chiếu để so sánh với các hình khác. Toàn bộ giao tác chỉ chiếm một chu kỳ "có ích" và một vài chu kỳ thiết lập/kết thúc. Đây là zero wait state cho Slave Read.
])

== Hình 2 — Slave Read với 1 chu kỳ chờ (fixed wait state = 1)

Hình 2 lặp lại giao thức của Hình 1 nhưng Slave được khai báo có 1 fixed wait state. Trong cột thời gian, ta thấy thêm một chu kỳ giữa "address valid" và "readdata valid" so với Hình 1.

#timing_signals([
  *Cột A* — chu kỳ nghỉ.

  *Cột B* — Master phát `address`, `byteenable_n`; `read_n` xuống 0. Bus đặt `chipselect` lên 1.

  *Cột C* — Slave bắt đầu xử lý nhưng chưa kịp xuất `readdata`. Bus *không* phát `waitrequest` — wait state này là "tĩnh", do Qsys cấu hình sẵn. Từ phía Master, các tín hiệu `address`, `read_n`, `chipselect` được giữ nguyên.

  *Cột D* — Slave xuất `readdata` hợp lệ.

  *Cột E* — Master lấy mẫu `readdata`.

  *Cột F* — Master kết thúc giao tác, các tín hiệu trở về trạng thái không hoạt động.
])

#note([
  Khi cấu hình Slave với fixed wait state, chính Bus chèn thêm chu kỳ và giữ tín hiệu giúp Master. Master không cần biết Slave chậm bao nhiêu chu kỳ; nó chỉ cần "đợi tới chu kỳ đọc dữ liệu" theo quy ước.
])

== Hình 3 — Slave Read với 2 chu kỳ chờ (fixed wait state = 2)

Hình 3 mở rộng tiếp Hình 2 với 2 chu kỳ chờ tĩnh.

#timing_signals([
  *Cột A* — chu kỳ nghỉ.

  *Cột B* — Master phát `address`, `byteenable_n`; `read_n` xuống 0; Bus đặt `chipselect` lên 1.

  *Cột C, D* — hai chu kỳ chờ tĩnh. `address`, `read_n`, `chipselect` được giữ nguyên. Slave đang xử lý nhưng chưa xuất `readdata`.

  *Cột E* — Slave xuất `readdata` hợp lệ.

  *Cột F* — Master lấy mẫu `readdata`. Sau đó các tín hiệu trở về không hoạt động.
])

#callout([Khi nào dùng nhiều fixed wait state], [
  Slave có thể cần nhiều fixed wait state khi truy cập một nguồn chậm hơn, ví dụ thanh ghi nội bộ chia clock hoặc bộ nhớ đồng bộ có độ trễ đọc cố định. Sự khác biệt giữa Hình 1, Hình 2, Hình 3 chỉ là *số chu kỳ chờ tĩnh*; giao thức và vai trò các tín hiệu giữ nguyên.
])

== Hình 4 — Slave Read với waitrequest (variable wait state)

=== Đặc điểm

Hình 4 thay fixed wait state bằng tín hiệu `waitrequest` do Slave phát. Đây là cách quản lý độ trễ động: Slave chủ động báo cho Bus rằng "tôi chưa xong, đừng lấy dữ liệu vội". Trong hình này chỉ cần hiểu là *một giao tác đọc bị kéo dài*; các cột F-G trong manual biểu thị số chu kỳ chờ có thể kéo dài tùy ý, không phải giao tác đọc thứ hai.

=== Phân tích

#timing_signals([
  *Cột A* — bắt đầu chu kỳ đọc trên cạnh lên `clk`.

  *Cột B* — Bus đưa `address`, `byteenable_n`, `read_n` hợp lệ đến Slave.

  *Cột C* — Bus giải mã địa chỉ và assert `chipselect`.

  *Cột D* — Slave assert `waitrequest` trước cạnh clock kế tiếp vì chưa có `readdata` hợp lệ.

  *Cột E* — Bus lấy mẫu thấy `waitrequest = 1`, vì vậy không capture `readdata`; giao tác trở thành wait state.

  *Cột F-G* — `waitrequest` còn được giữ mức 1 trong số chu kỳ tùy ý; Master/Bus phải giữ nguyên địa chỉ và tín hiệu điều khiển.

  *Cột H* — Slave đưa `readdata` hợp lệ.

  *Cột I* — Slave deassert `waitrequest`.

  *Cột J* — Bus capture `readdata` ở cạnh lên kế tiếp, giao tác đọc kết thúc.
])

#note([
  Khác biệt mấu chốt với Hình 1 – Hình 3: số chu kỳ chờ không cố định trước, vì `waitrequest` phụ thuộc trạng thái thực của Slave tại thời điểm đó. Manual cũng nhấn mạnh Bus không có timeout; nếu Slave giữ `waitrequest` mãi, Master có thể bị treo.
])

== Hình 5 — Slave Write cơ bản (zero wait state)

Hình 5 đối ứng với Hình 1 nhưng cho ghi. Master phát `write_n`, `writedata` thay vì `read_n`, `readdata`.

#timing_signals([
  *Cột A* — chu kỳ nghỉ.

  *Cột B* — Master phát `address`, `byteenable_n`, `writedata`; `write_n` xuống 0. Các tín hiệu địa chỉ, dữ liệu và điều khiển bắt đầu hợp lệ ở phía Slave.

  *Cột C* — Slave thấy `write_n = 0` và `chipselect = 1`, chốt `writedata` vào thanh ghi nội bộ ở cạnh lên clk.

  *Cột D* — Master kết thúc giao tác, các tín hiệu trở về trạng thái không hoạt động.
])

#figbox([Lưu ý so sánh Read và Write], [
  Trong giao tác Read, Master *nhận* dữ liệu nên cần đợi Slave xuất `readdata`. Trong giao tác Write, Master *cấp* dữ liệu nên Slave chỉ việc chốt; vì vậy giao thức Write thường có ít chu kỳ chờ hơn ở dạng cơ bản.
])

== Hình 6 — Slave Write với fixed wait state

Hình 6 thêm một fixed wait state giữa lúc Bus đưa địa chỉ/dữ liệu đến Slave và lúc Slave capture dữ liệu. Đây là wait state tĩnh do cấu hình Slave, không phải do `waitrequest`.

#timing_signals([
  *Cột A* — chu kỳ nghỉ.

  *Cột B* — Master phát `address`, `byteenable_n`, `writedata`; `write_n` xuống 0. Các tín hiệu địa chỉ, dữ liệu và điều khiển bắt đầu hợp lệ ở phía Slave.

  *Cột C* — Bus giải mã địa chỉ và đặt `chipselect = 1`.

  *Cột D* — fixed wait state duy nhất kết thúc ở cạnh lên; trong chu kỳ này `address`, `writedata`, `byteenable_n`, `write_n`, `chipselect` được giữ nguyên.

  *Cột E* — Slave capture `writedata`, `address`, `byteenable_n`, `write_n`, `chipselect`; giao tác ghi kết thúc.

  *Cột F* — Master kết thúc giao tác.
])

== Hình 7 — Slave Write với waitrequest

Hình 7 thay fixed wait state bằng `waitrequest` cho ghi. Đây là kịch bản Slave có thời gian ghi không cố định, ví dụ cần đẩy dữ liệu vào FIFO mà FIFO hiện đang đầy. Tương tự Hình 4, các cột F-G là khoảng wait kéo dài tùy ý của *một giao tác ghi*, không phải giao tác thứ hai.

#timing_signals([
  *Cột A* — bắt đầu giao tác ghi trên cạnh lên `clk`.

  *Cột B* — Bus đưa `address`, `writedata`, `byteenable_n`, `write_n` hợp lệ đến Slave.

  *Cột C* — Bus giải mã địa chỉ và assert `chipselect`.

  *Cột D* — Slave assert `waitrequest` trước cạnh clock kế tiếp vì chưa capture được dữ liệu.

  *Cột E* — Bus lấy mẫu thấy `waitrequest = 1`; chu kỳ trở thành wait state và mọi tín hiệu ghi phải giữ nguyên.

  *Cột F-G* — `waitrequest` tiếp tục ở mức 1 trong số chu kỳ tùy ý.

  *Cột H* — Slave cuối cùng capture `writedata`.

  *Cột I* — Slave deassert `waitrequest`.

  *Cột J* — giao tác ghi kết thúc ở cạnh lên kế tiếp.
])

#callout([Chu kỳ chờ động phía Write], [
  Master luôn phải giữ `address`, `writedata`, `write_n`, `byteenable_n` cho đến khi `waitrequest` về 0. Nếu Master "buông" sớm, Slave có thể chốt sai dữ liệu. Đây là điểm thường bị hỏi khi vấn đáp giao thức ghi có waitrequest.
])

== Hình 8 — Master Read nhìn từ phía Master Port (zero wait state)

Hình 8 đặt vòng tròn nhấn vào *Master Port* thay vì Slave Port: tài liệu nhìn các tín hiệu mà Master phát ra Bus và nhận vào từ Bus. Trong hình này, `waitrequest` không được assert nên giao tác đọc kết thúc trong một bus cycle. Điểm cần nhớ là ở góc nhìn Master, Master chỉ quan tâm: phát `address`, `byteenable_n`, `read_n`, chờ `waitrequest`, rồi capture `readdata`.

#timing_signals([
  *Cột A* — chu kỳ đọc bắt đầu trên cạnh lên `clk`.

  *Cột B* — Master assert `address`, `byteenable_n` và `read_n`.

  *Cột C* — Bus trả `readdata` hợp lệ ngay trong bus cycle đầu; `waitrequest` không assert.

  *Cột D* — Master capture `readdata` ở cạnh lên kế tiếp, deassert `address` và `read_n`; giao tác kết thúc.
])

#note([
  Dù `waitrequest` không assert trong Hình 8, tín hiệu này vẫn là một phần của giao thức Master Read. Nếu một Slave hoặc Bus chậm hơn, cùng Master đó sẽ phải chuyển sang hành vi của Hình 9.
])

== Hình 9 — Master Read với waitrequest

Hình 9 là Master Read khi Avalon Bus Module assert `waitrequest`. Nếu `waitrequest` được giữ trong N bus cycle thì toàn bộ transfer kéo dài N + 1 bus cycle. Đây là quy tắc vàng của Master: assert tín hiệu để bắt đầu transfer, sau đó giữ nguyên output cho đến khi `waitrequest` được deassert.

#timing_signals([
  *Cột A* — bắt đầu giao tác đọc trên cạnh lên `clk`.

  *Cột B* — Master assert `address`, `byteenable_n` và `read_n`.

  *Cột C* — Avalon Bus Module assert `waitrequest` trước cạnh clock kế tiếp.

  *Cột D* — Master thấy `waitrequest = 1`; bus cycle này trở thành wait state.

  *Cột E-F* — khi `waitrequest` còn assert, Master giữ nguyên `address`, `byteenable_n`, `read_n`.

  *Cột G* — `readdata` hợp lệ xuất hiện từ Bus.

  *Cột H* — Bus deassert `waitrequest`.

  *Cột I* — Master capture `readdata`, deassert output; giao tác kết thúc.
])

#callout([Ý nghĩa đối với DMA], [
  Khi DMAC đóng vai trò Master để đọc dữ liệu, mỗi giao tác đọc vẫn tuân theo quy tắc Hình 8 hoặc Hình 9. Tổng thời gian truyền không chỉ phụ thuộc tần số clock mà còn phụ thuộc số chu kỳ `waitrequest` do Slave nguồn hoặc Bus gây ra.
])

== Hình 10 — Master Write nhìn từ Master Port (zero wait state)

Hình 10 đối ứng với Hình 8 cho giao tác ghi. Master phát `address`, `byteenable_n`, `writedata`, `write_n`; nếu `waitrequest` không assert tại cạnh clock kế tiếp thì giao tác ghi kết thúc ngay trong một bus cycle.

#timing_signals([
  *Cột A* — bắt đầu giao tác ghi trên cạnh lên `clk`.

  *Cột B* — Master assert `address`, `byteenable_n`, `writedata`, `write_n`.

  *Cột C* — `waitrequest` không assert tại cạnh lên; write transfer kết thúc. Master có thể bắt đầu transfer khác ở bus cycle kế tiếp.
])

== Hình 11 — Master Write với hai chu kỳ waitrequest

Hình 11 minh họa Master Write khi Avalon Bus Module assert `waitrequest` trong hai bus cycle. Toàn bộ write transfer vì vậy kéo dài ba bus cycle. Đây là tình huống Slave chưa capture được dữ liệu ngay, ví dụ FIFO đầy hoặc bộ nhớ đang bận arbitration với Master khác.

#timing_signals([
  *Cột A* — bắt đầu giao tác ghi trên cạnh lên `clk`.

  *Cột B* — Master assert `address`, `byteenable_n`, `writedata`, `write_n`.

  *Cột C* — `waitrequest = 1`; đây là wait state thứ nhất, Master giữ nguyên toàn bộ output.

  *Cột D* — `waitrequest` vẫn bằng 1; đây là wait state thứ hai, Master tiếp tục giữ nguyên output.

  *Cột E* — Bus deassert `waitrequest`.

  *Cột F* — tại cạnh lên kế tiếp, vì `waitrequest` không assert, Master deassert output và write transfer kết thúc.
])

#callout([Sự khác biệt giữa Hình 10 và Hình 11], [
  Hình 10 là Master Write không có wait state; Hình 11 là Master Write có hai wait states do `waitrequest`. Nguyên tắc thiết kế Master không đổi: giữ `address`, `byteenable_n`, `writedata`, `write_n` cho đến cạnh clock sau khi `waitrequest` được deassert.
])

== Tóm tắt khác biệt giữa các hình

#tbl(
  table(
    columns: (1.5cm, 2.6cm, 2.6cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Hình]], [#cellhead[Loại giao tác]], [#cellhead[Quản lý chờ]], [#cellhead[Điểm trọng tâm]],
    [Hình 1], [#cell[Slave Read]], [#cell[Zero wait state]], [#cell[Giao tác đọc cơ bản; Slave xuất `readdata` ngay sau khi `chipselect` lên.]],
    [Hình 2], [#cell[Slave Read]], [#cell[1 fixed wait state]], [#cell[Bus chèn 1 chu kỳ chờ tĩnh trước khi `readdata` hợp lệ.]],
    [Hình 3], [#cell[Slave Read]], [#cell[2 fixed wait states]], [#cell[Mở rộng của Hình 2 với 2 chu kỳ chờ tĩnh.]],
    [Hình 4], [#cell[Slave Read]], [#cell[`waitrequest`]], [#cell[Slave chủ động kéo dài một giao tác đọc; Bus capture `readdata` sau khi `waitrequest` hạ.]],
    [Hình 5], [#cell[Slave Write]], [#cell[Zero wait state]], [#cell[Giao tác ghi cơ bản; Slave chốt `writedata`.]],
    [Hình 6], [#cell[Slave Write]], [#cell[1 fixed wait state]], [#cell[Bus chèn một chu kỳ chờ tĩnh trước khi Slave capture `writedata`.]],
    [Hình 7], [#cell[Slave Write]], [#cell[`waitrequest`]], [#cell[Slave kéo dài một giao tác ghi; Master giữ `writedata` đến khi `waitrequest` hạ.]],
    [Hình 8], [#cell[Master Read]], [#cell[Zero wait state]], [#cell[Góc nhìn Master Port; `waitrequest` không assert, Master capture `readdata` sau một bus cycle.]],
    [Hình 9], [#cell[Master Read]], [#cell[`waitrequest`]], [#cell[Góc nhìn Master Port; nếu `waitrequest` giữ N chu kỳ thì transfer kéo dài N + 1 chu kỳ.]],
    [Hình 10], [#cell[Master Write]], [#cell[Zero wait state]], [#cell[Góc nhìn Master Port; `waitrequest` không assert nên ghi xong trong một bus cycle.]],
    [Hình 11], [#cell[Master Write]], [#cell[2 wait states]], [#cell[Góc nhìn Master Port; Master giữ tín hiệu qua hai chu kỳ `waitrequest`.]],
  ),
  [Tóm tắt nhanh đặc điểm Hình 1 – Hình 11],
)

== Cặp so sánh hay bị hỏi

Ngoài việc phân tích từng hình, cần chuẩn bị các cặp so sánh vì câu hỏi vấn đáp thường ở dạng "Hình này khác hình kia chỗ nào?".

#tbl(
  table(
    columns: (3.8cm, 1fr),
    inset: 5pt,
    stroke: 0.45pt,
    [#cellhead[Cặp so sánh]], [#cellhead[Điểm khác biệt cần trả lời]],
    [Hình 1 và Hình 5], [#cell[Cùng zero wait state nhưng Hình 1 là Read nên dữ liệu nằm trên `readdata`; Hình 5 là Write nên dữ liệu nằm trên `writedata`.]],
    [Hình 2 và Hình 3], [#cell[Cùng là Read có fixed wait state, khác số chu kỳ chờ tĩnh: một chu kỳ so với hai chu kỳ.]],
    [Hình 3 và Hình 4], [#cell[Cùng làm Master phải đợi, nhưng Hình 3 đợi theo cấu hình cố định, Hình 4 đợi theo `waitrequest` động từ Slave.]],
    [Hình 4 và Hình 7], [#cell[Cùng dùng `waitrequest` ở phía Slave; Hình 4 là đọc nên chờ `readdata`, Hình 7 là ghi nên giữ `writedata` đến khi Slave capture được.]],
    [Hình 8 và Hình 9], [#cell[Cùng là Master Read; Hình 8 không có wait state, Hình 9 có `waitrequest` nên Master giữ output lâu hơn.]],
    [Hình 10 và Hình 11], [#cell[Cùng là Master Write; Hình 10 không có wait state, Hình 11 có hai chu kỳ `waitrequest`.]],
  ),
  [Các cặp hình nên so sánh được bằng lời],
)

== Mẫu trả lời khi giảng viên chỉ vào một cột thời gian

Khi bị hỏi "tại cột C đang xảy ra gì?", câu trả lời nên có ba ý: trạng thái tín hiệu, vai trò của thành phần, và hệ quả sang chu kỳ sau. Ví dụ với một cột đang có `waitrequest = 1`, không nên chỉ nói "đang wait"; nên nói đầy đủ hơn:

#callout([Mẫu câu], [
  Ở cột này, Slave hoặc Bus đang kéo `waitrequest = 1`, nghĩa là giao tác chưa thể hoàn tất. Vì vậy Master phải giữ nguyên `address`, `read_n`/`write_n`, `byteenable_n` và nếu là ghi thì giữ cả `writedata`. Sang chu kỳ sau, chỉ khi `waitrequest` về 0 thì dữ liệu đọc mới được lấy mẫu hoặc dữ liệu ghi mới được chốt.
])

Nếu cột đó không có `waitrequest` nhưng vẫn là chu kỳ chờ, hãy nói đây là fixed wait state: Bus giữ tín hiệu theo số chu kỳ đã khai báo trong cấu hình Slave, không phải do Slave kéo `waitrequest` động.

== Câu hỏi ôn tập gợi ý

#note([
  + So sánh giao tác đọc trong Hình 1, Hình 2 và Hình 3. Khác biệt nằm ở đâu? Bus dựa vào đâu để chèn chu kỳ chờ tĩnh?
  + So sánh Hình 4 và Hình 7: cả hai đều dùng `waitrequest`, nhưng một bên là đọc và một bên là ghi. Tín hiệu nào do ai phát, ai phải giữ?
  + Tại sao Hình 8 và Hình 9 lại nhìn từ Master Port? So sánh trường hợp không có và có `waitrequest`.
  + Trong Hình 11, vì sao Master phải giữ nguyên `address`, `writedata` qua hai chu kỳ `waitrequest`? Điều gì sẽ xảy ra nếu Master rút sớm?
  + Cho một giản đồ ngẫu nhiên không có nhãn, hãy chỉ ra đó là Read hay Write, có dùng `waitrequest` hay không, và đếm số chu kỳ chờ.
  + Tín hiệu `chipselect` xuất hiện sau bước giải mã nào của Bus? Nếu `chipselect = 0` thì Slave có được phép chốt `writedata` không?
  + Vì sao không được hiểu cột F-G trong Hình 4 hoặc Hình 7 là giao tác mới? Dấu hiệu nào cho thấy vẫn là một giao tác đang bị kéo dài?
])
