extends Node3D
# A small, self-contained 3D composition to test the reusable asset kit.

var camera: Camera3D
var dragging := false

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
 box(Vector3(9,0,6),Vector3(18,0.3,12),Color("748f5a"))
 road(Vector3(2.3,0.17,5.5),Vector3(7.0,0.17,6.2),0.8)
 road(Vector3(2.3,0.17,5.5),Vector3(3.0,0.17,3.2),0.7)
 road(Vector3(2.3,0.17,5.5),Vector3(6.4,0.17,3.4),0.6)
 asset("town_hall",Vector3(2.3,0.15,5.5))
 asset("house",Vector3(3.0,0.15,3.2))
 asset("farm",Vector3(7.0,0.15,6.2))
 for p in [Vector2(0.4,2.0),Vector2(1.2,2.5),Vector2(0.6,8.6),Vector2(1.5,9.1),Vector2(4.6,1.5),Vector2(5.3,2.0),Vector2(7.2,2.3),Vector2(7.8,3.2),Vector2(8.2,9.2)]:
  asset("pine",Vector3(p.x,0.15,p.y))
 for i in range(4):
  asset("worker",Vector3(1.0+i*0.48,0.15,7.1))

func asset(asset_name: String, pos: Vector3) -> void:
 var scene: PackedScene = load("res://assets/%s.tscn" % asset_name)
 var instance := scene.instantiate()
 instance.position = pos
 add_child(instance)

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

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventMouseButton:
  if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed: camera.size = maxf(7.0,camera.size-1.0)
  elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed: camera.size = minf(25.0,camera.size+1.0)
  elif event.button_index == MOUSE_BUTTON_MIDDLE: dragging = event.pressed
 if event is InputEventMouseMotion and dragging:
  camera.position += Vector3(-event.relative.x,0,-event.relative.y)*0.012*camera.size
