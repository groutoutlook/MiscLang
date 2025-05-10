# All further examples will assume these imports
import vapoursynth as vs
from functools import partial
from vsutil import scale_value, get_depth
from lvsfunc.misc import get_prop

core = vs.core


def auto_lbox(clip: vs.VideoNode, flt: vs.VideoNode, flt_lbox: vs.VideoNode,
              crop_top: int = 130, crop_bottom: int = 130) -> vs.VideoNode:
    """
    Automatically determining what scenes have letterboxing
    and applying the correct edgefixing to it
    """

    def _letterboxed(n: int, f: vs.VideoFrame,
                     clip: vs.VideoNode, flt: vs.VideoNode, flt_lbox: vs.VideoNode
                     ) -> vs.VideoNode:
        crop = (
            core.std.CropRel(clip, top=crop_top, bottom=crop_bottom)
            .std.AddBorders(top=crop_top, bottom=crop_bottom, color=[luma_val, chr_val, chr_val])
        )

        clip_prop = round(get_prop(clip.std.PlaneStats().get_frame(n), "PlaneStatsAverage", float), 4)
        crop_prop = round(get_prop(crop.std.PlaneStats().get_frame(n), "PlaneStatsAverage", float), 4)

        if crop_prop == clip_prop:
            return flt_lbox.std.SetFrameProp("Letterbox", intval=1)
        return flt.std.SetFrameProp("Letterbox", intval=0)

    luma_val = scale_value(16, 8, get_depth(clip))
    chr_val = scale_value(128, 8, get_depth(clip))

    return core.std.FrameEval(clip, partial(_letterboxed, clip=clip, flt=flt, flt_lbox=flt_lbox), clip)


core = vs.core

my_clip = core.std.BlankClip(width=1920, height=1080, length=1000, fpsnum=24, color=[255, 0, 0])
my_clip.set_output()
