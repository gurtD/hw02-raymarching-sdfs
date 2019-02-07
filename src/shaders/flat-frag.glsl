#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;
uniform float u_Movement;
uniform float u_ColorChange;

in vec2 fs_Pos;
out vec4 out_Col;


const float EPSILON = 0.01;

vec3 ray_dir() {
  float t =  0.1;
  vec3 f = normalize(u_Ref - u_Eye);
  vec3 r = normalize(cross(f, u_Up));
  float len =  length(u_Ref - u_Eye);
  float fovy = 90.0;
  float alpha = fovy / 2.0;
  vec3 V = u_Up * len * tan(alpha);
  vec3 H = r * len * u_Dimensions.x / u_Dimensions.y * tan(alpha);
  vec3 P = u_Ref + fs_Pos.x * H + fs_Pos.y * V;
  return normalize(P - u_Eye);
  
}

float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); }

float opSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h); }

float opSmoothIntersection( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) + k*h*(1.0-h); }

float sphere1SDF( vec3 p ) {
  mat4 translate = mat4(
   1.0, 0.0, 0.0, 0.0, // first column (not row!)
   0.0, 1.0, 0.0, 0.0,// second column
   0.0, 0.0, 1.0, 0.0,// third column
   sin( u_Movement / 50.0) * 10.0, 0.0, 0.0, 1.0
);
  return length((inverse(translate) * vec4(p, 1.0)).xyz) - 3.0;
}

float sphere2SDF( vec3 p ) {
  mat4 translate = mat4(
   1.0, 0.0, 0.0, 0.0, // first column (not row!)
   0.0, 1.0, 0.0, 0.0,// second column
   0.0, 0.0, 1.0, 0.0,// third column
   0.0, sin(u_Movement / 50.0) * 10.0, 0.0, 1.0
);
  return length((inverse(translate) * vec4(p, 1.0)).xyz) - 3.0;
}

float roundBoxSDF( vec3 p)
{
  vec3 d = abs(p) - 5.0;
  return length(max(d,0.0)) - 2.0
         + min(max(d.x,max(d.y,d.z)),0.0); // remove this line for an only partially signed sdf 
}

float innerBoxSDF1( vec3 p)
{
  mat4 translate = mat4(
   2.0, 0.0, 0.0, 0.0, // first column (not row!)
   0.0, 0.8, 0.0, 0.0,// second column
   0.0, 0.0, 0.8, 0.0,// third column
   0.0, 0.0, 0.0, 1.0
);
  vec3 d = abs((inverse(translate) * vec4(p, 1.0)).xyz) - 5.0;
  return length(max(d,0.0))
         + min(max(d.x,max(d.y,d.z)),0.0); // remove this line for an only partially signed sdf 
}

float innerBoxSDF2( vec3 p)
{
  mat4 translate = mat4(
   0.8, 0.0, 0.0, 0.0, // first column (not row!)
   0.0, 2.0, 0.0, 0.0,// second column
   0.0, 0.0, 0.8, 0.0,// third column
   0.0, 0.0, 0.0, 1.0
);
  vec3 d = abs((inverse(translate) * vec4(p, 1.0)).xyz) - 5.0;
  return length(max(d,0.0))
         + min(max(d.x,max(d.y,d.z)),0.0); // remove this line for an only partially signed sdf 
}

float innerBoxSDF3( vec3 p)
{
  mat4 translate = mat4(
   0.8, 0.0, 0.0, 0.0, // first column (not row!)
   0.0, 0.8, 0.0, 0.0,// second column
   0.0, 0.0, 2.0, 0.0,// third column
   0.0, 0.0, 0.0, 1.0
);
  vec3 d = abs((inverse(translate) * vec4(p, 1.0)).xyz) - 5.0;
  return length(max(d,0.0))
         + min(max(d.x,max(d.y,d.z)),0.0); // remove this line for an only partially signed sdf 
}

bool boundingBox ( vec3 p ) {
  if ( p.x >= -12.5 && p.y >= -12.5 && p.z >= -12.5 && p.x <= 12.5 && p.y <= 12.5 && p.z <= 12.5 ) {
    return true;
  }
  return false;
}

