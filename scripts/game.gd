extends Node2D
const Simulation = preload("res://scripts/simulation.gd")
const Rules = preload("res://scripts/rules.gd")
var sim = Simulation.new()
var selected: Array = []
var camera_pos = Vector2(600,550)
var zoom_level = 1.0
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
const COLORS = [Color("76bcd0"),Color("c96d5d")]
const INK = Color("251f1c")
const CREAM = Color("f2e7c9")

func _ready():
 var layer = CanvasLayer.new()
 add_child(layer)
 var root = Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter = Control.MOUSE_FILTER_IGNORE
 layer.add_child(root)
 var top = PanelContainer.new()
 top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 style_panel(top)
 root.add_child(top)
 var row = HBoxContainer.new()
 top.add_child(row)
 stats = Label.new()
 stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 stats.add_theme_font_size_override("font_size",18)
 stats.add_theme_color_override("font_color",CREAM)
 row.add_child(stats)
 for entry in [["−",func(): zoom_level = maxf(0.35,zoom_level-0.1)],["+",func(): zoom_level = minf(1.5,zoom_level+0.1)],["Pause",func(): paused = not paused],["Neustart",func(): get_tree().reload_current_scene()]]:
  button(row,entry[0],entry[1])
 tutorial_button = Button.new()
 tutorial_button.text = "Tutorial beenden"
 tutorial_button.custom_minimum_size = Vector2(150,44)
 style_button(tutorial_button)
 tutorial_button.pressed.connect(toggle_tutorial)
 row.add_child(tutorial_button)
 tutorial_card = PanelContainer.new()
 tutorial_card.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
 style_panel(tutorial_card)
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
 tutorial_text.add_theme_color_override("font_color",CREAM)
 tutorial_card.add_child(tutorial_text)
 var bottom = PanelContainer.new()
 bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 style_panel(bottom)
 bottom.offset_top = -155
 root.add_child(bottom)
 var col = VBoxContainer.new()
 bottom.add_child(col)
 hint = Label.new()
 hint.add_theme_font_size_override("font_size",16)
 hint.add_theme_color_override("font_color",CREAM)
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
 style_button(b)
 b.pressed.connect(callback)
 parent.add_child(b)

func style_button(b: Button):
 var normal = StyleBoxFlat.new()
 normal.bg_color = Color("61452f")
 normal.border_color = Color("b68b54")
 normal.set_border_width_all(2)
 normal.set_corner_radius_all(5)
 var hover = normal.duplicate()
 hover.bg_color = Color("805b38")
 var pressed = normal.duplicate()
 pressed.bg_color = Color("3f3028")
 b.add_theme_stylebox_override("normal",normal)
 b.add_theme_stylebox_override("hover",hover)
 b.add_theme_stylebox_override("pressed",pressed)
 b.add_theme_font_size_override("font_size",16)
 b.add_theme_color_override("font_color",CREAM)
 b.add_theme_color_override("font_hover_color",Color.WHITE)

func style_panel(panel: PanelContainer):
 var style = StyleBoxFlat.new()
 style.bg_color = Color("302b27",0.96)
 style.border_color = Color("9c764a")
 style.set_border_width_all(2)
 style.set_content_margin_all(7)
 panel.add_theme_stylebox_override("panel",style)

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

func draw_ground():
 var map_rect = Rect2(world_screen(Vector2.ZERO),Rules.MAP_SIZE*zoom_level)
 draw_rect(map_rect,Color("617c53"))
 # Fixed coordinates keep the terrain from flickering as the camera moves.
 for y in range(20,1100,56):
  for x in range(20,1800,56):
   var seed: int = (x * 13 + y * 7) / 56
   var p = world_screen(Vector2(x+(seed%17)-8,y+(seed%13)-6))
   if seed%5 == 0:
    draw_circle(p,18*zoom_level,Color("759060",0.34))
   elif seed%3 == 0:
    draw_circle(p,13*zoom_level,Color("465f43",0.25))
   draw_line(p+Vector2(-5,3)*zoom_level,p+Vector2(-2,-5)*zoom_level,Color("c0bd7a",0.48),maxf(1.0,zoom_level))
   draw_line(p+Vector2(1,3)*zoom_level,p+Vector2(4,-4)*zoom_level,Color("d0c88a",0.4),maxf(1.0,zoom_level))
 for home_x in [230,1550]:
  var home = Vector2(home_x,550)
  for destination in [home+Vector2(150,100),home+Vector2(40,190),home+Vector2(140,-160)]:
   draw_line(world_screen(home),world_screen(destination),Color("52664a",0.55),76*zoom_level)
   draw_line(world_screen(home),world_screen(destination),Color("a48d62",0.86),49*zoom_level)
   draw_line(world_screen(home),world_screen(destination),Color("b5a178",0.5),30*zoom_level)
 draw_rect(map_rect,Color("c5af7a",0.6),false,3)

