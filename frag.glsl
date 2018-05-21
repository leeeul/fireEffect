#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture; 
uniform vec2 texOffset;
uniform float time;
uniform vec3 resolution;

varying vec4 vertColor;
varying vec4 vertTexCoord;

vec2 random(vec2 c_){
    float x = fract(sin(dot(c_, vec2(75.8,48.6)))*1e5);
    float y = fract(sin(dot(c_, vec2(85.8,108.6)))*1e5);
    
    vec2 returnVec = vec2(x,y);
    returnVec = returnVec*2.-1.; //벡터값을 0 ~ 1을 -1 ~ 1로 맞춰놓는 작업이다
    return returnVec;
}

float noise(vec2 coord){
    
    vec2 i = floor(coord);
    vec2 f = fract(coord);
    
    f = smoothstep(0., 1., f);
    
    
    float returnVal = mix(    mix( dot(random(i), coord-i),
                                  dot(random(i+vec2(1., 0.)), coord-(i+vec2(1., 0.))),
                                  f.x),
                          mix( dot(random(i+vec2(0., 1.)), coord-(i+vec2(0., 1.))),
                              dot(random(i+vec2(1., 1.)), coord-(i+vec2(1., 1.))),
                              f.x),
                          f.y
                          );
    
    
    return (returnVal);
}

float random_f(vec2 coord){
    return fract(sin(dot(coord, vec2(75.7,65.9)))*1e5); // 0~1
}

vec2 noiseVec2(vec2 coord){
    float time_Speed = 300.; //중요변수1 : 불의 활력을 담당한다
    coord.y -= time*time_Speed;
    return vec2( noise((coord+0.57)), noise((coord+90.43)) );
}

void main() {
    vec2 ncoord = vertTexCoord.xy;
    ncoord.x *= resolution.x/resolution.y;
    
    ncoord *= 4.; //중요변수2 : 불의 자글자글하게 꾸겨짐을 담당한다
    ncoord += noiseVec2(ncoord)*1.;
    ncoord += noiseVec2(ncoord)*3.;
    float f = noise(ncoord);
    float f_save = f;
    f += 1.;
    f /= 2.;
    
    f *= 0.078; // 중요변수3 : 이 값이 커지면 불꽃이 짧아진다.
    
    if(f<0.037){
        f = 0.;
    }
    
    vec2 coord = vertTexCoord.xy;
    float up = 5.5; // 중요변수4 : 불꽃이 위로 올라가는 속도를 관할한다
    vec2 index0 = coord + vec2(texOffset.x*f_save*6.8, -texOffset.y*up);//-texOffset.s, -texOffset.t
    vec2 index1 = index0 + vec2(0., texOffset.y);//-texOffset.s, -texOffset.t
    vec2 index2 = index0 + vec2(-texOffset.x, 0.);//-texOffset.s, -texOffset.t
    vec2 index3 = index0 + vec2(texOffset.x, 0.);//-texOffset.s, -texOffset.t
    vec2 index4 = index0 + vec2(0., -texOffset.y);//-texOffset.s, -texOffset.t
    
    vec3 col1 = texture2D(texture, index1).rgb;
    vec3 col2 = texture2D(texture, index2).rgb;
    vec3 col3 = texture2D(texture, index3).rgb;
    vec3 col4 = texture2D(texture, index4).rgb;
    
    vec3 col = (col1 + col2 + col3 + col4)/4.;
    
    col -= f;
    col = clamp(col, 0., 1.);
    
    gl_FragColor = vec4(col, 1.);
}





