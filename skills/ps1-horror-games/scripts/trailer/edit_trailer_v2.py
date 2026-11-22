# WORKING EXAMPLE from the trailer for "Keep an Eye". To reuse it for your game, rename:
#   - the shot names in CUTS (they must match the _shot_<name> functions in trailer_shot.gd),
#   - the card art ("card:day2" loads art/day2.png), LOGO (your title art),
#   - BED / TITLE_MUSIC (your score files), and the timing constants (SILENCE, HIT, TITLE_AT, END)
#     to match your own music structure.
# Paths are relative to your project root (two folders above this file). Needs ffmpeg on PATH,
# plus Python 3 with Pillow and numpy.
"""Cut the v2 in-engine trailer: the hand rises out of the sea, the island dies.

Shots come from tools/trailer/trailer_shot.gd (v_* shots plus chop, well,
hands, shore and scream), recorded with Godot's movie writer at 640x360 with
the game's own sound. The bed is your island-fall score (audio only):
quiet to 13 s, building to 39.3 s, true silence, a hit at 41 s. The cuts follow
it: calm island, the shadow kills ground, a goat and a tree, then faster
horror, the scream, silence, and the hand standing in the sea under the title.
No ending is shown.

Usage: python tools/trailer/edit_trailer_v2.py SHOTS_DIR OUTPUT.mp4 [BUILD.mp3 HIT.mp3]
With BUILD and HIT (e.g. ElevenLabs music), BUILD plays 0-39.3 s and is cut
dead for the silence, and HIT starts on the cut at 41 s.
"""
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

SHOTS = Path(sys.argv[1])
OUT = Path(sys.argv[2])
ROOT = Path(__file__).resolve().parents[2]
BED = ROOT / "audio/derived/ending_a_mix.ogg"
TITLE_MUSIC = ROOT / "audio/derived/ending_title_mix.ogg"
LOGO = ROOT / "art/title.png"
W, H = 1920, 1080

# (shot or card, start inside the shot, seconds kept, game-sound gain dB, fade in)
CUTS = [
    ("v_open", .35, 7.0, 4, 1.2),
    ("v_eye", .3, 3.2, 2, 0),
    ("v_goats", .3, 2.4, 2, 0),
    ("chop", .4, 2.2, 0, 0),
    ("card:day2", 0, 1.4, 0, .2),
    ("v_ground", .3, 3.6, 2, 0),
    ("v_goat_dies", .3, 3.6, 4, 0),
    ("v_tree", .3, 4.0, 4, 0),
    ("card:day4", 0, 1.2, 0, .15),
    ("well", .3, 2.4, 0, 0),
    ("v_watchers", .3, 3.7, 2, 0),
    ("hands", 1.6, 3.3, 2, 0),
    ("scream", .55, 1.3, 4, 0),
    ("black", 0, 1.7, 0, 0),        # the score's true silence (39.3 - 41.0)
    ("v_final", .4, 9.0, 0, 0),     # the hit: the hand standing in the sea
]
SILENCE = 39.3       # the score stops dead here
HIT = 41.0           # and hits here, on the cut to the hand in the sea
TITLE_AT = 43.6      # logo fades in over the last shot
TITLE_CUE = 44.2     # title music
END = 50.0

LOOK = "eq=gamma=1.25:contrast=1.08:saturation=1.1,colorbalance=rm=0.04:gm=0.05:bm=-0.03:rh=0.02:gh=0.04"


def vignette(path: Path) -> None:
    yy, xx = np.mgrid[0:H, 0:W]
    r = np.hypot((xx - W / 2) / (W * .52), (yy - H / 2) / (H * .56))
    alpha = np.clip((r - .78) / .5, 0, 1) ** 1.5 * .92
    rgba = np.zeros((H, W, 4), np.uint8)
    rgba[..., 3] = (alpha * 255).astype(np.uint8)
    Image.fromarray(rgba, "RGBA").save(path)


