#ifdef GL_ES
precision lowp float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
varying vec2 v_alphaCoord;
uniform sampler2D CC_Texture0;


//uniform vec4 CC_Time;  time/10 time time*2 time*4
//uniform vec4 CC_SinTime;
//uniform vec4 CC_CosTime;

//blur 之后 混合两张图片
//sin blur 即可

void main() {
    vec4 col = texture2D(CC_Texture0, v_texCoord);
    col.a = texture2D(CC_Texture0, v_alphaCoord).r;
    gl_FragColor = v_fragmentColor*col;
}
