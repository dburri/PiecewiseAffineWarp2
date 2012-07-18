varying lowp vec4 vColor;
varying highp vec2 vST;

uniform sampler2D texUnit;
uniform lowp vec2 uImgSize;
uniform lowp vec2 uTexSize;

void main(void) {
    lowp vec2 vSTCorr = vST *  uImgSize / uTexSize;
    highp vec4 color = texture2D(texUnit, vSTCorr);
    color = 0.7*color + 0.3*vColor;
    gl_FragColor = color;
}