def main() -> None:
    tmp = Path(tempfile.mkdtemp())
    vig = tmp / "vig.png"
    vignette(vig)
    inputs, filters, vparts, aparts = [], [], [], []

    def add(*args):
        inputs.extend(args)
        return sum(1 for a in inputs if a == "-i") - 1

    vig_in = add("-loop", "1", "-i", str(vig))
    t = 0.0
    for k, (name, start, keep, gain, fin) in enumerate(CUTS):
        v, a = f"v{k}", f"a{k}"
        if name == "black" or name.startswith("card:"):
            filters.append(f"color=c=black:s={W}x{H}:r=30:d={keep},setsar=1[bg{k}]")
            if name.startswith("card:"):
                card = add("-loop", "1", "-t", str(keep), "-i", str(ROOT / f"art/{name[5:]}.png"))
                filters.append(f"[{card}:v]scale=620:-1,format=rgba[c{k}];[bg{k}][c{k}]overlay=(W-w)/2:(H-h)/2-30,"
                               f"fade=t=in:st=0:d={fin},fade=t=out:st={keep - 0.2:.3f}:d=0.2,setsar=1,format=yuv420p[{v}]")
            else:
                filters.append(f"[bg{k}]format=yuv420p[{v}]")
            filters.append(f"anullsrc=r=48000:cl=stereo,atrim=0:{keep}[{a}]")
        else:
            src = add("-i", str(SHOTS / f"{name}.avi"))
            chain = (f"[{src}:v]trim={start}:{start + keep},setpts=PTS-STARTPTS,fps=30,"
                     f"scale={W}:{H}:flags=neighbor,{LOOK},format=rgba[r{k}];"
                     f"[{vig_in}:v]trim=0:{keep},setpts=PTS-STARTPTS,fps=30,format=rgba[m{k}];"
                     f"[r{k}][m{k}]overlay=0:0[o{k}]")
            if name == "v_final":
                logo = add("-loop", "1", "-t", str(keep), "-i", str(LOGO))
                at = TITLE_AT - t
                chain += (f";[{logo}:v]scale=880:-1,format=rgba,fade=t=in:st={at}:d=1.4:alpha=1[l{k}];"
                          f"[o{k}][l{k}]overlay=(W-w)/2:H-h-30[o{k}b]")
                last = f"[o{k}b]"
                fout = f",fade=t=out:st={keep - 1.2}:d=1.2"
            else:
                last = f"[o{k}]"
                fout = ""
            fi = f",fade=t=in:st=0:d={fin}" if fin else ""
            filters.append(chain + f";{last}format=yuv420p{fi}{fout},setsar=1[{v}]")
            filters.append(f"[{src}:a]atrim={start}:{start + keep},asetpts=PTS-STARTPTS,aresample=48000,"
                           f"aformat=channel_layouts=stereo,volume={gain}dB,afade=t=in:st=0:d=0.04,"
                           f"afade=t=out:st={keep - 0.06:.3f}:d=0.06[{a}]")
        vparts.append(f"[{v}]")
        aparts.append(f"[{a}]")
        t += keep
    total = t
    n = len(CUTS)
    filters.append("".join(vparts) + f"concat=n={n}:v=1:a=0[video]")
    filters.append("".join(aparts) + f"concat=n={n}:v=0:a=1,apad=whole_dur={END}[game]")
    if len(sys.argv) > 4:
        # Custom score: a build cut hard at the silence, and a hit piece at 41 s.
        bed = add("-i", sys.argv[3])
        cue = add("-i", sys.argv[4])
        # BUILD_PEAK: the moment in BUILD that should land on the silence (its climax).
        # HIT_LEAD: how far into HIT its impact sits, so the impact lands on the cut.
        peak = float(sys.argv[5]) if len(sys.argv) > 5 else SILENCE
        lead = float(sys.argv[6]) if len(sys.argv) > 6 else 0.0
        start = max(0.0, SILENCE - peak)
        skip = max(0.0, peak - SILENCE)
        delay = int(start * 1000)
        filters.append(f"[{bed}:a]aresample=48000,aformat=channel_layouts=stereo,atrim={skip}:{peak},asetpts=PTS-STARTPTS,"
                       f"afade=t=in:st=0:d=1.5,afade=t=out:st={peak - skip - 0.05:.3f}:d=0.05,"
                       f"adelay={delay}|{delay},apad=whole_dur={END}[bed]")
        hd = int((HIT - lead) * 1000)
        filters.append(f"[{cue}:a]aresample=48000,aformat=channel_layouts=stereo,atrim=0:{END - HIT + lead},"
                       f"afade=t=out:st={END - HIT + lead - 1.8:.3f}:d=1.8,adelay={hd}|{hd},"
                       f"apad=whole_dur={END}[cue]")
    else:
        bed = add("-i", str(BED))
        cue = add("-i", str(TITLE_MUSIC))
        filters.append(f"[{bed}:a]aresample=48000,aformat=channel_layouts=stereo,volume=1dB,"
                       f"afade=t=out:st=44.0:d=2.5,apad=whole_dur={END}[bed]")
        filters.append(f"[{cue}:a]aresample=48000,aformat=channel_layouts=stereo,atrim=0:{END - TITLE_CUE},"
                       f"afade=t=out:st={END - TITLE_CUE - 1.6}:d=1.6,adelay={int(TITLE_CUE * 1000)}|{int(TITLE_CUE * 1000)},"
                       f"apad=whole_dur={END}[cue]")
    filters.append(f"[game][bed][cue]amix=inputs=3:normalize=0:duration=longest,atrim=0:{END},"
                   "loudnorm=I=-15:TP=-1.5:LRA=14,alimiter=limit=0.89[audio]")
    cmd = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", *inputs,
           "-filter_complex", ";".join(filters), "-map", "[video]", "-map", "[audio]",
           "-t", str(min(END, total)), "-c:v", "libx264", "-preset", "slow", "-crf", "18",
           "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", str(OUT)]
    subprocess.run(cmd, check=True)
    print(f"wrote {OUT} ({min(END, total):.1f} s)")


if __name__ == "__main__":
    main()
