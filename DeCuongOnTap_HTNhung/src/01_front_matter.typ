#import "../config.typ": meta, centered_title, outline_entry, tbl, cellhead, cell

#let preface_page() = [
  #outline_entry([Lời nói đầu])
  #centered_title([LỜI NÓI ĐẦU])
  Tài liệu này được biên soạn theo bốn nội dung ôn tập do giảng viên cung cấp cho học phần #meta.course_name. Mục đích của tài liệu là giúp sinh viên ôn tập có hệ thống, từ các khái niệm nền tảng về Master, Bus, Slave trong kiến trúc Avalon, đến quy trình thiết kế một hệ thống nhúng dùng SoPC và các project thực hành cụ thể. Phần cuối tập trung phân tích từng giản đồ thời gian xuất hiện trong đề cương, từ Hình 1 đến Hình 11.

  Đề cương gốc được giảng viên đưa ra ở dạng bốn ý lớn: (1) trình bày các khái niệm và chức năng của Master, Bus, Slave; (2) quy trình thiết kế một hệ thống nhúng dùng SoPC; (3) hiểu và thiết kế được bốn project thực hành — Prj1 dùng sáu IP PIO để điều khiển HEX, Prj2 dùng custom IP HEX tự viết, Prj3 dùng Timer cho phần đếm giây, Prj4 dùng DMAC; (4) phân tích hoạt động của Master, Bus và Slave thông qua giản đồ thời gian đính kèm. Tài liệu giữ nguyên thứ tự bốn nội dung này để tiện đối chiếu khi ôn tập.

  Tài liệu được trình bày theo hướng cô đọng, hạn chế phần lý thuyết xa đề. Mỗi nội dung đều có phần "Câu hỏi ôn tập" gợi ý ở cuối, giúp sinh viên tự kiểm tra mức độ hiểu bài. Các giản đồ thời gian Avalon được giải thích theo từng cột thời gian (A, B, C, …) để đọc cùng với hình trong đề cương gốc; phần này không lặp lại hình ảnh mà chỉ mô tả tín hiệu, vì hình đã có sẵn trong đề cương của giảng viên.

  #v(0.4cm)
  #align(right)[#text(12pt, style: "italic")[Người biên soạn]]
  #pagebreak()
]

#let abbreviations_page() = [
  #outline_entry([Danh mục chữ viết tắt])
  #centered_title([DANH MỤC CHỮ VIẾT TẮT])
  #tbl(
    table(
      columns: (3.0cm, 1fr),
      inset: 5pt,
      stroke: 0.45pt,
      [#cellhead[Chữ viết tắt]], [#cellhead[Diễn giải]],
      [SoPC], [System on a Programmable Chip — hệ thống trên một chip khả lập trình],
      [FPGA], [Field-Programmable Gate Array — mạch khả trình theo trường],
      [IP], [Intellectual Property — khối thiết kế phần cứng đóng gói sẵn],
      [PIO], [Parallel Input/Output — IP vào/ra song song],
      [DMA], [Direct Memory Access — truy cập bộ nhớ trực tiếp],
      [DMAC], [DMA Controller — bộ điều khiển DMA],
      [CPU], [Central Processing Unit — bộ xử lý trung tâm (ở đây thường là Nios II)],
      [Avalon-MM], [Avalon Memory-Mapped Interface — chuẩn giao tiếp ánh xạ bộ nhớ của Avalon Bus],
      [HDL], [Hardware Description Language — ngôn ngữ mô tả phần cứng (Verilog/VHDL)],
      [BSP], [Board Support Package — gói hỗ trợ phần cứng cho phần mềm],
      [HAL], [Hardware Abstraction Layer — lớp trừu tượng hóa phần cứng],
      [LED], [Light-Emitting Diode — đèn LED],
      [SW], [Switch — công tắc gạt trên kit],
      [HEX], [Bộ hiển thị bảy đoạn (seven-segment display)],
      [IRQ], [Interrupt Request — yêu cầu ngắt],
      [ISR], [Interrupt Service Routine — chương trình phục vụ ngắt],
      [LSB / MSB], [Least / Most Significant Bit — bit có trọng số thấp / cao],
    ),
    [Danh mục chữ viết tắt sử dụng trong tài liệu],
  )
  #pagebreak()
]
