#ifdef GL_ES
precision lowp float;
#endif
varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D CC_Texture0;


//uniform float CC_Time;
//uniform float CC_SinTime;
//uniform float CC_CosTime;

void main() {
    vec2 uv = vec2(v_texCoord);
    if(uv.y <= 0.35f) {
        uv.x = uv.x+0.07*min((0.35f-uv.y), 0.1)*sin(10*(CC_Time+uv.y+sin(uv.x)));
    }
	gl_FragColor =  v_fragmentColor*texture2D(CC_Texture0, uv);
    //* u_color;
}
