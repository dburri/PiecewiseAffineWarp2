attribute vec4 aPosition;
attribute mat3 aTransformation;

varying vec4 vColor;
varying vec2 vST;
varying mat3 vTransformation;

void main(void) {
    vTransformation = aTransformation;
    vST = (aPosition.xy+vec2(1,1))*0.5;
    vColor = vec4(aTransformation[0], 1);
    gl_Position = vec4(aPosition.xy, 0, 1);
}
