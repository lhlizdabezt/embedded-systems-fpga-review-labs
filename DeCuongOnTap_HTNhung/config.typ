#let meta = (
  university_top: "ĐẠI HỌC QUỐC GIA THÀNH PHỐ HỒ CHÍ MINH",
  university_name: "TRƯỜNG ĐẠI HỌC KHOA HỌC TỰ NHIÊN",
  faculty_name: "KHOA ĐIỆN TỬ - VIỄN THÔNG",
  course_name: "HỆ THỐNG NHÚNG",
  doc_type: "ĐỀ CƯƠNG ÔN TẬP",
  title_vi: "Đề cương ôn tập học phần Hệ thống nhúng – Thiết kế hệ thống nhúng dùng SoPC trên nền Avalon Bus",
  title_upper_vi: "ĐỀ CƯƠNG ÔN TẬP HỌC PHẦN HỆ THỐNG NHÚNG – THIẾT KẾ HỆ THỐNG NHÚNG DÙNG SoPC TRÊN NỀN AVALON BUS",
  scope: "Bốn nội dung ôn tập theo đề cương: khái niệm Master/Bus/Slave, quy trình thiết kế hệ thống nhúng dùng SoPC, bốn project thực hành (PIO HEX, Custom IP HEX, Timer, DMAC) và phân tích hoạt động của Master/Bus/Slave trên Hình 1 – Hình 11.",
  city: "Thành phố Hồ Chí Minh",
  month_year: "Tháng 5 năm 2026",
)

#let body_leading = 0.86em
#let page_footer = context align(right)[#counter(page).display()]

#let title_rule(rule_width: 4.2cm, thickness: 0.65pt) = [
  #align(center)[#rect(width: rule_width, height: thickness, fill: black)]
]

#let centered_title(text_value) = [
  #align(center)[#text(16pt, weight: "bold")[#text_value]]
  #v(0.12cm)
  #title_rule()
  #v(0.18cm)
]

#let outline_entry(title) = [
  #{
    show heading: none
    heading(numbering: none)[#title]
  }
]

#let noindent(body) = [
  #set par(first-line-indent: 0pt)
  #body
]

#let compact(body) = [
  #set par(first-line-indent: 0pt, leading: 0.70em)
  #body
]

#let cellhead(body) = [
  #set par(first-line-indent: 0pt, justify: false)
  #text(weight: "bold")[#body]
]
#let cell(body) = [
  #set par(first-line-indent: 0pt, justify: true)
  #body
]
#let cellleft(body) = [
  #set par(first-line-indent: 0pt, justify: false)
  #body
]

#let callout(title, body) = block(
  width: 100%,
  inset: 9pt,
  fill: rgb("#f7f7f7"),
  stroke: 0.55pt + rgb("#777777"),
  radius: 4pt,
  breakable: true,
  [
    #set par(first-line-indent: 0pt, justify: true)
    #text(12.5pt, weight: "bold")[#title]
    #v(0.06cm)
    #body
  ],
)

#let note(body) = block(
  width: 100%,
  inset: 8pt,
  fill: rgb("#fff8e1"),
  stroke: 0.55pt + rgb("#c9a227"),
  radius: 4pt,
  breakable: true,
  [
    #set par(first-line-indent: 0pt, justify: true)
    #text(12.5pt, weight: "bold")[Ghi nhớ. ]
    #body
  ],
)

#let figbox(title, body) = block(
  width: 100%,
  inset: 9pt,
  fill: rgb("#f1f5fb"),
  stroke: 0.55pt + rgb("#3a5fa3"),
  radius: 4pt,
  breakable: true,
  [
    #set par(first-line-indent: 0pt, justify: true)
    #text(12.5pt, weight: "bold")[#title]
    #v(0.06cm)
    #body
  ],
)

#let photo(path, cap, width: 100%, height: auto) = figure(
  align(center)[#image(path, width: width, height: height, fit: "contain")],
  kind: image,
  caption: cap,
)

#let tbl(body, cap) = figure(
  body,
  kind: table,
  caption: cap,
)

#let timing_signals(body) = block(
  width: 100%,
  inset: 8pt,
  fill: rgb("#f7f7f7"),
  stroke: 0.45pt + rgb("#888888"),
  radius: 3pt,
  breakable: true,
  [
    #set par(first-line-indent: 0pt, justify: false, leading: 0.70em)
    #text(12pt)[#body]
  ],
)
