
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 canvasSize;

void main() {
	
	vec4 canvasColour = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec2 transColourPos = (v_vTexcoord * canvasSize);
	vec3 transColour = vec3(floor(mod(transColourPos.x + floor(mod(transColourPos.y, 16.0) / 8.0) * 8.0, 16.0) / 8.0) * 0.2 + 0.35);
	
	gl_FragColor = vec4(canvasColour.rgb + transColour * (1.0 - canvasColour.a), 1.0);
	
}
