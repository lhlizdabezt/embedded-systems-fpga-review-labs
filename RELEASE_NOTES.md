# Release notes - v1.2.0

## Điểm chính

- Viết lại README tiếng Việt theo hướng portfolio kỹ thuật: nêu phạm vi lab, bằng chứng trong mã, cách dựng lại, release và metadata.
- Thêm GIF motion tự host `assets/fpga-review-flow.gif` để mô tả luồng Verilog IP -> Avalon-MM -> Platform Designer -> Nios II C -> PIO/timer/DMA/HEX.
- Thêm `scripts/render_fpga_review_flow.py` để tái tạo GIF có kiểm soát khi cần chỉnh visual.
- Bổ sung `.gitattributes` cho SVG/GIF/PNG/JPG và Python script, giúp line ending và binary assets ổn định hơn trên Windows.
- Đóng gói release có PDF ôn tập, SVG/GIF visual và source snapshot để người review kiểm tra nhanh.

## Tài sản review

| Tài sản | Vai trò |
| --- | --- |
| `README.md` | Trang giới thiệu repo bằng tiếng Việt, có visual, bảng chứng cứ và runbook |
| `assets/fpga-review-motion.svg` | Banner SVG motion, dùng tiếng Anh/ASCII-safe để tránh lỗi dấu |
| `assets/fpga-review-flow.gif` | GIF mô phỏng luồng FPGA/SoPC bằng chữ tiếng Việt raster |
| `DeCuong_OnTap_LuongHaiLong.pdf` | PDF ôn tập Hệ thống nhúng |
| `DeCuongOnTap_HTNhung/` | Source Typst và bibliography để dựng lại tài liệu |
| `embedded-systems-fpga-review-labs-source-v1.2.0.zip` | Source snapshot từ commit phát hành |

## Phạm vi kỹ thuật

Repo này là bộ lab ôn tập và tài liệu học thuật cho FPGA/SoPC, gồm Quartus, Platform Designer/Qsys, Verilog custom IP, Avalon-MM, Nios II C, PIO, timer, DMA và Typst. Nội dung được trình bày để HR và kỹ sư có thể kiểm tra bằng chứng, nhưng không quảng bá như sản phẩm production.
