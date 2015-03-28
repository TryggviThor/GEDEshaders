Shader "GLSLToon" {
   Properties {
      _Color ("Diffuse Color", Color) = (1,1,1,1) 
      _UnlitColor ("Unlit Diffuse Color", Color) = (0.5,0.5,0.5,1) 
      _DiffuseThreshold ("Threshold for Diffuse Colors", Range(0,1)) = 0.1 
      _OutlineColor ("Outline Color", Color) = (0,0,0,1)
      _LitOutlineThickness ("Lit Outline Thickness", Range(0,1)) = 0.1
      _UnlitOutlineThickness ("Unlit Outline Thickness", Range(0,1)) = 0.4
      _SpecColor ("Specular Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 10
      _MainTex ("Base (RGB)", 2D) = "white" {}
   }
   SubShader {
      Pass {      
         Tags { "LightMode" = "ForwardBase" } 
            // pass for ambient light and first light source
 
         GLSLPROGRAM
 
         // User-specified properties
         uniform vec4 _Color; 
         uniform vec4 _UnlitColor;
         uniform float _DiffuseThreshold;
         uniform vec4 _OutlineColor;
         uniform float _LitOutlineThickness;
         uniform float _UnlitOutlineThickness;
         uniform vec4 _SpecColor; 
         uniform float _Shininess;
         
 
         // The following built-in uniforms (except _LightColor0) 
         // are also defined in "UnityCG.glslinc", 
         // i.e. one could #include "UnityCG.glslinc" 
         uniform vec3 _WorldSpaceCameraPos; 
            // camera position in world space
         uniform mat4 _Object2World; // model matrix
         uniform mat4 _World2Object; // inverse model matrix
         uniform vec4 _WorldSpaceLightPos0; 
            // direction to or position of light source
         uniform vec4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         varying vec4 position; 
            // position of the vertex (and fragment) in world space 
         varying vec3 varyingNormalDirection; 
            // surface normal vector in world space
            
         // Texture variables
         uniform sampler2D _MainTex;   
         varying vec4 TextureCoordinate;
 
         #ifdef VERTEX
 
         void main()
         {                                
            mat4 modelMatrix = _Object2World;
            mat4 modelMatrixInverse = _World2Object; // unity_Scale.w 
               // is unnecessary because we normalize vectors
 
            position = modelMatrix * gl_Vertex;
            varyingNormalDirection = normalize(vec3(vec4(gl_Normal, 0.0) * modelMatrixInverse));
 
            gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            TextureCoordinate = gl_MultiTexCoord0;
         }
 
         #endif
 
         #ifdef FRAGMENT
 
         void main()
         {
            vec3 normalDirection = normalize(varyingNormalDirection);
 
            vec3 viewDirection = normalize(_WorldSpaceCameraPos - vec3(position));
            vec3 lightDirection;
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = normalize(vec3(_WorldSpaceLightPos0));
            } 
            else // point or spot light
            {
               vec3 vertexToLightSource = vec3(_WorldSpaceLightPos0 - position);
               float distance = length(vertexToLightSource);
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            // default: unlit
            //vec3 fragmentColor = vec3(_UnlitColor); 
            vec3 fragmentColor = vec3(_UnlitColor) * vec3(texture2D(_MainTex, vec2(TextureCoordinate))); 
 
            // low priority: diffuse illumination
            if (attenuation * max(0.0, dot(normalDirection, lightDirection)) 
               >= _DiffuseThreshold)
            {
               //fragmentColor = vec3(_LightColor0) * vec3(_Color);
               fragmentColor = vec3(texture2D(_MainTex, vec2(TextureCoordinate))); //Svona verður diffuse hlutinn aðeins of bjartur, eins og i flat shadernum...
            }
 
            // higher priority: outline
            if (dot(viewDirection, normalDirection) 
               < mix(_UnlitOutlineThickness, _LitOutlineThickness, max(0.0, dot(normalDirection, lightDirection))))
            {
               //fragmentColor = vec3(_LightColor0) * vec3(_OutlineColor); 
               fragmentColor = vec3(_LightColor0) * vec3(_OutlineColor); 
            }
 
            // highest priority: highlights
            if (dot(normalDirection, lightDirection) > 0.0 
               // light source on the right side?
               && attenuation *  pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess) > 0.5) 
               // more than half highlight intensity? 
            {
               //fragmentColor = _SpecColor.a * vec3(_LightColor0) * vec3(_SpecColor) + (1.0 - _SpecColor.a) * fragmentColor;
               fragmentColor = _SpecColor.a * vec3(_LightColor0) * vec3(_SpecColor) + (1.0 - _SpecColor.a) * fragmentColor * vec3(texture2D(_MainTex, vec2(TextureCoordinate)));
            }
 
            gl_FragColor = vec4(fragmentColor, 1.0);
         }
 
         #endif
 
         ENDGLSL
      }
 
      Pass {      
         Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources
         Blend SrcAlpha OneMinusSrcAlpha 
            // blend specular highlights over framebuffer
 
         GLSLPROGRAM
 
         // User-specified properties
         uniform vec4 _Color; 
         uniform vec4 _UnlitColor;
         uniform float _DiffuseThreshold;
         uniform vec4 _OutlineColor;
         uniform float _LitOutlineThickness;
         uniform float _UnlitOutlineThickness;
         uniform vec4 _SpecColor; 
         uniform float _Shininess;
         
 
         // The following built-in uniforms (except _LightColor0) 
         // are also defined in "UnityCG.glslinc", 
         // i.e. one could #include "UnityCG.glslinc" 
         uniform vec3 _WorldSpaceCameraPos; 
            // camera position in world space
         uniform mat4 _Object2World; // model matrix
         uniform mat4 _World2Object; // inverse model matrix
         uniform vec4 _WorldSpaceLightPos0; 
            // direction to or position of light source
         uniform vec4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         varying vec4 position; 
            // position of the vertex (and fragment) in world space 
         varying vec3 varyingNormalDirection; 
            // surface normal vector in world space
 
 		 // Texture variables
 		 uniform sampler2D _MainTex;
 		 varying vec4 TextureCoordinate;
 		 
         #ifdef VERTEX
 
         void main()
         {                                
            mat4 modelMatrix = _Object2World;
            mat4 modelMatrixInverse = _World2Object; // unity_Scale.w 
               // is unnecessary because we normalize vectors
 
            position = modelMatrix * gl_Vertex;
            varyingNormalDirection = normalize(vec3(vec4(gl_Normal, 0.0) * modelMatrixInverse));
 
            gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            TextureCoordinate = gl_MultiTexCoord0;
         }
 
         #endif
 
         #ifdef FRAGMENT
 
         void main()
         {
            vec3 normalDirection = normalize(varyingNormalDirection);
 
            vec3 viewDirection = normalize(_WorldSpaceCameraPos - vec3(position));
            vec3 lightDirection;
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = normalize(vec3(_WorldSpaceLightPos0));
            } 
            else // point or spot light
            {
               vec3 vertexToLightSource = vec3(_WorldSpaceLightPos0 - position);
               float distance = length(vertexToLightSource);
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            vec4 fragmentColor = texture2D(_MainTex, vec2(TextureCoordinate));
            if (dot(normalDirection, lightDirection) > 0.0 
               // light source on the right side?
               && attenuation *  pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess) > 0.5) 
               // more than half highlight intensity? 
            {
               fragmentColor = vec4(_LightColor0.rgb, 1.0) * _SpecColor;
            }
 
            gl_FragColor = fragmentColor;
         }
 
         #endif
 
         ENDGLSL
      }
   } 
   // The definition of a fallback shader should be commented out 
   // during development:
   Fallback "Specular"
}