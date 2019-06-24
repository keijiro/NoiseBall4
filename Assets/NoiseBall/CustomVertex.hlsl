#include "SimplexNoise3D.hlsl"

uint _TriangleCount;
float _LocalTime;
float _Extent;
float _NoiseAmplitude;
float _NoiseFrequency;
float3 _NoiseOffset;
float4x4 _LocalToWorld;

// Random point on an unit sphere
float3 RandomPoint(uint seed)
{
    float u = Hash(seed * 2 + 0) * PI * 2;
    float z = Hash(seed * 2 + 1) * 2 - 1;
    return float3(float2(cos(u), sin(u)) * sqrt(1 - z * z), z);
}

// Vertex input attributes
struct Attributes
{
    uint vertexID : SV_VertexID;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

// Custom vertex shader
PackedVaryingsType CustomVert(Attributes input)
{

    uint t_idx = input.vertexID / 3;         // Triangle index
    uint v_idx = input.vertexID - t_idx * 3; // Vertex index

    // Time dependent random number seed
    uint seed = _LocalTime + (float)t_idx / _TriangleCount;
    seed = ((seed << 16) + t_idx) * 4;

    // Random triangle on unit sphere
    float3 v1 = RandomPoint(seed + 0);
    float3 v2 = RandomPoint(seed + 1);
    float3 v3 = RandomPoint(seed + 2);

    // Constraint with the extent parameter
    v2 = normalize(v1 + normalize(v2 - v1) * _Extent);
    v3 = normalize(v1 + normalize(v3 - v1) * _Extent);

    // Displacement by noise field
    float l1 = snoise(v1 * _NoiseFrequency + _NoiseOffset);
    float l2 = snoise(v2 * _NoiseFrequency + _NoiseOffset);
    float l3 = snoise(v3 * _NoiseFrequency + _NoiseOffset);

    l1 = abs(l1 * l1 * l1);
    l2 = abs(l2 * l2 * l2);
    l3 = abs(l3 * l3 * l3);

    v1 *= 1 + l1 * _NoiseAmplitude;
    v2 *= 1 + l2 * _NoiseAmplitude;
    v3 *= 1 + l3 * _NoiseAmplitude;

    // Vertex position/normal vector
    float3 pos = v_idx == 0 ? v1 : (v_idx == 1 ? v2 : v3);
    float3 norm = normalize(cross(v2 - v1, v3 - v2));

    // Apply the transform matrix.
    pos = mul(_LocalToWorld, float4(pos, 1)).xyz;
    norm = mul((float3x3)_LocalToWorld, norm);

    // Imitate a common vertex input.
    AttributesMesh am;
    am.positionOS = pos;
#ifdef ATTRIBUTES_NEED_NORMAL
    am.normalOS = norm;
#endif
#ifdef ATTRIBUTES_NEED_TANGENT
    am.tangentOS = 0;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD0
    am.uv0 = 0;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD1
    am.uv1 = 0;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD2
    am.uv2 = 0;
#endif
#ifdef ATTRIBUTES_NEED_TEXCOORD3
    am.uv3 = 0;
#endif
#ifdef ATTRIBUTES_NEED_COLOR
    am.color = 0;
#endif
    UNITY_TRANSFER_INSTANCE_ID(input, am);

    // Throw it into the default vertex pipeline.
    VaryingsType varyingsType;
    varyingsType.vmesh = VertMesh(am);
    return PackVaryingsType(varyingsType);
}
