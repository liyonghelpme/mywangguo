#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec3 v_normal;
varying vec3 v_pos;
varying vec3 v_wn;
//varying vec3 v_eye;

uniform sampler2D CC_Texture0;
uniform vec3 light;

uniform sampler2D u_normalMap;
void main() {
    /*
    vec3 L = normalize(light-v_pos);
    float diff = 1*max(dot(v_normal, L), 0.0);
    diff = clamp(diff, 0, 1);
    */

    vec3 L = normalize(light-v_pos);
    float diff = clamp(dot(v_normal, L), 0.4, 1);

    //gl_FragColor = v_fragmentColor;
    //gl_FragColor = texture2D(CC_Texture0, v_texCoord)*diff;
    gl_FragColor = vec4(diff);
    //gl_FragColor = vec4(v_normal, 1);
    //gl_FragColor = vec4(v_texCoord, 0, 1);
}
