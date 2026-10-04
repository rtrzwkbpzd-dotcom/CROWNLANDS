extends Node2D
const Simulation = preload("res://scripts/simulation.gd")
const Rules = preload("res://scripts/rules.gd")
var sim = Simulation.new()
var selected: Array = []
var camera_pos = Vector2(400,550)
var zoom_level = 0.7
var placement = ""
var drag_start = Vector2.ZERO
var dragging = false
var pointer = Vector2.ZERO
var touches: Dictionary = {}
var multi_touch = false
var touch_distance = 0.0
var stats: Label
var hint: Label
var actions: HBoxContainer
var tutorial_card: PanelContainer
var tutorial_text: Label
var tutorial_button: Button
var tutorial_active = true
var tutorial_stage = 0
var tutorial_start_total = 0
var action_key = ""
var paused = false
var fog = true
var accumulator = 0.0
const COLORS = [Color("66c7ed"),Color("ef7973")]

func _ready():
 var layer = CanvasLayer.new()
 add_child(layer)
 var root = Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter = Control.MOUSE_FILTER_IGNORE
 layer.add_child(root)
 var top = PanelContainer.new()
 top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 root.add_child(top)
 var row = HBoxContainer.new()
 top.add_child(row)
 stats = Label.new()
 stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 stats.add_theme_font_size_override("font_size",18)
 row.add_child(stats)
 for entry in [["−",func(): zoom_level = maxf(0.35,zoom_level-0.1)],["+",func(): zoom_level = minf(1.5,zoom_level+0.1)],["Pause",func(): paused = not paused],["Neustart",func(): get_tree().reload_current_scene()]]:
  button(row,entry[0],entry[1])
 tutorial_button = Button.new()
 tutorial_button.text = "Tutorial beenden"
 tutorial_button.custom_minimum_size = Vector2(150,44)
 tutorial_button.pressed.connect(toggle_tutorial)
 row.add_child(tutorial_button)
 tutorial_card = PanelContainer.new()
 tutorial_card.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 tutorial_card.offset_left = 170
 tutorial_card.offset_right = -170
 tutorial_card.offset_top = 54
 tutorial_card.offset_bottom = 132
 root.add_child(tutorial_card)
 tutorial_text = Label.new()
 tutorial_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 tutorial_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
 tutorial_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 tutorial_text.add_theme_font_size_override("font_size",18)
 tutorial_card.add_child(tutorial_text)
 var bottom = PanelContainer.new()
 bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 bottom.offset_top = -155
 root.add_child(bottom)
 var col = VBoxContainer.new()
 bottom.add_child(col)
 hint = Label.new()
 hint.add_theme_font_size_override("font_size",16)
 col.add_child(hint)
 var groups = HBoxContainer.new()
 col.add_child(groups)
 button(groups,"Arbeiter",func(): select_group("worker"))
 button(groups,"Armee",func(): select_group("army"))
 button(groups,"Rathaus",func():
  for b in sim.buildings:
   if b.team == 0 and b.kind == "town":
    selected = [b.id]
    camera_pos = b.pos)
 button(groups,"Abwählen",func(): selected.clear(); placement = "")
 var scroll = ScrollContainer.new()
 col.add_child(scroll)
 actions = HBoxContainer.new()
 scroll.add_child(actions)
 tutorial_start_total = resource_total(sim.wallets[0])
 update_hud()
 update_tutorial()

func button(parent: Node, title: String, callback: Callable):
 var b = Button.new()
 b.text = title
 b.custom_minimum_size = Vector2(100,44)
 b.pressed.connect(callback)
 parent.add_child(b)

func resource_total(wallet: Dictionary) -> int:
 return wallet.wood + wallet.food + wallet.stone + wallet.gold

func toggle_tutorial():
 tutorial_active = not tutorial_active
 if tutorial_active:
  tutorial_stage = 0
  tutorial_start_total = resource_total(sim.wallets[0])
  tutorial_card.show()
  tutorial_button.text = "Tutorial beenden"
 else:
  tutorial_card.hide()
  tutorial_button.text = "Tutorial starten"

