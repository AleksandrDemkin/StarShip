using UnityEngine;

namespace ShaderTest
{
    public class ShaderTest1 : MonoBehaviour
    {
        [SerializeField] private Material _material;

        private void Start()
        {
            _material.SetColor("Color", Color.white);

            float height = _material.GetFloat("_MixValue");
        }
    }
}
