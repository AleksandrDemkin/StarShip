Shader "MyShaders/UnlitTextureMix"
{
    Properties
    {
        _Tex1 ("Texture", 2D) = "white" {} //texture
        _Tex2 ("Texture", 2D) = "white" {}
        _MixValue("MixValue", Range(0,1)) = 0.5 //texture mix parameter
        _Color("Main Color", COLOR) = (1,1,1,1) //staining color
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" } //tag of opaque shader
        LOD 100 //minimum LOD

        Pass
        {
            CGPROGRAM
            #pragma vertex vert //directive for vertexes processing
            #pragma fragment frag //directive for fragments processing

            #include "UnityCG.cginc" //library

            sampler2D _Tex1; //texture
            float4 _Tex1_ST;
            sampler2D _Tex2; //texture
            float4 _Tex2_ST;
            float _MixValue; //mix parameter
            float4 _Color; //staining color

            struct v2f //struct converts vertexes date to fragment data
            {
                float2 uv : TEXCOORD0; // vertex UV-coordinates 
                float4 vertex : SV_POSITION; //vertex coordinates
            };

            v2f vert (appdata_full v) //vertex processing
            {
                v2f result;
                result.vertex = UnityObjectToClipPos(v.vertex); //find vertex position, local vertex coordinates => world coordinates 
                result.uv = TRANSFORM_TEX(v.texcoord, _Tex1); //find UV-coordinates
                return result;
            }

            fixed4 frag (v2f i) : SV_Target //pixels processing, get v2f, return fixed4
            {
                fixed4 color = tex2D(_Tex1, i.uv) * _MixValue; //UV-coordinates and texture => pixel color on the texture
                color += tex2D(_Tex2, i.uv) * (1 - _MixValue);
                color = color * _Color;
                return color;
            }
            ENDCG
        }
    }
}
