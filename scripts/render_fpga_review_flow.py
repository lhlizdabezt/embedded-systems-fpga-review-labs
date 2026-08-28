from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "fpga-review-flow.gif"
WIDTH, HEIGHT = 1000, 340
FRAMES = 48

COLORS = {
    "bg0": (4, 18, 35),
    "bg1": (12, 70, 84),
    "panel": (16, 29, 56),
    "text": (246, 248, 255),
    "muted": (190, 208, 225),
    "cyan": (35, 217, 234),
    "blue": (82, 166, 255),
    "green": (44, 230, 174),
    "yellow": (255, 205, 65),
    "pink": (255, 91, 136),
    "violet": (169, 130, 255),
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


def center_text(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], text: str, fnt: ImageFont.FreeTypeFont) -> None:
    left, top, right, bottom = box
    bbox = draw.textbbox((0, 0), text, font=fnt)
    x = left + (right - left - (bbox[2] - bbox[0])) / 2
    y = top + (bottom - top - (bbox[3] - bbox[1])) / 2 - 2
    draw.text((x, y), text, font=fnt, fill=COLORS["text"])


def frame(index: int) -> Image.Image:
    img = Image.new("RGB", (WIDTH, HEIGHT), COLORS["bg0"])
    draw = ImageDraw.Draw(img)
    draw_background(draw)

    draw.text((34, 30), "FPGA and SoPC Review Labs", font=FONT_TITLE, fill=COLORS["text"])
    draw.text((34, 66), "Verilog | Platform Designer | Avalon-MM | Nios II C | Typst", font=FONT_SUB, fill=COLORS["muted"])

    for label, x, y, w, border in NODES:
        shift = -3 if ((index // 8) + (x // 100)) % 2 else 0
        draw.rounded_rectangle((x + 4, y + 5 + shift, x + w + 4, y + 58 + shift), radius=12, fill=(0, 0, 0, 84))
        draw.rounded_rectangle((x, y + shift, x + w, y + 53 + shift), radius=12, fill=COLORS["panel"], outline=border, width=3)
        center_text(draw, (x, y + shift, x + w, y + 53 + shift), label, FONT_LABEL)

    draw.rounded_rectangle((80, 218, 920, 264), radius=12, fill=(8, 22, 43), outline=COLORS["cyan"], width=2)
    center_text(draw, (80, 218, 920, 264), "Tracked evidence: .v | .qsys | .sopcinfo | source.c | Typst PDF", FONT_SMALL)

    draw.rounded_rectangle((34, 294, 966, 326), radius=10, fill=(1, 7, 22), outline=(18, 28, 58), width=2)
    draw.text((54, 302), "Quartus 18.1 context | DE10-Standard course labs | release-backed review", font=FONT_MONO, fill=COLORS["mono"])
    return img


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    frames = [frame(i).convert("P", palette=Image.Palette.ADAPTIVE, colors=128) for i in range(FRAMES)]
    frames[0].save(OUT, save_all=True, append_images=frames[1:], duration=60, loop=0, optimize=True)
    print(OUT)


if __name__ == "__main__":
    main()
