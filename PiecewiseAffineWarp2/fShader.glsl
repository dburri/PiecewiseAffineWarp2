varying lowp vec4 vColor;
varying highp vec2 vST;
varying highp mat3 vTransformation;

uniform sampler2D texUnit;
uniform lowp vec2 uImgSize;
uniform lowp vec2 uTexSize;

void main(void) {
    lowp vec2 vSTCorr = vST *  uImgSize / uTexSize;
    highp vec4 color = texture2D(texUnit, vSTCorr);
    color = 0.1*color + 0.9*vColor + vTransformation[2][0]*0.0;
    gl_FragColor = color;
}
