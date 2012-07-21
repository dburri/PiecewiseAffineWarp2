varying highp vec2 vST;
uniform sampler2D texUnit;

void main(void) {
    gl_FragColor = texture2D(texUnit, vST);
}