bool sphere1BoundingBox ( vec3 p ) {
   mat4 translate = mat4(
   1.0, 0.0, 0.0, 0.0, // first column (not row!)
   0.0, 1.0, 0.0, 0.0,// second column
   0.0, 0.0, 1.0, 0.0,// third column
   sin(u_Time / 500.0) * 10.0, 0.0, 0.0, 1.0
);
  vec3 q = (inverse(translate) * vec4(p, 1.0)).xyz;
  if ( q.x >= -3.0 && q.y >= -3.0 && q.z >= -3.0 && q.x <= 3.0 && q.y <= 3.0 && q.z <= 3.0 ) {
    return true;
  }
  return false;
}

bool sphere2BoundingBox ( vec3 p ) {
  mat4 translate = mat4(
   1.0, 0.0, 0.0, 0.0, // first column (not row!)
   0.0, 1.0, 0.0, 0.0,// second column
   0.0, 0.0, 1.0, 0.0,// third column
   0.0, sin(u_Time / 500.0) * 10.0, 0.0, 1.0
);
  vec3 q = (inverse(translate) * vec4(p, 1.0)).xyz;
  if ( q.x >= -3.0 && q.y >= -3.0 && q.z >= -3.0 && q.x <= 3.0 && q.y <= 3.0 && q.z <= 3.0 ) {
    return true;
  }
  return false;
}

float sceneSDF( vec3 p ) {
  if ( boundingBox(p) ) {
    
    float rectIntersect1 = opSmoothUnion(innerBoxSDF1(p), innerBoxSDF2(p), 1.0);
    float rectIntersect2 = opSmoothUnion(rectIntersect1, innerBoxSDF3(p), 1.0);
    float squareCage = opSmoothSubtraction(rectIntersect2, roundBoxSDF(p), 1.0);
    return opSmoothUnion(min(opSmoothUnion(sphere1SDF(p), sphere2SDF(p), 0.75), 1e10), squareCage, 1.0);
    //float sphereIntersection = 1e10;
    bool sphere1Hit = sphere1BoundingBox(p);
    bool sphere2Hit = sphere2BoundingBox(p);

    if (sphere1Hit && sphere2Hit) {
      return opSmoothUnion(min(opSmoothUnion(sphere1SDF(p), sphere2SDF(p), 0.75), 1e10), squareCage, 1.0);
    } else if (sphere1Hit) {
      //return sphere1SDF(p);
      return opSmoothUnion(min(sphere1SDF(p), 1e10), squareCage, 1.0);
    } else if (sphere2Hit) {
      //return sphere2SDF(p);
      return opSmoothUnion(min(sphere2SDF(p), 1e10), squareCage, 1.0);
    } else {
      return squareCage;
    }

    

    //return opSmoothUnion(min(opSmoothUnion(sphere1SDF(p), sphere2SDF(p), 0.75), 1e10), squareCage, 1.0);

  }
  return 0.1;
  }



float march() {
  float t = 0.0;
  float dt = 0.1;
  vec3 dir = ray_dir();
  for ( int i = 0; i < 200; i++ ) {
    vec3 ray = u_Eye + dir * t;
    float dist = sceneSDF(ray);
    
    if (dist < EPSILON) {
      return t;
    }
    else {
      t += dist;
    }

    
  }

  return -1.0;
}

vec3 estimateNormal(vec3 p) {
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z)) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z)) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(vec3(p.x, p.y, p.z  + EPSILON)) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON))
    ));
}

void main() {
  
  float d = march();
  vec3 normal = estimateNormal(u_Eye + d * ray_dir());
  
  if (d >= 0.0) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(2.0, 1.0, 0.0);
    vec3 d = vec3(0.5, 0.2, 0.25);
    vec4 diffuseColor = vec4(a + b * cos( 6.28318 * (c * sin(u_ColorChange / 50.0) + d)), 1.0);
    float diffuseTerm = dot(normalize(normal), normalize(u_Eye));
    diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);
    float ambientTerm = 0.4;
    float lightIntensity = diffuseTerm + ambientTerm;

    out_Col = vec4(diffuseColor.rgb * lightIntensity, 1.0);
  } else {
    out_Col = vec4(0.5 * (ray_dir() + vec3(1.0, 1.0, 1.0)), 1.0);
  }

  
  //out_Col = vec4(0.5 * (fs_Pos + vec2(1.0)), 0.5 * (sin(u_Time * 3.14159 * 0.01) + 1.0), 1.0);
  //out_Col = vec4(0.5 * (ray_dir() + vec3(1.0, 1.0, 1.0)), 1.0);
}
