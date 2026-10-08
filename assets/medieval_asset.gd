extends Node3D
# Procedural source models for the first CROWNLANDS 3D kit.
# Each .tscn below is a reusable asset with its own size and silhouette.

@export_enum("town_hall", "house", "farm", "pine", "worker") var kind := "town_hall"

const STONE = Color("a8a294")
const STONE_LIGHT = Color("c7bdab")
const PLASTER = Color("dfd0ad")
const BEAM = Color("64432f")
const ROOF = Color("59413b")
const ROOF_LIGHT = Color("785146")
const SOIL = Color("755a3f")
const WHEAT = Color("d3b75d")
const LEAF = Color("416b4d")
const BLUE = Color("527b9b")

var materials: Dictionary = {}

func _ready() -> void:
 match kind:
  "town_hall": town_hall()
  "house": house()
  "farm": farm()
  "pine": pine()
  "worker": worker()

func mat(tint: Color) -> StandardMaterial3D:
 var key := tint.to_html()
 if not materials.has(key):
  var result := StandardMaterial3D.new()
  result.albedo_color = tint
  result.roughness = 0.92
  materials[key] = result
 return materials[key]

func block(pos: Vector3, size: Vector3, tint: Color, angle: float = 0.0) -> void:
 var item := MeshInstance3D.new()
 var shape := BoxMesh.new()
 shape.size = size
 item.mesh = shape
 item.material_override = mat(tint)
 item.position = pos
 item.rotation.z = angle
 add_child(item)

func cone(pos: Vector3, radius: float, height: float, tint: Color) -> void:
 var item := MeshInstance3D.new()
 var shape := CylinderMesh.new()
 shape.top_radius = 0.04
 shape.bottom_radius = radius
 shape.height = height
 shape.radial_segments = 7
 item.mesh = shape
 item.material_override = mat(tint)
 item.position = pos
 add_child(item)

func ball(pos: Vector3, radius: float, tint: Color) -> void:
 var item := MeshInstance3D.new()
 var shape := SphereMesh.new()
 shape.radius = radius
 shape.height = radius * 2.0
 shape.radial_segments = 8
 shape.rings = 4
 item.mesh = shape
 item.material_override = mat(tint)
 item.position = pos
 add_child(item)

func pitched_roof(center: Vector3, width: float, depth: float, tint: Color) -> void:
 for side in [-1.0,1.0]:
  block(center+Vector3(side*width*0.25,0.18,0),Vector3(width*0.58,0.12,depth),tint,side*0.48)
 for z in [-1.0,1.0]:
  block(center+Vector3(0,0.37,z*depth*0.46),Vector3(width*0.13,0.14,0.10),ROOF_LIGHT)

func timber_front(width: float, floor_y: float, front_z: float, height: float) -> void:
 for x in [-width*0.43,0.0,width*0.43]:
  block(Vector3(x,floor_y,front_z),Vector3(0.10,height,0.09),BEAM)
 for y in [floor_y-height*0.42,floor_y+height*0.42]:
  block(Vector3(0,y,front_z),Vector3(width*0.94,0.09,0.09),BEAM)
 for x in [-width*0.22,width*0.22]:
  block(Vector3(x,floor_y,front_z+0.055),Vector3(0.20,0.29,0.04),Color("3f4b48"))
  block(Vector3(x,floor_y,front_z+0.08),Vector3(0.025,0.30,0.03),BEAM)

func town_hall() -> void:
 block(Vector3(0,0.08,0),Vector3(2.9,0.16,2.4),STONE)
 block(Vector3(0,0.57,0),Vector3(2.45,0.98,2.0),STONE_LIGHT)
 block(Vector3(0,1.32,0),Vector3(2.30,0.62,1.90),PLASTER)
 for x in [-1.2,1.2]:
  block(Vector3(x,0.70,0),Vector3(0.14,1.20,2.07),STONE)
 timber_front(2.30,1.32,0.99,0.64)
 timber_front(2.30,1.32,-0.99,0.64)
 for x in [-0.72,0.72]:
  block(Vector3(x,0.52,1.035),Vector3(0.24,0.42,0.05),Color("484944"))
 block(Vector3(0,0.48,1.05),Vector3(0.49,0.80,0.10),BEAM)
 block(Vector3(0,1.08,1.13),Vector3(0.78,0.09,0.28),STONE)
 for i in range(4):
  block(Vector3(-0.36+i*0.24,0.09,1.35+i*0.18),Vector3(0.90,0.16,0.28),STONE_LIGHT)
 pitched_roof(Vector3(0,1.83,0),2.78,2.24,ROOF)
 # Short slate roof battens read as shingles from the orthographic camera.
 for z in [-0.75,-0.30,0.15,0.60]:
  for x in [-0.78,0.78]:
   block(Vector3(x,2.03,z),Vector3(0.86,0.025,0.035),ROOF_LIGHT,0.47 if x < 0 else -0.47)
 block(Vector3(0.75,2.37,-0.48),Vector3(0.22,0.62,0.25),STONE)
 block(Vector3(-1.36,1.58,0.70),Vector3(0.09,0.82,0.09),BEAM)
 block(Vector3(-1.54,1.91,0.70),Vector3(0.36,0.30,0.04),BLUE)
 block(Vector3(-1.43,1.84,0.73),Vector3(0.045,0.23,0.05),Color("d9d2b9"))
 for x in [-1.07,1.07]:
  for z in [-0.82,0.82]: block(Vector3(x,0.27,z),Vector3(0.25,0.34,0.25),STONE)

