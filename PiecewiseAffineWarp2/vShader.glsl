attribute vec4 aPosTo;
attribute vec4 aPosFrom;

uniform vec2 uImgSize;
uniform vec2 uTexSize;

varying vec2 vST;

void main(void) {
    vST = (aPosFrom.xy / uTexSize);
    vec2 tmpPosTo = ((aPosTo.xy / uImgSize) * vec2(2., 2.) - vec2(1., 1.));
    gl_Position = vec4(tmpPosTo, 0, 1);
}
