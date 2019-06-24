using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
sealed class NoiseBall : MonoBehaviour
{
    #region Editable attributes

    [SerializeField] Material _material = null;

    [SerializeField] int _triangleCount = 100;

    public int triangleCount {
        get { return _triangleCount; }
        set { _triangleCount = value; }
    }

    [SerializeField] float _triangleExtent = 0.1f;

    public float triangleExtent {
        get { return _triangleExtent; }
        set { _triangleExtent = value; }
    }

    [SerializeField] float _shuffleSpeed = 4;

    public float shuffleSpeed {
        get { return _shuffleSpeed; }
        set { _shuffleSpeed = value; }
    }

    [SerializeField] float _noiseAmplitude = 1;

    public float noiseAmplitude {
        get { return _noiseAmplitude; }
        set { _noiseAmplitude = value; }
    }

    [SerializeField] float _noiseFrequency = 1;

    public float noiseFrequency {
        get { return _noiseFrequency; }
        set { _noiseFrequency = value; }
    }

    [SerializeField] Vector3 _noiseMotion = Vector3.up;

    public Vector3 noiseMotion {
        get { return _noiseMotion; }
        set { _noiseMotion = value; }
    }

    #endregion

    #region MonoBehaviour functions

    MaterialPropertyBlock _props;

    void OnValidate()
    {
        _triangleCount = Mathf.Max(0, _triangleCount);
        _triangleExtent = Mathf.Max(0, _triangleExtent);
        _noiseFrequency = Mathf.Max(0, _noiseFrequency);
    }

    void Update()
    {
        if (_props == null) _props = new MaterialPropertyBlock();

        var time = Application.isPlaying ? Time.time : 3.3333f;

        _props.SetInt("_TriangleCount", _triangleCount);
        _props.SetFloat("_LocalTime", time * _shuffleSpeed);
        _props.SetFloat("_Extent", _triangleExtent);
        _props.SetFloat("_NoiseAmplitude", _noiseAmplitude);
        _props.SetFloat("_NoiseFrequency", _noiseFrequency);
        _props.SetVector("_NoiseOffset", _noiseMotion * time);
        _props.SetMatrix("_LocalToWorld", transform.localToWorldMatrix);

        Graphics.DrawProcedural(
            _material,
            new Bounds(transform.position, transform.lossyScale * 5),
            MeshTopology.Triangles, _triangleCount * 3, 1,
            null, _props,
            ShadowCastingMode.TwoSided, true, gameObject.layer
        );
    }

    #endregion
}
