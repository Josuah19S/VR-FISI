shader_type sky;


uniform float Exponer       :  hint_range(0.0, 2.0, 0.1) = 1.3;
uniform float TonoMapa      :  hint_range(0.0, 3.0) = 0.0;
uniform float NivelContraste:  hint_range(0.0, 1.0) = 0.4;
uniform vec4 ColorFondo     =  vec4(0.3, 0.3, 0.3, 1.0);


uniform float _OscuridadAtmosfera : hint_range(0.0, 3.0) = 0.936;
uniform float _ItensidadSol       : hint_range(20.0, 100.0, 0.1) = 30.0;
uniform float _EspesorAtmosfera   : hint_range(0.5, 5.0, 0.1) = 1.0;
uniform vec4 _ColorDiaAtmosfera   = vec4(1.0);
uniform vec4 _ColorNocheAtmosfera = vec4(0.02, 0.03, 0.04, 1.0);
uniform vec4 _ColorHorizonte      = vec4(0.980392, 0.635294, 0.462745, 1.0);
uniform vec3 _AtmosferaParametros = vec3(1.0, 0.0, 0.0);


uniform float _SolTamanio     : hint_range(0.0, 1.0, 0.01) = 0.01;
uniform float _SolIntensidad  : hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float _SolBrillo      : hint_range(0.0, 0.9999999) = 0.8;
uniform vec4 _SolColor        = vec4(1.0);


uniform vec4  sol_color_disco      = vec4(0.99, 0.49, 0.22, 1.0);
uniform float sol_intensidad_disco = 1.3;
uniform float sol_tamanio_disco    = 0.009;

const float kPI4    = 12.5663706; // PI(π)*4.
const float k3PI16  = 0.0596831;  // 3/(PI(π)*16).

const float LONGITUD_DEL_RAYO = 8.4e3;
const float LONGITUD_CENITAL = 1.25e3;

const highp vec3 RayosBeta = vec3(5.807035e-06, 1.356874e-05, 3.312679e-05); // 680, 550, 440

const vec3 BetaSol = vec3(0.000434);

float saturacion(float x){
	return clamp(x, 0.0 , 1.0);
}

vec3 saturacionRGB(vec3 rgb){
	return clamp(rgb, 0.0, 1.0);
}

vec3 nivelConstraste(vec3 vec, float nivel){
	return mix(vec, vec * vec * vec, nivel);
}

vec3 tonoMapa(vec3 color, float exposicion, float nivel){
	color.rgb *= exposicion;
	return mix(color.rgb, 1.0 - exp2(-color.rgb), nivel);
}

float discoSol(vec3 norm, vec3 coords, lowp float size){
	float dist = length(norm - coords);
	return 1.0 - step(size, dist);
}

float faceDelRayo(float mu){
	return k3PI16 * (1.0 + mu * mu);
}

vec3 faceParcialSol(in float g){
	vec3 ret; 
	float g2 = g * g;
	ret.x = (1.0 - g2);
	ret.y = (1.0 + g2);
	ret.z = (2.0 * g);
	return ret;
}

float faceSol(float mu, float g)
{
	vec3 partial = faceParcialSol(g);
	return (kPI4 * partial.x * ((1.0 + mu * mu) * 
		pow(partial.y - (partial.z * mu), -1.5))) * _SolIntensidad;
}

void profundidadOpticaSimple(float y, out float sr, out float sm){
	y = max(0.03, y + 0.03) + _AtmosferaParametros.y;
	y = 1.0 / (y * _AtmosferaParametros.x);
	sr = y * LONGITUD_DEL_RAYO;
	sm = y * LONGITUD_CENITAL;
}

vec3 dispersionAtmosferica(float sr, float sm, float mu, vec3 mult){
	vec3 sol_beta = BetaSol * 0.0001 * _SolTamanio;
	vec3 rayos_beta = RayosBeta * _EspesorAtmosfera;
	
	vec3 extcFactor = saturacionRGB(exp(-(rayos_beta * sr + sol_beta * sm)));
	
	float extcFF = mix(saturacion(_EspesorAtmosfera * 0.5), 1.0, mult.x);
	vec3 factor_extc_final = mix(1.0 - extcFactor, (1.0 - extcFactor) * extcFactor, extcFF);
	float face_de_rayos = faceDelRayo(mu);
	vec3 BRT = rayos_beta * face_de_rayos;
	vec3 BMT = sol_beta * faceSol(mu, _SolBrillo);
	BMT *= _SolIntensidad * _SolColor.rgb;
	
	vec3 BRMT = (BRT + BMT) / (rayos_beta + sol_beta);
	vec3 dispersion = _ItensidadSol * (BRMT * factor_extc_final) * _ColorDiaAtmosfera.rgb * mult.y;
	dispersion = mix(dispersion, dispersion * (1.0 - extcFactor), _OscuridadAtmosfera);
	
	vec3 lcol =  mix(_ColorDiaAtmosfera.rgb, _ColorHorizonte.rgb, mult.x);
	vec3 n_dispersion = (1.0 - extcFactor) * _ColorNocheAtmosfera.rgb;

	return (dispersion * lcol) + n_dispersion;
}

void sky(){
	if (LIGHT0_ENABLED) {
		vec4 anglesMult;
		anglesMult.x = saturacion(1.0 - LIGHT0_DIRECTION.y);
		anglesMult.y = saturacion(LIGHT0_DIRECTION.y + 0.45);
		anglesMult.z = saturacion(-LIGHT0_DIRECTION.y + 0.30);
		anglesMult.w = saturacion(LIGHT0_DIRECTION.y);
		
		float y        = dot( vec3(0.0, 1.0, 0.0), EYEDIR);// + _AtmosHorizonOffset;
		float cosTheta = dot(normalize(LIGHT0_DIRECTION), EYEDIR);
		

		float sr; float sm; profundidadOpticaSimple(y, sr, sm);
		vec3 dispersion = dispersionAtmosferica(sr, sm, cosTheta, anglesMult.xyz);
		

		dispersion += discoSol(EYEDIR, LIGHT0_DIRECTION, sol_tamanio_disco) * sol_color_disco.rgb *
			sol_intensidad_disco * dispersion;
		
		vec3 color_final = mix(dispersion, ColorFondo.rgb * anglesMult.w, saturacion(-y * 100.0) * ColorFondo.a);
		
		color_final.rgb = tonoMapa(color_final, Exponer, TonoMapa);
		color_final.rgb = nivelConstraste(color_final, NivelContraste);
		
		COLOR = color_final;
	}
}