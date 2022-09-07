Shader "MyShaders/AtmosphereShader"
{
    Properties
    {
        _Tex1 ("Texture", 2D) = "white" {} //texture
        _Tex2 ("Texture", 2D) = "white" {}
        _Tex3 ("Texture", 2D) = "white" {}
        _Tex4 ("Texture", 2D) = "white" {}
        _MixValue("MixValue", Range(0,1)) = 0.5
        _MixValue2("MixValue2", Range(0,1)) = 0.5
        _Color("Main Color", COLOR) = (1,1,1,1) //staining color
        _Color2("Main Color2", COLOR) = (1,1,1,1) //staining color
        _Height("Height", Range(0,5)) = 0.5 //bending force
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" } //tag of opaque shader
        LOD 100 //minimum LOD

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _Tex1; //texture
            float4 _Tex1_ST;

            sampler2D _Tex2;
            float4 _Tex2_ST;
                        
            float _MixValue; //mix parameter
            float4 _Color; //staining color
            float _Height; //bending force

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_full v)
            {
                v2f result;
                v.vertex.xyz += v.normal * _Height;
                //v.vertex.y += _Height;
                result.vertex = UnityObjectToClipPos(v.vertex); //find vertex position, local vertex coordinates => world coordinates 
                result.uv = TRANSFORM_TEX(v.texcoord, _Tex1); //find UV-coordinates
                return result;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_Tex1, i.uv) * _MixValue; //UV-coordinates and texture => pixel color on the texture
                color += tex2D(_Tex2, i.uv) * (1 - _MixValue);
                color = color * _Color;
                return color;
            }
            ENDCG
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _Tex3; //texture
            float4 _Tex3_ST;

            sampler2D _Tex4; //texture
            float4 _Tex4_ST;
            
            float _MixValue2; //mix parameter
            float4 _Color2; //staining color
            float _Height; //bending force

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_full v)
            {
                v2f result;
                v.vertex.xyz += v.normal * _Height;
                result.vertex = UnityObjectToClipPos(v.vertex); //find vertex position, local vertex coordinates => world coordinates 
                result.uv = TRANSFORM_TEX(v.texcoord, _Tex3); //find UV-coordinates
                return result;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_Tex3, i.uv) * _MixValue2; //UV-coordinates and texture => pixel color on the texture
                color += tex2D(_Tex4, i.uv) * (1 - _MixValue2);
                color = color * _Color2;
                return color;
            }
            ENDCG
        }
    }
}