func draw_resource(r: Dictionary):
 var p = world_screen(r.pos)
 var s = zoom_level
 draw_circle(p+Vector2(0,11)*s,27*s,Color(0.11,0.16,0.12,0.32))
 match r.kind:
  "wood":
   draw_rect(Rect2(p+Vector2(-5,-4)*s,Vector2(10,27)*s),Color("6b4a32"))
   for offset in [Vector2(-13,-12),Vector2(11,-15),Vector2(0,-27)]:
    draw_circle(p+offset*s,15*s,Color("254f3c"))
    draw_circle(p+(offset+Vector2(-4,-4))*s,9*s,Color("397451"))
   draw_line(p+Vector2(-4,7)*s,p+Vector2(5,14)*s,Color("9f7144"),maxf(1.0,2*s))
  "food":
   for offset in [Vector2(-12,2),Vector2(12,2),Vector2(0,-11)]:
    draw_circle(p+offset*s,13*s,Color("446c39"))
    draw_circle(p+(offset+Vector2(-4,-3))*s,7*s,Color("729653"))
   for offset in [Vector2(-12,-1),Vector2(8,4),Vector2(1,-14)]:
    draw_circle(p+offset*s,4*s,Color("b64d43"))
  "stone", "gold":
   var rock = Color("a7a79a") if r.kind == "stone" else Color("af9967")
   draw_colored_polygon(PackedVector2Array([p+Vector2(-23,12)*s,p+Vector2(-16,-12)*s,p+Vector2(2,-21)*s,p+Vector2(21,-10)*s,p+Vector2(25,11)*s]),rock)
   draw_colored_polygon(PackedVector2Array([p+Vector2(-16,-12)*s,p+Vector2(2,-21)*s,p+Vector2(8,-3)*s,p+Vector2(-6,4)*s]),Color("d1c7a5") if r.kind == "stone" else Color("e6c575"))
   if r.kind == "gold":
    for offset in [Vector2(-10,2),Vector2(6,-7),Vector2(13,7)]: draw_circle(p+offset*s,3*s,Color("f1d36f"))
 label_at(p+Vector2(-22,-34)*s,Rules.RESOURCE_NAMES[r.kind],CREAM,13)

func draw_building(b: Dictionary):
 var p = world_screen(b.pos)
 var s: float = Rules.BUILDINGS[b.kind].size*zoom_level
 var wood = Color("77533a")
 var roof = Color("704334") if b.team == 0 else Color("5e3535")
 draw_circle(p+Vector2(2,s*0.5),s*1.3,Color(0.09,0.14,0.1,0.28))
 if b.kind == "farm":
  draw_rect(Rect2(p-Vector2(s*1.35,s*0.9),Vector2(s*2.7,s*1.8)),Color("765c40"))
  for row in range(5):
   var y = p.y+(row-2)*s*0.31
   draw_line(Vector2(p.x-s*1.2,y),Vector2(p.x+s*1.2,y),Color("bd9f5c"),maxf(1.0,3*zoom_level))
   for crop in range(5):
    draw_circle(Vector2(p.x+(crop-2)*s*0.5,y-3*zoom_level),2.3*zoom_level,Color("a4ad59"))
  draw_rect(Rect2(p+Vector2(-s*0.55,-s*1.15),Vector2(s*1.1,s*0.55)),Color("bfa780"))
  draw_colored_polygon(PackedVector2Array([p+Vector2(-s*0.7,-s*1.15),p+Vector2(0,-s*1.7),p+Vector2(s*0.7,-s*1.15)]),roof)
 else:
  draw_rect(Rect2(p-Vector2(s,s*0.58),Vector2(s*2,s*1.55)),Color("bba782"))
  draw_rect(Rect2(p-Vector2(s,s*0.58),Vector2(s*2,s*1.55)),wood,false,maxf(1.0,3*zoom_level))
  for x_offset in [-0.76,0.76]:
   draw_line(p+Vector2(s*x_offset,-s*0.5),p+Vector2(s*x_offset,s*0.9),wood,maxf(1.0,3*zoom_level))
  draw_rect(Rect2(p+Vector2(-s*0.21,s*0.44),Vector2(s*0.42,s*0.53)),Color("563f31"))
  draw_colored_polygon(PackedVector2Array([p+Vector2(-s*1.15,-s*0.55),p+Vector2(0,-s*1.35),p+Vector2(s*1.15,-s*0.55),p+Vector2(0,s*0.18)]),roof)
  draw_line(p+Vector2(-s*1.15,-s*0.55),p+Vector2(0,s*0.18),Color("b7895c"),maxf(1.0,3*zoom_level))
  draw_line(p+Vector2(s*1.15,-s*0.55),p+Vector2(0,s*0.18),Color("b7895c"),maxf(1.0,3*zoom_level))
  if b.kind == "town":
   draw_rect(Rect2(p+Vector2(s*0.45,-s*1.4),Vector2(s*0.23,s*0.4)),Color("806c59"))
   draw_line(p+Vector2(0,-s*1.35),p+Vector2(0,-s*1.9),INK,maxf(1.0,2*zoom_level))
   draw_colored_polygon(PackedVector2Array([p+Vector2(0,-s*1.9),p+Vector2(s*0.48,-s*1.72),p+Vector2(0,-s*1.55)]),COLORS[b.team])
 draw_rect(Rect2(p+Vector2(-s,s*0.99),Vector2(2*s,4*zoom_level)),COLORS[b.team])
 label_at(p+Vector2(-s,s+21),Rules.BUILDINGS[b.kind].name,CREAM,14)
 if b.progress < 1:
  draw_rect(Rect2(p+Vector2(-s,s+24),Vector2(2*s*b.progress,5)),Color("e5c178"))
 draw_rect(Rect2(p+Vector2(-s,-s*2.15),Vector2(2*s*b.hp/Rules.BUILDINGS[b.kind].hp,4)),Color("9ecb85"))
 if b.id in selected: draw_arc(p,s*1.55,0,TAU,32,Color("f5d789"),2)

