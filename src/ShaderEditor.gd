extends TextEdit

func _ready():
	setup_syntax_highlighting()

func setup_syntax_highlighting():
	for i in keywords:
		add_keyword_color(i, keyword_color)
	for i in constants:
		add_keyword_color(i, special_color)
	
	add_color_region("\"", "\"", string_color, true)
	add_color_region("//", "", comment_color, true)
	add_color_region("#", "", comment_color, true)
	add_color_region("/*", "*/", comment_color, false)

const keyword_color := Color("#ff7085")
const special_color := Color(0.697828, 0.465393, 0.953125)
const comment_color := Color("#80ccced3")
const string_color := Color("#202531")

const keywords := [
	"void",
	"bool",
	"bvec2",
	"bvec3",
	"bvec4",
	"int",
	"ivec2",
	"ivec3",
	"ivec4",
	"uint",
	"uvec2",
	"uvec3",
	"uvec4",
	"float",
	"vec2",
	"vec3",
	"vec4",
	"mat2",
	"mat3",
	"mat4",
	"sampler2D",
	"isampler2D",
	"usampler2D",
	"samplerCube",

	"shader_type",
	"render_mode",
	"canvas_item",
	"spatial",
	"particles",
	
	"if", "else", "for", "while",

	"blend_mix",
	"blend_add",
	"blend_sub",
	"blend_mul",
	"depth_draw_opaque",
	"depth_draw_always",
	"depth_draw_never",
	"depth_draw_alpha_prepass",
	"depth_test_disable",
	"cull_front",
	"cull_back",
	"cull_disabled",
	"unshaded",
	"diffuse_lambert",
	"diffuse_lambert_wrap",
	"diffuse_oren_nayar",
	"diffuse_burley",
	"diffuse_toon",
	"specular_schlick_ggx",
	"specular_blinn",
	"specular_phong",
	"specular_toon",
	"specular_disabled",
	"skip_vertex_transform",
	"world_vertex_coords",
	"vertex_lighting",

	"uniform",
	"varying",
]

const constants := [
	"true", "false",
	
	"lowp", "mediump", "highp",
	"flat", "noperspective", "smooth",
	"in", "out", "inout",
	
	"WORLD_MATRIX",
	"INV_CAMERA_MATRIX",
	"PROJECTION_MATRIX",
	"CAMERA_MATRIX",
	"MODELVIEW_MATRIX",
	"INV_PROJECTION_MATRIX",
	"TIME",
	"VIEWPORT_SIZE",
	"VERTEX",
	"NORMAL",
	"TANGENT",
	"BINORMAL",
	"UV",
	"UV2",
	"COLOR",
	"POINT_SIZE",
	"INSTANCE_ID",
	"INSTANCE_CUSTOM",
	"ROUGHNESS",
	"VELOCITY",
	"MASS",
	"ACTIVE",
	"RESTART",
	"CUSTOM",
	"TRANSFORM",
	"LIFETIME",
	"DELTA",
	"NUMBER",
	"INDEX",
	"EMISSION_TRANSFORM",
	"RANDOM_SEED",
	"VIEWPORT_SIZE",
	"FRAGCOORD",
	"FRONT_FACING",
	"NORMALMAP",
	"NORMALMAP_DEPTH",
	"ALBEDO",
	"ALPHA",
	"METALLIC",
	"SPECULAR",
	"ROUGHNESS",
	"RIM",
	"RIM_TINT",
	"CLEARCOAT",
	"CLEARCOAT_GLOSS",
	"ANISOTROPY",
	"ANISOTROPY_FLOW",
	"SSS_STRENGTH",
	"TRANSMISSION",
	"AO",
	"AO_LIGHT_AFFECT",
	"EMISSION",
	"SCREEN_TEXTURE",
	"DEPTH_TEXTURE",
	"SCREEN_UV",
	"POINT_COORD",
	"ALPHA_SCISSOR",
]
