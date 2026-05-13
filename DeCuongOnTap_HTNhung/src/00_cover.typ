#import "../config.typ": meta

#let outer_cover() = [
  #set page(numbering: none, footer: none)
  #rect(
    stroke: 4.2pt,
    inset: 7pt,
    width: 100%,
    height: 100%,
    [
      #rect(
        stroke: 1.1pt,
        inset: 13pt,
        width: 100%,
        height: 100%,
        [
          #align(center)[
            #stack(
              dir: ttb,
              spacing: 0.13cm,
              text(12pt, weight: "bold")[#meta.university_top],
              text(12pt, weight: "bold")[#meta.university_name],
              text(12pt, weight: "bold")[#meta.faculty_name],
            )
          ]

          #v(0.62cm)
          #align(center)[#text(13pt, weight: "bold")[#meta.doc_type]]
          #v(0.16cm)
          #align(center)[#text(12pt, weight: "bold")[Học phần: #meta.course_name]]

          #v(0.52cm)
          #align(center)[#rect(width: 3.8cm, height: 0.7pt, fill: black)]
          #v(0.24cm)
          #align(center)[
            #pad(left: 0.42cm, right: 0.42cm)[
              #text(16.6pt, weight: "bold")[#meta.title_upper_vi]
            ]
          ]
          #v(0.24cm)
          #align(center)[#rect(width: 10.8cm, height: 0.7pt, fill: black)]

          #v(0.42cm)
          #align(center)[
            #pad(left: 1.0cm, right: 1.0cm)[
              #text(12pt, style: "italic")[#meta.scope]
            ]
          ]

          #v(1fr)
          #align(center)[#text(12pt, weight: "bold")[#meta.city – #meta.month_year]]
        ],
      )
    ],
  )
  #pagebreak()
]

#let inner_cover() = [
  #set page(numbering: none, footer: none)
  #align(center)[
    #stack(
      dir: ttb,
      spacing: 0.14cm,
      text(12pt, weight: "bold")[#meta.university_top],
      text(12pt, weight: "bold")[#meta.university_name],
      text(12pt, weight: "bold")[#meta.faculty_name],
      text(13pt, weight: "bold")[#meta.doc_type],
    )
  ]

  #v(0.38cm)
  #align(center)[#text(12pt)[Học phần: #meta.course_name]]

  #v(0.56cm)
  #align(center)[#pad(left: 0.7cm, right: 0.7cm)[#text(16pt, weight: "bold")[#meta.title_upper_vi]]]

  #v(0.48cm)
  #grid(
    columns: (4.2cm, 0.28cm, 1fr),
    row-gutter: 0.16cm,
    [Loại tài liệu], [:], [Đề cương ôn tập theo bốn nội dung của giảng viên],
    [Phạm vi], [:], [Master / Bus / Slave, quy trình SoPC, 4 project thực hành, phân tích Hình 1 – Hình 11],
    [Định dạng], [:], [Bundle Typst — biên dịch bằng `typst compile main.typ`],
    [Mục đích sử dụng], [:], [Ôn tập trước kỳ thi, đối chiếu lại các nội dung thực hành đã làm],
  )

  #v(0.6cm)
  #line(length: 100%, stroke: 0.45pt + rgb("#888888"))
  #v(0.2cm)
  #set par(first-line-indent: 0pt, justify: true)
  #text(11.5pt, style: "italic")[
    Tài liệu này được biên soạn lại từ đề cương do giảng viên cung cấp, tổ chức nội dung theo trình tự bốn câu hỏi ôn tập. Phần trình bày tập trung vào các điểm cần nhớ khi vấn đáp và cách đọc giản đồ thời gian Avalon Bus, không phải là tài liệu chính thức của môn học. Sinh viên cần đối chiếu lại với slide bài giảng và bộ tài liệu thực hành chính thức trước khi sử dụng.
  ]

  #v(1fr)
  #align(right)[#text(12pt)[#meta.city – #meta.month_year]]
  #pagebreak()
]

#let cover_pages() = [
  #outer_cover()
  #inner_cover()
]
