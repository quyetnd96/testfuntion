#ifndef MAINLIGHT_INCLUDED
#define MAINLIGHT_INCLUDED

void MainLight_half(out half3 Direction)
{
#ifdef SHADERGRAPH_PREVIEW
    Direction = half3(0, 1, 0);
#else
    #if defined(UNIVERSAL_LIGHTING_INCLUDED)
        Light light = GetMainLight();
        Direction = light.direction;
    #endif
#endif
}
#endif