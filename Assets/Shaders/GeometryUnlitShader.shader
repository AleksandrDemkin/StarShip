Shader "MyShaders/GeometryUnlitShader"
{
    Properties
    {
        _Tex1 ("Texture", 2D) = "white" {} //texture
        _Tex2 ("Texture", 2D) = "white" {}
        _MixValue("MixValue", Range(0,1)) = 0.5 //texture mix parameter
        _Color("Main Color", COLOR) = (1,1,1,1) //staining color
        _Height("Height", Range(0,20)) = 0.75 //bending force
        _MyFloat1 ("My float1", Float) = 2
        _MyFloat2 ("My float2", Float) = 3

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
            float _Height; //bending force

            float _MyFloat1;
            float _MyFloat2;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f //struct converts vertexes date to fragment data
            {
                float2 uv : TEXCOORD0; // vertex UV-coordinates 
                float4 vertex : SV_POSITION; //vertex coordinates
            };

            v2f vert (appdata_full v) //vertex processing
            {
                v2f result;
                //v.vertex.y += _Height; //move up
                //v.vertex.xyz += v.normal * _Height; // increase texture size
                //v.vertex.xyz += v.normal * _Height * v.texcoord.x;// one side move up x
                //v.vertex.xyz += v.normal * _Height * v.texcoord.x * v.texcoord.x; // one side move up x
                //v.vertex.x -= v.normal * _Height * v.texcoord.x * v.texcoord.x * v.texcoord.x;
                v.vertex.xyz -= cos(2+(v.normal * _Height *  v.texcoord.y));
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
