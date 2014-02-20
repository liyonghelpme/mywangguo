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
    int i, j;
    vec4 sum = vec4(0);
    for(i=-4; i<4; i++) {
        for(j=-3; j<3; j++) {
            sum += texture2D(CC_Texture0, v_texCoord+vec2(j, i)*0.004)*0.15;
        }
    }
    vec4 newCol;
    vec4 col = texture2D(CC_Texture0, v_texCoord);
    if(col.r < 0.3) {
        newCol = sum*sum*0.012+col;
    }else {
        if(col.r < 0.5) {
            newCol = sum*sum*0.009 + col;
        }else {
            newCol = sum*sum*0.0075 + col;
        }
    }
    gl_FragColor = lerp(newCol, col, (sin(CC_Time.g*5.0)+1.0)/2.0);
}
