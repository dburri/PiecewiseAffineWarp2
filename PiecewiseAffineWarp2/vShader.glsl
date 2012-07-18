attribute vec4 aPosition;
attribute vec2 aST;
attribute vec4 aColor;

varying vec4 vColor;
varying vec2 vST;

void main(void) {
    vST = (aPosition.st+vec2(1,1))*0.5;
    vColor = vec4(vST,0,1);
    gl_Position = aPosition;
}