func update_tutorial():
 if not tutorial_active: return
 if sim.winner == 0:
  tutorial_text.text = "Sieg! Du hast das gegnerische Rathaus zerstört. Starte eine neue Partie für eine weitere Runde."
  return
 elif sim.winner == 1:
  tutorial_text.text = "Dein Rathaus wurde zerstört. Du kannst neu starten oder das Tutorial überspringen."
  return
 if tutorial_stage == 0:
  for value in selected:
   var e = sim.entity(value)
   if not e.is_empty() and e.get("kind","") == "worker": tutorial_stage = 1
 elif tutorial_stage == 1:
  for value in selected:
   var e = sim.entity(value)
   if not e.is_empty() and e.get("kind","") == "worker" and e.order == "gather": tutorial_stage = 2
 elif tutorial_stage == 2 and resource_total(sim.wallets[0]) > tutorial_start_total:
  tutorial_stage = 3
 elif tutorial_stage == 3 and placement == "barracks":
  tutorial_stage = 4
 elif tutorial_stage == 4:
  for b in sim.buildings:
   if b.team == 0 and b.kind == "barracks": tutorial_stage = 5
 elif tutorial_stage == 5:
  for b in sim.buildings:
   if b.team == 0 and b.kind == "barracks" and b.progress >= 1.0: tutorial_stage = 6
 elif tutorial_stage == 6:
  for b in sim.buildings:
   if b.team == 0 and b.kind == "barracks" and not b.queue.is_empty(): tutorial_stage = 7
 match tutorial_stage:
  0: tutorial_text.text = "CROWNLANDS • 1/5  Wähle einen Arbeiter: tippe auf einen blauen Arbeiter oder auf „Arbeiter“."
  1: tutorial_text.text = "2/5  Schicke ihn sammeln: tippe auf ein sichtbares Holz-, Nahrungs-, Stein- oder Goldfeld."
  2: tutorial_text.text = "2/5  Der Arbeiter bringt bis zu 20 Rohstoffe zurück zum Lager. Warte, bis der Vorrat steigt."
  3: tutorial_text.text = "3/5  Tippe unten auf „Kaserne“."
  4: tutorial_text.text = "3/5  Setze die Kaserne auf einen grünen, freien Platz nahe deinem Dorf."
  5: tutorial_text.text = "3/5  Dein Arbeiter errichtet die Kaserne. Lass ihn dort, bis der Bau abgeschlossen ist."
  6: tutorial_text.text = "4/5  Tippe auf deine fertige Kaserne und bilde einen Schwertkämpfer aus."
  7: tutorial_text.text = "Grundlagen geschafft! Wähle „Armee“, erkunde die Karte und greife das rote Rathaus an. Viel Erfolg!"

func select_group(kind: String):
 selected.clear()
 placement = ""
 for u in sim.units:
  if u.team == 0 and (u.kind == kind or (kind == "army" and u.kind != "worker")): selected.append(u.id)

func screen_world(p: Vector2) -> Vector2:
 return (p-get_viewport_rect().size/2.0)/zoom_level+camera_pos

func world_screen(p: Vector2) -> Vector2:
 return (p-camera_pos)*zoom_level+get_viewport_rect().size/2.0

func hit(p: Vector2) -> Dictionary:
 for collection in [sim.units,sim.buildings,sim.resources]:
  for e in collection:
   if e.get("team",0) != 0 and not sim.visible(e.pos): continue
   if e.has("amount") and e.amount <= 0: continue
   var radius = Rules.BUILDINGS[e.kind].size if e.has("progress") else 25.0
   if e.pos.distance_to(p) < maxf(radius,18.0/zoom_level): return e
 return {}

func click(p: Vector2):
 var w = screen_world(p)
 if not placement.is_empty():
  if sim.visible(w) and sim.build(placement,0,w,selected): placement = ""
  else: hint.text = "Bauplatz, Ressourcen oder Arbeiter fehlen."
  return
 var e = hit(w)
 if not e.is_empty() and e.get("team",-1) == 0:
  if not selected.is_empty() and e.has("progress") and (e.progress < 1.0 or e.kind == "farm"):
   sim.command(selected,w,e.id)
  else: selected = [e.id]
 elif not selected.is_empty():
  sim.command(selected,w,e.get("id",-1))

func release(p: Vector2):
 if p.distance_to(drag_start) > 16:
  selected.clear()
  var rect = Rect2(drag_start,p-drag_start).abs()
  for u in sim.units:
   if u.team == 0 and rect.has_point(world_screen(u.pos)): selected.append(u.id)
 else: click(p)
 dragging = false

