precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;
void main() {
    vec4 color = texture2D(tex, v_texcoord);
    vec4 blur = vec4(0.0);
    float radius = 2.0;
    for (float x = -radius; x <= radius; x++) {
        for (float y = -radius; y <= radius; y++) {
            blur += texture2D(tex, v_texcoord + vec2(x, y) * 0.005);
        }
    }
    blur /= (radius * 2.0 + 1.0) * (radius * 2.0 + 1.0);
    gl_FragColor = mix(color, blur, 0.5);
}
