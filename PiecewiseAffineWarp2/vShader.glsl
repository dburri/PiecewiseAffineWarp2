attribute vec4 aPosition;

varying vec4 vColor;
varying vec2 vST;

void main(void) {
    vST = (aPosition.xy+vec2(1,1))*0.5;
    vColor = vec4(vST, aPosition.w, 1);
    gl_Position = vec4(aPosition.xy, 0, 1);
}
