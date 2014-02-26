#ifdef GL_ES
precision lowp float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D CC_Texture0;

uniform sampler2D noisemap;

//uniform vec4 CC_Time;  time/10 time time*2 time*4
//uniform vec4 CC_SinTime;
//uniform vec4 CC_CosTime;

//blur 之后 混合两张图片
//sin blur 即可

vec4 lerp(vec4 a, vec4 b, float d) {
    return a*(1.0-d)+b*d;
}

void main() {
    vec4 sum = vec4(0);
    vec2 uv = v_texCoord;
    uv.x = uv.x+0.004*sin(CC_Time.g+uv.x);
    uv.y = uv.y+0.004*sin(CC_Time.g+uv.y);
    for(int i=-4; i<4; i++) {
        for(int j=-4; j<4; j++) {
            sum += texture2D(CC_Texture0, uv+vec2(j, i)*0.001)*0.010;
        }
    }
    /*
    if (sum.w > 0) {
        sum.w = 0.5;
    }
    */
    //sin 影响透明度
    gl_FragColor = sum;
}
