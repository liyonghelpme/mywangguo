#ifdef GL_ES
precision lowp float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D CC_Texture0;


//uniform vec4 CC_Time;  time/10 time time*2 time*4
//uniform vec4 CC_SinTime;
//uniform vec4 CC_CosTime;

//blur 之后 混合两张图片
//sin blur 即可

vec4 lerp(vec4 a, vec4 b, float d) {
    return a*(1.0-d)+b*d;
}

void main() {
    vec2 uv = vec2(v_texCoord);
    float v = 0.001*(1.0-abs(uv.x-uv.y))*sin(5.0*(CC_Time.g+sqrt(uv.y*uv.y+uv.x*uv.x)));
    uv.x = uv.x+v*0.707;
    uv.y = uv.y+v*0.707; 

    /*
    float v = mod((CC_Time.g+sqrt(uv.y*uv.y+uv.x*uv.x)), 1.0);
    uv.x = uv.x+v;
    uv.y = uv.y+v; 
    */

    gl_FragColor = texture2D(CC_Texture0, uv);

}
