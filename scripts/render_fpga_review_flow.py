from __future__ import annotations

from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "fpga-review-flow.gif"
WIDTH, HEIGHT = 1000, 340
FRAMES = 48

COLORS = {
    "bg0": (4, 18, 35),
    "bg1": (12, 70, 84),
    "grid": (95, 212, 255, 52),
    "panel": (16, 29, 56),
    "text": (246, 248, 255),
    "muted": (190, 208, 225),
    "cyan": (35, 217, 234),
    "blue": (82, 166, 255),
    "green": (44, 230, 174),
    "yellow": (255, 205, 65),
    "pink": (255, 91, 136),
    "violet": (169, 130, 255),
    "line": (255, 225, 92),
    "mono": (182, 255, 223),
}

NODES = [
    ("Verilog IP", 42, 118, 130, COLORS["blue"]),
    ("Avalon-MM", 204, 118, 140, COLORS["green"]),
    ("Platform", 382, 118, 132, COLORS["yellow"]),
    ("Nios II C", 552, 118, 126, COLORS["pink"]),
    ("PIO/Timer", 714, 118, 130, COLORS["cyan"]),
    ("DMA/HEX", 876, 118, 100, COLORS["violet"]),
]


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf",
        r"C:\Windows\Fonts\segoeuib.ttf" if bold else r"C:\Windows\Fonts\segoeui.ttf",
        r"C:\Windows\Fonts\consolab.ttf" if bold else r"C:\Windows\Fonts\consola.ttf",
    ]
    for candidate in candidates:
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


FONT_TITLE = font(27, True)
FONT_SUB = font(17)
FONT_LABEL = font(22, True)
FONT_SMALL = font(15)
FONT_MONO = font(15)


def lerp(a: int, b: int, t: float) -> int:
    return round(a + (b - a) * t)


def draw_background(draw: ImageDraw.ImageDraw) -> None:
    for y in range(HEIGHT):
        t = y / (HEIGHT - 1)
        r = lerp(COLORS["bg0"][0], COLORS["bg1"][0], t)
        g = lerp(COLORS["bg0"][1], COLORS["bg1"][1], t)
        b = lerp(COLORS["bg0"][2], COLORS["bg1"][2], t)
        draw.line((0, y, WIDTH, y), fill=(r, g, b))
    for x in range(0, WIDTH, 92):
        draw.line((x, 0, x, HEIGHT), fill=COLORS["grid"], width=1)
    for y in range(0, HEIGHT, 48):
        draw.line((0, y, WIDTH, y), fill=COLORS["grid"], width=1)


def center_text(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], text: str, fnt: ImageFont.FreeTypeFont) -> None:
    left, top, right, bottom = box
    bbox = draw.textbbox((0, 0), text, font=fnt)
    x = left + (right - left - (bbox[2] - bbox[0])) / 2
    y = top + (bottom - top - (bbox[3] - bbox[1])) / 2 - 2
    draw.text((x, y), text, font=fnt, fill=COLORS["text"])


def draw_polyline(draw: ImageDraw.ImageDraw, points: Iterable[tuple[int, int]], color: tuple[int, int, int], width: int = 4) -> None:
    pts = list(points)
    for a, b in zip(pts, pts[1:]):
        draw.line((*a, *b), fill=color, width=width)


def point_on_path(points: list[tuple[int, int]], t: float) -> tuple[int, int]:
    segments = []
    total = 0.0
    for a, b in zip(points, points[1:]):
        length = ((b[0] - a[0]) ** 2 + (b[1] - a[1]) ** 2) ** 0.5
        segments.append((a, b, length))
        total += length
    target = (t % 1.0) * total
    seen = 0.0
    for a, b, length in segments:
        if seen + length >= target:
            local = (target - seen) / max(length, 1)
            return lerp(a[0], b[0], local), lerp(a[1], b[1], local)
        seen += length
    return points[-1]


def frame(index: int) -> Image.Image:
    img = Image.new("RGB", (WIDTH, HEIGHT), COLORS["bg0"])
    draw = ImageDraw.Draw(img)
    draw_background(draw)

    draw.text((34, 30), "Luồng ôn tập FPGA/SoPC trên DE10-Standard", font=FONT_TITLE, fill=COLORS["text"])
    draw.text((34, 66), "Quartus -> Platform Designer -> Avalon-MM -> Nios II C -> PIO / Timer / DMA / HEX", font=FONT_SUB, fill=COLORS["muted"])

    main_y = 146
    main_points = [(22, main_y)]
    for _, x, _, w, _ in NODES:
        main_points.extend([(x - 8, main_y), (x + w + 8, main_y)])
    main_points.append((988, main_y))
    draw_polyline(draw, main_points, COLORS["line"], 4)

    doc_path = [(138, 244), (272, 244), (272, 220), (454, 220), (454, 244), (704, 244), (704, 220), (914, 220)]
    draw_polyline(draw, doc_path, COLORS["cyan"], 3)
    draw.text((54, 256), "Tài liệu Typst, README, release và ghi chú kiểm tra", font=FONT_SMALL, fill=COLORS["muted"])

    progress = index / FRAMES
    dot = point_on_path(main_points, progress)
    draw.ellipse((dot[0] - 8, dot[1] - 8, dot[0] + 8, dot[1] + 8), fill=(255, 246, 168), outline=COLORS["text"], width=1)
    dot2 = point_on_path(doc_path, progress + 0.38)
    draw.rounded_rectangle((dot2[0] - 18, dot2[1] - 8, dot2[0] + 18, dot2[1] + 8), radius=8, fill=COLORS["cyan"], outline=(165, 255, 255), width=1)

    for label, x, y, w, border in NODES:
        draw.rounded_rectangle((x + 4, y + 5, x + w + 4, y + 58), radius=12, fill=(0, 0, 0, 84))
        draw.rounded_rectangle((x, y, x + w, y + 53), radius=12, fill=COLORS["panel"], outline=border, width=3)
        center_text(draw, (x, y, x + w, y + 53), label, FONT_LABEL)

    draw.rounded_rectangle((34, 294, 966, 326), radius=10, fill=(1, 7, 22), outline=(18, 28, 58), width=2)
    draw.text((54, 302), "BẰNG CHỨNG: .v | .qsys | .sopcinfo | source.c | Typst PDF | release assets", font=FONT_MONO, fill=COLORS["mono"])
    return img


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    frames = [frame(i).convert("P", palette=Image.Palette.ADAPTIVE, colors=128) for i in range(FRAMES)]
    frames[0].save(OUT, save_all=True, append_images=frames[1:], duration=60, loop=0, optimize=True)
    print(OUT)


if __name__ == "__main__":
    main()
