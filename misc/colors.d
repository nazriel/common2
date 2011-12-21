module misc.colors;

import math.common;
import math.vec4;

alias uint Color; // a simple ABGR unsigned byte color (memory layout is RGBA on x86)
alias vec4f Colorf; // a 4-components color

// RGBA ubyte-image
const uint RED_MASK   = 0x000000ff;
const uint GREEN_MASK = 0x0000ff00;
const uint BLUE_MASK  = 0x00ff0000;
const uint ALPHA_MASK = 0xff000000;


final uint rgb(ubyte r, ubyte g, ubyte b) // make a color from a integer RGB triplet
{
    return ALPHA_MASK | (b << 16) | (g << 8) | r;
}

final uint rgba(ubyte a, ubyte r, ubyte g, ubyte b) // make a color from a integer RGB triplet
{
    return (a << 24) | (b << 16) | (g << 8) | r;
}

final uint rgbf(float r, float g, float b) // make a color from a floating point RGB triplet
{
    ubyte br = cast(ubyte)(clampf(r, 0.f, 1.f) * 255.f);
    ubyte bg = cast(ubyte)(clampf(g, 0.f, 1.f) * 255.f);
    ubyte bb = cast(ubyte)(clampf(b, 0.f, 1.f) * 255.f);
    return ALPHA_MASK | (bb << 16) | (bg << 8) | br;
}

final uint rgbaf(float r, float g, float b, float a)
{
    auto br = cast(ubyte)(clamp(r, 0.f, 1.f) * 255.f);
    auto bg = cast(ubyte)(clamp(g, 0.f, 1.f) * 255.f);
    auto bb = cast(ubyte)(clamp(b, 0.f, 1.f) * 255.f);
    auto ba = cast(ubyte)(clamp(a, 0.f, 1.f) * 255.f);
    return (ba << 24) | (bb << 16) | (bg << 8) | br;
}

final ubyte Rvalue(uint c)
{
    return cast(ubyte)(c & RED_MASK);
}

final ubyte Gvalue(uint c)
{
    return cast(ubyte)((c & GREEN_MASK) >> 8);
}

final ubyte Bvalue(uint c)
{
    return cast(ubyte)((c & BLUE_MASK) >> 16);
}

final ubyte Avalue(uint c)
{
    return cast(ubyte)((c & ALPHA_MASK) >> 24);
}

// add with saturation
final uint colorAdd(uint a, uint b)
{
    uint res;
    asm
     {
         movd MM0, a;
         movd MM1, b;
         paddusb MM0, MM1;
         movd res, MM0;
         emms;
     }
     return res;
}

// subtract with saturation (a - b)
final uint colorSub(uint a, uint b)
{
    uint res;
    asm
     {
         movd MM0, a;
         movd MM1, b;
         psubusb MM0, MM1;
         movd res, MM0;
         emms;
     }
     return res;
}

// average
final uint colorAvg(uint a, uint b)
{
    return colorMix(a, b, 128, 128);
}

Colorf hsla_to_rgba(float h, float s, float l, float a)
{

    float hue_to_rgb(float m1, float m2, float hue)
    {
        float h = fract(hue);
        if (h * 6.f < 1.f) return m1 + (m2 - m1) * h * 6.f;
        else if (h * 2.f < 1.f) return m2;
        else if (h * 3.f < 2.f) return m1 + (m2 - m1) * (2.f / 3.f - h) * 6;
        else return m1;
    }

    float m1, m2;
    if (l < 0.5)
    {
        m2 = l * (s + 1);
    } else
    {
        m2 = l + s - l * s;
    }
    m1 = l * 2 - m2;
    return vec4f(hue_to_rgb(m1,m2,h + 1.f / 3.f),
                 hue_to_rgb(m1,m2,h),
                 hue_to_rgb(m1,m2,h - 1.f / 3.f),
                 a);
}

// blend colors
// blend factors must be in 0..256
final uint colorMix(uint a, uint b, uint amul, uint bmul, uint aAlphaMul, uint bAlphaMul)
{

    int ra = Rvalue(a), ga = Gvalue(a), ba = Bvalue(a), aa = Avalue(a);
    int rb = Rvalue(b), gb = Gvalue(b), bb = Bvalue(b), ab = Avalue(b);
    int fr = (ra * amul + rb * bmul) >> 8;
    int fg = (ga * amul + gb * bmul) >> 8;
    int fb = (ba * amul + bb * bmul) >> 8;
    int fa = (aa * aAlphaMul + ab * bAlphaMul) >> 8;
    return rgb(cast(ubyte)fr, cast(ubyte)fg, cast(ubyte)fb);
}

// blend colors
// blend factors must be in 0..256
final uint colorMix(uint a, uint b, uint amul, uint bmul)
{

    int ra = Rvalue(a), ga = Gvalue(a), ba = Bvalue(a), aa = Avalue(a);
    int rb = Rvalue(b), gb = Gvalue(b), bb = Bvalue(b), ab = Avalue(b);
    int fr = (ra * amul + rb * bmul) >> 8;
    int fg = (ga * amul + gb * bmul) >> 8;
    int fb = (ba * amul + bb * bmul) >> 8;
    int fa = (aa * amul + ab * bmul) >> 8;
    return rgb(cast(ubyte)fr, cast(ubyte)fg, cast(ubyte)fb);
}
