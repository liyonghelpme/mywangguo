attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;
#ifdef GL_ES
varying mediump vec2 v_texCoord;
varying lowp vec4 v_fragmentColor;
varying mediump vec2 v_alphaCoord;
#else
varying vec2 v_texCoord;
varying vec4 v_fragmentColor;
varying vec2 v_alphaCoord;
#endif

void main(){
    gl_Position = CC_MVPMatrix * a_position;
    v_texCoord = a_texCoord * vec2(1.0, 0.5);
    v_alphaCoord = v_texCoord+vec2(0.0, 0.5);
    v_fragmentColor = a_color;
}