func house() -> void:
 block(Vector3(0,0.07,0),Vector3(1.65,0.14,1.50),STONE)
 block(Vector3(0,0.62,0),Vector3(1.43,1.12,1.30),PLASTER)
 timber_front(1.43,0.67,0.69,1.02)
 block(Vector3(0,0.43,0.73),Vector3(0.30,0.77,0.10),BEAM)
 block(Vector3(0.23,0.43,0.80),Vector3(0.035,0.04,0.03),Color("d8bd6f"))
 pitched_roof(Vector3(0,1.26,0),1.75,1.65,ROOF_LIGHT)
 block(Vector3(0.46,1.72,-0.32),Vector3(0.18,0.45,0.22),STONE)
 for x in [-0.7,0.7]:
  block(Vector3(x,0.58,-0.48),Vector3(0.10,0.78,0.10),BEAM)

func farm() -> void:
 block(Vector3(0,0.06,0),Vector3(3.7,0.12,2.55),SOIL)
 for row in range(7):
  var z := -0.96+row*0.32
  block(Vector3(0,0.15,z),Vector3(3.35,0.10,0.16),Color("a08050"))
  for plant in range(10):
   var x := -1.48+plant*0.33
   block(Vector3(x,0.34,z),Vector3(0.07,0.34,0.07),WHEAT)
   ball(Vector3(x,0.54,z),0.07,Color("e3ca76"))
 for z in [-1.31,1.31]:
  for x in [-1.70,-0.85,0,0.85,1.70]:
   block(Vector3(x,0.30,z),Vector3(0.08,0.6,0.08),BEAM)
  block(Vector3(0,0.38,z),Vector3(3.5,0.08,0.08),BEAM)
 # Small open storage lean-to beside the field.
 block(Vector3(-2.17,0.55,-0.46),Vector3(0.80,0.90,0.85),PLASTER)
 block(Vector3(-2.17,1.10,-0.46),Vector3(1.03,0.12,1.06),ROOF)
 block(Vector3(-2.17,0.45,0.0),Vector3(0.40,0.55,0.04),BEAM)

func pine() -> void:
 block(Vector3(0,0.67,0),Vector3(0.22,1.34,0.22),BEAM)
 cone(Vector3(0,1.06,0),0.68,1.25,Color("315d45"))
 cone(Vector3(0,1.60,0),0.55,1.15,LEAF)
 cone(Vector3(0,2.11,0),0.42,1.05,Color("507956"))

func worker() -> void:
 block(Vector3(-0.11,0.18,0),Vector3(0.12,0.36,0.16),Color("574437"))
 block(Vector3(0.11,0.18,0),Vector3(0.12,0.36,0.16),Color("574437"))
 cone(Vector3(0,0.53,0),0.22,0.48,BLUE)
 ball(Vector3(0,0.88,0),0.14,Color("ddbb91"))
 block(Vector3(-0.24,0.56,0),Vector3(0.10,0.35,0.11),Color("ddbb91"),-0.30)
 block(Vector3(0.24,0.56,0),Vector3(0.10,0.35,0.11),Color("ddbb91"),0.30)
 block(Vector3(0,1.02,0),Vector3(0.29,0.08,0.29),Color("766047"))
 block(Vector3(0.33,0.50,0),Vector3(0.05,0.55,0.05),BEAM,-0.20)
 block(Vector3(0.39,0.78,0),Vector3(0.30,0.12,0.08),STONE)
