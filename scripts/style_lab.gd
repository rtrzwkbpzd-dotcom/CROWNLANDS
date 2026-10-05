extends Node3D
# A small, self-contained 3D composition to test camera and proportions.
# These procedural shapes are placeholders, not the final artwork.

var camera: Camera3D
var dragging := false
var last_pointer := Vector2.ZERO

func _ready() -> void:
 var sun := DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-55,-35,0)
 sun.light_energy = 1.4
 sun.shadow_enabled = true
 add_child(sun)
 var environment := WorldEnvironment.new()
 environment.environment = Environment.new()
 environment.environment.background_mode = Environment.BG_COLOR
 environment.environment.background_color = Color("a9c6bb")
 environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 environment.environment.ambient_light_color = Color("e8dfc4")
 environment.environment.ambient_light_energy = 0.7
 add_child(environment)
 camera = Camera3D.new()
 camera.projection = Camera3D.PROJECTION_ORTHOGONAL
 camera.size = 15.0
 camera.position = Vector3(12,14,17)
 add_child(camera)
 camera.look_at(Vector3(5,0,5))
 camera.current = true
 box(Vector3(9,0.15,11),Vector3(18,0.3,12),Color("748f5a"))
 road(Vector3(2.3,0.03,5.5),Vector3(5.4,0.03,6.2),0.8)
 road(Vector3(2.3,0.03,5.5),Vector3(3.0,0.03,3.2),0.7)
 road(Vector3(2.3,0.03,5.5),Vector3(6.4,0.03,3.4),0.6)
 town(Vector3(2.3,0.25,5.5))
 house(Vector3(3.0,0.25,3.2))
 farm(Vector3(5.4,0.24,6.2))
 for p in [Vector2(0.4,2.0),Vector2(1.2,2.5),Vector2(0.6,8.6),Vector2(1.5,9.1),Vector2(4.6,1.5),Vector2(5.3,2.0),Vector2(7.2,2.3),Vector2(7.8,3.2),Vector2(8.2,9.2)]:
  tree(Vector3(p.x,0.2,p.y))
 for i in range(4):
  worker(Vector3(1.0+i*0.48,0.25,7.1))

func material(tint: Color) -> StandardMaterial3D:
 var result := StandardMaterial3D.new()
 result.albedo_color = tint
 result.roughness = 1.0
 return result

func box(pos: Vector3, dimensions: Vector3, tint: Color, rotation_y: float = 0.0) -> MeshInstance3D:
 var result := MeshInstance3D.new()
 var mesh := BoxMesh.new()
 mesh.size = dimensions
 result.mesh = mesh
 result.material_override = material(tint)
 result.position = pos
 result.rotation.y = rotation_y
 add_child(result)
 return result

func road(start: Vector3, finish: Vector3, width: float) -> void:
 var midpoint := (start+finish)*0.5
 var delta := finish-start
 box(midpoint,Vector3(width,0.035,delta.length()),Color("ad9870"),atan2(delta.x,delta.z))

func town(pos: Vector3) -> void:
 box(pos+Vector3(0,0.55,0),Vector3(2.4,1.1,2.0),Color("aaa18d"))
 box(pos+Vector3(0,1.35,0),Vector3(2.1,0.65,1.8),Color("d3bc92"))
 roof(pos+Vector3(0,1.95,0),2.7,2.2)
 for x in [-0.82,0.82]:
  box(pos+Vector3(x,1.32,1.01),Vector3(0.13,0.7,0.08),Color("694332"))
 box(pos+Vector3(0,0.48,1.04),Vector3(0.42,0.9,0.09),Color("50372d"))
 box(pos+Vector3(0,2.65,-0.75),Vector3(0.12,0.72,0.12),Color("674733"))
 box(pos+Vector3(0.22,2.83,-0.75),Vector3(0.42,0.26,0.05),Color("537da2"))

func house(pos: Vector3) -> void:
 box(pos+Vector3(0,0.52,0),Vector3(1.35,1.05,1.2),Color("d4bf9a"))
 roof(pos+Vector3(0,1.13,0),1.6,1.5)
 box(pos+Vector3(0,0.42,0.64),Vector3(0.3,0.75,0.07),Color("62412d"))

func roof(pos: Vector3, width: float, depth: float) -> void:
 for side in [-1,1]:
  var half := box(pos+Vector3(side*width*0.25,0.18,0),Vector3(width*0.58,0.12,depth),Color("6a453c"))
  half.rotation.z = side*0.48

func farm(pos: Vector3) -> void:
 box(pos,Vector3(3.5,0.12,2.2),Color("71583c"))
 for row in range(6):
  var z := pos.z-0.82+row*0.32
  box(Vector3(pos.x,pos.y+0.1,z),Vector3(3.2,0.06,0.12),Color("c9af61"))
  for plant in range(10):
   box(Vector3(pos.x-1.4+plant*0.31,pos.y+0.22,z),Vector3(0.08,0.22,0.08),Color("dbc270"))
 house(pos+Vector3(-2.25,0,-0.35))

func tree(pos: Vector3) -> void:
 box(pos+Vector3(0,0.5,0),Vector3(0.22,1.0,0.22),Color("71543b"))
 var foliage := MeshInstance3D.new()
 var cone := CylinderMesh.new()
 cone.top_radius = 0.05
 cone.bottom_radius = 0.73
 cone.height = 1.8
 foliage.mesh = cone
 foliage.material_override = material(Color("37624a"))
 foliage.position = pos+Vector3(0,1.5,0)
 add_child(foliage)

func worker(pos: Vector3) -> void:
 var body := MeshInstance3D.new()
 var mesh := CylinderMesh.new()
 mesh.top_radius = 0.16
 mesh.bottom_radius = 0.2
 mesh.height = 0.46
 body.mesh = mesh
 body.material_override = material(Color("5b87a4"))
 body.position = pos+Vector3(0,0.43,0)
 add_child(body)
 var head := MeshInstance3D.new()
 var sphere := SphereMesh.new()
 sphere.radius = 0.12
 sphere.height = 0.24
 head.mesh = sphere
 head.material_override = material(Color("e1bd92"))
 head.position = pos+Vector3(0,0.79,0)
 add_child(head)

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventMouseButton:
  if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed: camera.size = maxf(7.0,camera.size-1.0)
  elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed: camera.size = minf(25.0,camera.size+1.0)
  elif event.button_index == MOUSE_BUTTON_MIDDLE: dragging = event.pressed
 if event is InputEventMouseMotion and dragging:
  camera.position += Vector3(-event.relative.x,0,-event.relative.y)*0.012*camera.size
