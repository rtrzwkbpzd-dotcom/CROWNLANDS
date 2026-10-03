extends RefCounted

const MAP_SIZE = Vector2(1800, 1100)
const CELL = 40.0
const REGION = Rect2i(Vector2i.ZERO, Vector2i(45, 28))

static func _cell(point: Vector2) -> Vector2i:
 return Vector2i(clampi(floori(point.x / CELL), 0, 44), clampi(floori(point.y / CELL), 0, 27))

static func _world(cell: Vector2i) -> Vector2:
 return Vector2(cell.x * CELL + CELL / 2.0, cell.y * CELL + CELL / 2.0)

static func route(start: Vector2, destination: Vector2, buildings: Array, resources: Array, ignored_resource: int = -1, approach_radius: float = 0.0) -> Array[Vector2]:
 var grid := AStarGrid2D.new()
 grid.region = REGION
 grid.cell_size = Vector2(CELL, CELL)
 grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
 grid.update()
 for building in buildings:
  if building.hp <= 0.0:
   continue
  var extent: float = float(40 if building.kind == "town" else 34 if building.kind in ["barracks", "range"] else 30) + 20.0
  _mark_circle(grid, building.pos, extent)
 for resource in resources:
  if resource.amount > 0 and resource.id != ignored_resource:
   _mark_circle(grid, resource.pos, 29.0)
 var start_cell := _cell(start)
 if grid.is_point_solid(start_cell):
  grid.set_point_solid(start_cell, false)
 var candidates: Array[Vector2] = []
 if approach_radius <= 0.0:
  candidates.append(destination)
 else:
  for step in range(16):
   var angle := TAU * float(step) / 16.0
   candidates.append(destination + Vector2(cos(angle), sin(angle)) * approach_radius)
  candidates.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.distance_squared_to(start) + a.distance_squared_to(destination) < b.distance_squared_to(start) + b.distance_squared_to(destination))
 var best_path: Array[Vector2] = []
 var best_length := INF
 for candidate in candidates:
  var goal_cell := _cell(candidate)
  if grid.is_point_solid(goal_cell):
   continue
  var cell_path := grid.get_id_path(start_cell, goal_cell)
  if cell_path.is_empty() and start_cell != goal_cell:
   continue
  if cell_path.size() < best_length:
   best_length = cell_path.size()
   best_path.clear()
   for cell in cell_path:
    best_path.append(_world(cell))
 return best_path

static func _mark_circle(grid: AStarGrid2D, center: Vector2, radius: float) -> void:
 var min_cell := _cell(center - Vector2.ONE * radius)
 var max_cell := _cell(center + Vector2.ONE * radius)
 for y in range(min_cell.y, max_cell.y + 1):
  for x in range(min_cell.x, max_cell.x + 1):
   var point := Vector2i(x, y)
   if _world(point).distance_to(center) < radius:
    grid.set_point_solid(point, true)
