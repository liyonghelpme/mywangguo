#ifdef GL_ES
precision lowp float;
#endif

varying vec2 v_texCoord;
uniform sampler2D CC_Texture0;
uniform float offset;

vec3 getColor(float deg) {
    deg = mod(deg+360.0, 360.0);
    if(deg < 120.0) {
        return vec3((120.0-deg)/120.0, 0.0, deg/120.0);
    }
    if(deg < 240.0) {
        deg -= 120.0;
        return vec3(0.0, deg/120.0, (120.0-deg)/120.0);
    }
    deg -= 240.0;
    return vec3(deg/120.0, (120.0-deg)/120.0, 0.0);
}
void main() {
    vec4 col = texture2D(CC_Texture0, v_texCoord);
    vec3 r = getColor(offset);
    vec3 b = getColor(offset+120.);
    vec3 g = getColor(offset+240.);
    mat3 cmat = mat3(r,g,b);
    col.rgb = cmat*col.rgb;
    gl_FragColor = col;
}