func _unhandled_input(event):
 if event is InputEventKey and event.pressed:
  if event.keycode == KEY_ESCAPE: selected.clear(); placement = ""
  if event.keycode == KEY_SPACE: paused = not paused
 if event is InputEventMouseButton:
  pointer = event.position
  if event.button_index == MOUSE_BUTTON_WHEEL_UP: zoom_level = minf(1.5,zoom_level+0.1)
  elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: zoom_level = maxf(0.35,zoom_level-0.1)
  elif event.button_index == MOUSE_BUTTON_LEFT:
   if event.pressed: drag_start = pointer; dragging = true
   elif dragging: release(pointer)
  elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
   var e = hit(screen_world(pointer))
   sim.command(selected,screen_world(pointer),e.get("id",-1))
 if event is InputEventMouseMotion:
  pointer = event.position
  if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
   camera_pos -= event.relative/zoom_level
 if event is InputEventScreenTouch:
  pointer = event.position
  if event.pressed:
   touches[event.index] = event.position
   if touches.size() == 1: drag_start = event.position; dragging = true
   else:
    multi_touch = true
    dragging = false
    var points = touches.values()
    touch_distance = points[0].distance_to(points[1])
  else:
   touches.erase(event.index)
   if not multi_touch and dragging: release(event.position)
   if touches.is_empty(): multi_touch = false; dragging = false
 if event is InputEventScreenDrag:
  pointer = event.position
  touches[event.index] = event.position
  if touches.size() >= 2:
   camera_pos -= event.relative/(2.0*zoom_level)
   var points = touches.values()
   var distance: float = points[0].distance_to(points[1])
   if touch_distance > 10: zoom_level = clampf(zoom_level*distance/touch_distance,0.35,1.5)
   touch_distance = distance
 camera_pos = camera_pos.clamp(Vector2.ZERO,Rules.MAP_SIZE)

func cost_text(cost: Dictionary) -> String:
 var parts: PackedStringArray = []
 for key in cost: parts.append("%d %s" % [cost[key],Rules.RESOURCE_NAMES[key]])
 return ", ".join(parts)

func update_hud():
 var w: Dictionary = sim.wallets[0]
 stats.text = "  CROWNLANDS   Holz %d   Nahrung %d   Stein %d   Gold %d   %d/%d" % [w.wood,w.food,w.stone,w.gold,sim.population(0),sim.capacity(0)]
 var live: Array = []
 for value in selected:
  if not sim.entity(value).is_empty(): live.append(value)
 selected = live
 var key = str(selected)
 if key != action_key:
  action_key = key
  for child in actions.get_children(): actions.remove_child(child); child.queue_free()
  var workers = false
  for value in selected:
   if sim.entity(value).kind == "worker": workers = true
  if workers:
   for kind in Rules.BUILDINGS:
    if kind == "town": continue
    button(actions,Rules.BUILDINGS[kind].name+"\n"+cost_text(Rules.BUILDINGS[kind].cost),func(): placement = kind)
  if selected.size() == 1:
   var e = sim.entity(selected[0])
   if e.has("queue"):
    for kind in Rules.BUILDINGS[e.kind].trains:
     button(actions,Rules.UNITS[kind].name+"\n"+cost_text(Rules.UNITS[kind].cost),func():
      if not sim.train(e.id,kind): hint.text = "Ressourcen, Wohnraum oder Baufortschritt fehlen.")
 if sim.winner != -1: hint.text = "SIEG! Das gegnerische Rathaus ist gefallen." if sim.winner == 0 else "NIEDERLAGE — Dein Rathaus wurde zerstört. Neustart für eine neue Partie."
 elif paused: hint.text = "PAUSE"
 elif not placement.is_empty(): hint.text = "Bauen: %s — Tippe auf einen freien, sichtbaren Platz." % Rules.BUILDINGS[placement].name
 elif selected.is_empty(): hint.text = "Tippen: auswählen • Ziehen: Gruppe • Zwei Finger: Kamera/Zoom • Ziel: rotes Rathaus zerstören"
 else:
  var e = sim.entity(selected[0])
  var name_text: String = Rules.BUILDINGS[e.kind].name if e.has("queue") else Rules.UNITS[e.kind].name
  hint.text = "%s (%d gewählt) • Auf Rohstoff/Boden/Gegner tippen" % [name_text,selected.size()]
  if e.has("queue"): hint.text += " • Bau %d%% • Warteschlange %d" % [int(e.progress*100),e.queue.size()]

func _process(dt):
 if not paused:
  accumulator += minf(dt,0.1)
  while accumulator >= 0.1:
   sim.tick(0.1)
   accumulator -= 0.1
 update_tutorial()
 update_hud()
 queue_redraw()

