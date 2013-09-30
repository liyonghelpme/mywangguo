"                                            \n\
#ifdef GL_ES                                \n\
precision mediump float;                      \n\
#endif                                        \n\
                                            \n\
varying vec4 v_fragmentColor;                \n\
varying vec2 v_texCoord;                    \n\
uniform sampler2D u_texture;                \n\
uniform float u_hueOffset;                    \n\
uniform float u_satOffset;                    \n\
uniform float u_valOffset;                    \n\
void main()                              \n\
{                                            \n\
	vec3 rgb = texture2D(u_texture, v_texCoord).rgb;  \n\
	float h=0.0;\n\
	float min = rgb.r;\n\
	if(min>rgb.g)\n\
		min=rgb.g;\n\
	if(min>rgb.b)\n\
		min=rgb.b;\n\
	float max = rgb.r;\n\
	if(max<rgb.g)\n\
		max=rgb.g;\n\
	if(max<rgb.b)\n\
		max=rgb.b;\n\
	float l=(max+min)/2.0;\n\
	float s=0.0;\n\
	if(max>min){\n\
		if(l<0.5)\n\
			s=(max-min)/2.0/l;\n\
		else\n\
			s=(max-min)/2.0/(1.0-l);\n\
		if(max==rgb.r){\n\
			if(rgb.g>rgb.b)\n\
				h=(rgb.g-rgb.b)/(max-min);\n\
			else\n\
				h=(rgb.g-rgb.b)/(max-min) + 6.0;\n\
		}\n\
		else if(max==rgb.g)\n\
			h=(rgb.b-rgb.r)/(max-min) + 2.0;\n\
		else\n\
			h=(rgb.r-rgb.g)/(max-min) + 4.0;\n\
	}\n\
	h=h+u_hueOffset;\n\
	if(h>=6.0)\n\
		h=h-6.0;\n\
	s=s+u_satOffset;\n\
	if(s<0.0)\n\
		s=0.0;\n\
	if(s>1.0)\n\
		s=1.0;\n\
	l=l+u_valOffset*texture2D(u_texture, v_texCoord).a;\n\
	if(l<0.0)\n\
		l=0.0;\n\
	if(l>1.0)\n\
		l=1.0;\n\
	float q=l*(1.0+s);\n\
	if(l>=0.5)\n\
		q=l+s-l*s;\n\
	float p=2.0*l-q;\n\
	if(h<1.0)\n\
		rgb=vec3(q, p+(q-p)*h, p);\n\
	else if(h<2.0)\n\
		rgb=vec3(p+(q-p)*(2.0-h), q, p);\n\
	else if(h<3.0)\n\
		rgb=vec3(p, q, p+(q-p)*(h-2.0));\n\
	else if(h<4.0)\n\
		rgb=vec3(p, p+(q-p)*(4.0-h), q);\n\
	else if(h<5.0)\n\
		rgb=vec3(p+(q-p)*(h-4.0), p, q);\n\
	else\n\
		rgb=vec3(q, p, p+(q-p)*(6.0-h));\n\
	gl_FragColor = v_fragmentColor*vec4(rgb, texture2D(u_texture, v_texCoord).a);            \n\
}";