func draw_unit(u: Dictionary):
 var p = world_screen(u.pos)
 var s = maxf(zoom_level,0.7)
 draw_circle(p+Vector2(0,6)*s,12*s,Color(0.09,0.13,0.1,0.35))
 draw_circle(p+Vector2(0,2)*s,10*s,INK)
 draw_circle(p+Vector2(0,2)*s,8*s,COLORS[u.team])
 draw_circle(p+Vector2(0,-7)*s,5*s,Color("e9c89c"))
 if u.kind == "worker":
  draw_line(p+Vector2(8,-1)*s,p+Vector2(13,-11)*s,wood_color(),maxf(1.0,2*s))
  draw_line(p+Vector2(10,-11)*s,p+Vector2(17,-11)*s,Color("bdc0ac"),maxf(1.0,3*s))
 elif u.kind == "scout":
  draw_colored_polygon(PackedVector2Array([p+Vector2(-8,-4)*s,p+Vector2(-14,8)*s,p+Vector2(0,7)*s]),Color("5c493b"))
 else:
  draw_line(p+Vector2(7,-1)*s,p+Vector2(14,-15)*s,Color("d7cfb2"),maxf(1.0,2*s))
  if u.kind == "archer": draw_arc(p+Vector2(10,-3)*s,8*s,-PI*0.5,PI*0.5,12,Color("ad7b48"),maxf(1.0,2*s))
 draw_rect(Rect2(p+Vector2(-10,-20)*s,Vector2(20*u.hp/Rules.UNITS[u.kind].hp,3)*s),Color("a4cf85"))
 if u.id in selected: draw_arc(p,16*s,0,TAU,24,Color("f5d789"),2)

func wood_color() -> Color:
 return Color("6f4931")

func _draw():
 draw_ground()
 for r in sim.resources:
  if r.amount <= 0: continue
  draw_resource(r)
 for b in sim.buildings:
  if b.team != 0 and not sim.visible(b.pos): continue
  draw_building(b)
 for u in sim.units:
  if u.team != 0 and not sim.visible(u.pos): continue
  draw_unit(u)
 if fog:
  for y in range(28):
   for x in range(45):
    var center = Vector2(x*40+20,y*40+20)
    if not sim.visible(center):
     var alpha = 0.48 if sim.discovered.has(Vector2i(x,y)) else 0.83
     draw_rect(Rect2(world_screen(Vector2(x*40,y*40)),Vector2(40,40)*zoom_level+Vector2.ONE),Color(0.08,0.12,0.1,alpha))
 if dragging and pointer.distance_to(drag_start)>16:
  draw_rect(Rect2(drag_start,pointer-drag_start).abs(),Color("ffe3a0"),false,2)
 if not placement.is_empty():
  var pos = screen_world(pointer)
  var valid = sim.can_place(placement,pos) and sim.visible(pos)
  var size: float = Rules.BUILDINGS[placement].size*zoom_level
  draw_rect(Rect2(pointer-Vector2(size,size),Vector2(size,size)*2),Color(0.4,1,0.5,0.5) if valid else Color(1,0.3,0.3,0.5))