func label_at(p: Vector2, value: String, color: Color = Color.WHITE, size: int = 15):
 draw_string(ThemeDB.fallback_font,p,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func _draw():
 var map_rect = Rect2(world_screen(Vector2.ZERO),Rules.MAP_SIZE*zoom_level)
 draw_rect(map_rect,Color("416345"))
 for x in range(0,1801,80): draw_line(world_screen(Vector2(x,0)),world_screen(Vector2(x,1100)),Color(0.5,0.7,0.5,0.12))
 for y in range(0,1101,80): draw_line(world_screen(Vector2(0,y)),world_screen(Vector2(1800,y)),Color(0.5,0.7,0.5,0.12))
 for r in sim.resources:
  if r.amount <= 0: continue
  var p = world_screen(r.pos)
  var color: Color = {"wood":Color("203e2f"),"food":Color("e0a075"),"stone":Color("a0aaa7"),"gold":Color("e9c05a")}[r.kind]
  draw_circle(p,23*zoom_level,color)
  label_at(p+Vector2(-20,-26)*zoom_level,Rules.RESOURCE_NAMES[r.kind],Color("f1e9d2"),13)
 for b in sim.buildings:
  if b.team != 0 and not sim.visible(b.pos): continue
  var p = world_screen(b.pos)
  var size: float = Rules.BUILDINGS[b.kind].size*zoom_level
  draw_rect(Rect2(p-Vector2(size,size),Vector2(size,size)*2),Color("ac9674"))
  draw_colored_polygon(PackedVector2Array([p+Vector2(-size,-size),p+Vector2(size,-size),p+Vector2(0,-size*1.7)]),COLORS[b.team])
  draw_rect(Rect2(p-Vector2(size,size),Vector2(size,size)*2),COLORS[b.team],false,2)
  label_at(p+Vector2(-size,size+18),Rules.BUILDINGS[b.kind].name,Color.WHITE,14)
  if b.progress < 1: draw_rect(Rect2(p+Vector2(-size,size+23),Vector2(size*2*b.progress,4)),Color("e9c05a"))
  draw_rect(Rect2(p+Vector2(-size,-size*1.8-6),Vector2(2*size*b.hp/Rules.BUILDINGS[b.kind].hp,4)),COLORS[b.team])
  if b.id in selected: draw_arc(p,size*1.6,0,TAU,32,Color("ffe3a0"),2)
 for u in sim.units:
  if u.team != 0 and not sim.visible(u.pos): continue
  var p = world_screen(u.pos)
  draw_circle(p+Vector2(0,5),12*zoom_level,Color(0,0,0,0.25))
  draw_circle(p,10*zoom_level,COLORS[u.team])
  draw_circle(p+Vector2(0,-7)*zoom_level,5*zoom_level,Color("edd1a0"))
  var glyph: String = {"worker":"W","scout":"?","sword":"S","spear":"P","archer":"B"}[u.kind]
  label_at(p+Vector2(-4,4),glyph,Color("182633"),12)
  draw_rect(Rect2(p+Vector2(-10,-18)*zoom_level,Vector2(20*u.hp/Rules.UNITS[u.kind].hp,3)*zoom_level),Color("9ada82"))
  if u.id in selected: draw_arc(p,16*zoom_level,0,TAU,24,Color("ffe3a0"),2)
 if fog:
  for y in range(28):
   for x in range(45):
    var center = Vector2(x*40+20,y*40+20)
    if not sim.visible(center):
     var alpha = 0.52 if sim.discovered.has(Vector2i(x,y)) else 0.96
     draw_rect(Rect2(world_screen(Vector2(x*40,y*40)),Vector2(40,40)*zoom_level+Vector2.ONE),Color(0.04,0.08,0.09,alpha))
 if dragging and pointer.distance_to(drag_start)>16:
  draw_rect(Rect2(drag_start,pointer-drag_start).abs(),Color("ffe3a0"),false,2)
 if not placement.is_empty():
  var pos = screen_world(pointer)
  var valid = sim.can_place(placement,pos) and sim.visible(pos)
  var size: float = Rules.BUILDINGS[placement].size*zoom_level
  draw_rect(Rect2(pointer-Vector2(size,size),Vector2(size,size)*2),Color(0.4,1,0.5,0.5) if valid else Color(1,0.3,0.3,0.5))
