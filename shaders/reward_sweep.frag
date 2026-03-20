#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uProgress;
uniform float uIntensity;
uniform vec3 uAccent;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float diagonal = (uv.x * 0.78) + ((1.0 - uv.y) * 0.72);
  float center = mix(-0.35, 1.45, uProgress);
  float distanceToBand = abs(diagonal - center);

  float core = 1.0 - smoothstep(0.0, 0.075, distanceToBand);
  float glow = 1.0 - smoothstep(0.02, 0.24, distanceToBand);

  vec3 warm = mix(vec3(1.0, 0.84, 0.34), uAccent, 0.42);
  vec3 color = (warm * core * 0.95) + (vec3(1.0, 0.97, 0.82) * glow * 0.38);

  float edgeFade =
      smoothstep(0.0, 0.08, uv.x) *
      smoothstep(0.0, 0.12, uv.y) *
      smoothstep(0.0, 0.08, 1.0 - uv.x) *
      smoothstep(0.0, 0.12, 1.0 - uv.y);

  float alpha = ((core * 0.42) + (glow * 0.24)) * uIntensity * edgeFade;
  fragColor = vec4(color, alpha);
}
