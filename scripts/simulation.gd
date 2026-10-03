extends RefCounted
const Rules = preload("res://scripts/rules.gd")
var units: Array = []
var buildings: Array = []
var resources: Array = []
var wallets: Array = []
var winner: int = -1
var elapsed: float = 0.0
var ai_clock: float = 0.0
var next_id: int = 1
var discovered: Dictionary = {}

func _init():
 wallets = [{"wood":320,"food":260,"stone":140,"gold":140},{"wood":320,"food":260,"stone":140,"gold":140}]
 for team in range(2):
  var home = Vector2(230,550) if team == 0 else Vector2(1550,550)
  add_building("town",team,home,true)
  for i in range(4):
   add_unit("worker",team,home+Vector2(-50+i*28,70))
  add_unit("scout",team,home+Vector2(0,-80))
  for offset in [Vector2(40,190),Vector2(-90,-200)]:
   add_resource("wood",home+offset,1600)
  add_resource("food",home+Vector2(150,100),1200)
  add_resource("stone",home+Vector2(-110,130),1000)
  add_resource("gold",home+Vector2(140,-160),1000)
 for i in range(6):
  add_resource("wood",Vector2(650+i*100,220 if i%2==0 else 880),1200)
 update_discovery()

func id() -> int:
 var value = next_id
 next_id += 1
 return value

func add_unit(kind: String, team: int, pos: Vector2) -> Dictionary:
 var u = {"id":id(),"kind":kind,"team":team,"pos":pos,"hp":Rules.UNITS[kind].hp,"order":"idle","target":-1,"goal":pos,"cooldown":0.0,"gather":0.0}
 units.append(u)
 return u

func add_building(kind: String, team: int, pos: Vector2, complete: bool) -> Dictionary:
 var b = {"id":id(),"kind":kind,"team":team,"pos":pos,"hp":Rules.BUILDINGS[kind].hp,"progress":1.0 if complete else 0.0,"queue":[],"timer":0.0}
 buildings.append(b)
 return b

func add_resource(kind: String, pos: Vector2, amount: int) -> void:
 resources.append({"id":id(),"kind":kind,"pos":pos,"amount":amount})

func entity(value: int) -> Dictionary:
 for collection in [units,buildings,resources]:
  for e in collection:
   if e.id == value:
    return e
 return {}

func afford(team: int, cost: Dictionary) -> bool:
 for key in cost:
  if wallets[team][key] < cost[key]:
   return false
 return true

func pay(team: int, cost: Dictionary) -> bool:
 if not afford(team,cost):
  return false
 for key in cost:
  wallets[team][key] -= cost[key]
 return true

func population(team: int) -> int:
 var count = 0
 for u in units:
  if u.team == team:
   count += 1
 for b in buildings:
  if b.team == team:
   count += b.queue.size()
 return count

func capacity(team: int) -> int:
 var count = 0
 for b in buildings:
  if b.team == team and b.progress >= 1.0:
   if b.kind == "town": count += 10
   if b.kind == "house": count += 5
 return count

func train(building_id: int, kind: String) -> bool:
 var b = entity(building_id)
 if b.is_empty() or not b.has("queue") or b.progress < 1.0 or not kind in Rules.BUILDINGS[b.kind].trains:
  return false
 if b.queue.size() >= 5 or population(b.team) >= capacity(b.team) or not pay(b.team,Rules.UNITS[kind].cost):
  return false
 b.queue.append(kind)
 return true

func can_place(kind: String, pos: Vector2) -> bool:
 var size = Rules.BUILDINGS[kind].size
 if pos.x < size or pos.y < size or pos.x > Rules.MAP_SIZE.x-size or pos.y > Rules.MAP_SIZE.y-size:
  return false
 for b in buildings:
  if b.pos.distance_to(pos) < size+Rules.BUILDINGS[b.kind].size+15:
   return false
 for r in resources:
  if r.amount > 0 and r.pos.distance_to(pos) < size+26:
   return false
 return true

func build(kind: String, team: int, pos: Vector2, worker_ids: Array) -> bool:
 var workers: Array = []
 for value in worker_ids:
  var w = entity(value)
  if not w.is_empty() and w.get("kind") == "worker" and w.team == team:
   workers.append(w)
 if workers.is_empty() or not can_place(kind,pos) or not pay(team,Rules.BUILDINGS[kind].cost):
  return false
 var b = add_building(kind,team,pos,false)
 for w in workers:
  w.order = "build"
  w.target = b.id
 return true

func command(ids: Array, point: Vector2, target_id: int = -1):
 var target = entity(target_id)
 var index = 0
 for value in ids:
  var u = entity(value)
  if u.is_empty() or not u.has("order"): continue
  u.target = target_id
  u.order = "move"
  u.goal = point+Vector2((index%4)*20,(index/4)*20)
  u.goal = u.goal.clamp(Vector2(15,15),Rules.MAP_SIZE-Vector2(15,15))
  if not target.is_empty():
   if target.has("team") and target.team != u.team: u.order = "attack"
   elif u.kind == "worker" and target.has("amount"): u.order = "gather"
   elif u.kind == "worker" and target.get("kind") == "farm" and target.team == u.team and target.progress >= 1.0: u.order = "gather"
   elif u.kind == "worker" and target.has("progress") and target.team == u.team and target.progress < 1.0: u.order = "build"
  index += 1

func visible(pos: Vector2, team: int = 0) -> bool:
 for u in units:
  if u.team == team and u.pos.distance_to(pos) < (270.0 if u.kind == "scout" else 190.0): return true
 for b in buildings:
  if b.team == team and b.pos.distance_to(pos) < 230.0: return true
 return false

func update_discovery():
 for y in range(28):
  for x in range(45):
   if visible(Vector2(x*40+20,y*40+20)): discovered[Vector2i(x,y)] = true

func move_towards(u: Dictionary, point: Vector2, dt: float):
 var step = Rules.UNITS[u.kind].speed*dt
 u.pos = u.pos.move_toward(point,step)
 # Soft separation avoids stacks. Buildings remain a graybox limitation.
 for other in units:
  if other.id == u.id: continue
  var diff: Vector2 = u.pos-other.pos
  if diff.length_squared() < 225.0 and diff.length_squared() > 0.01:
   u.pos += diff.normalized()*dt*20.0
 u.pos = u.pos.clamp(Vector2(10,10),Rules.MAP_SIZE-Vector2(10,10))

func tick(dt: float):
 if winner != -1: return
 elapsed += dt
 for b in buildings:
  if b.progress < 1.0 or b.queue.is_empty(): continue
  b.timer += dt
  var kind: String = b.queue[0]
  if b.timer >= Rules.UNITS[kind].time:
   b.timer = 0.0
   b.queue.pop_front()
   add_unit(kind,b.team,b.pos+Vector2(0,Rules.BUILDINGS[b.kind].size+22))
 for u in units:
  u.cooldown = maxf(0.0,u.cooldown-dt)
  var target = entity(u.target)
  if u.order in ["attack","gather","build"] and target.is_empty(): u.order = "idle"
  if u.order == "move":
   move_towards(u,u.goal,dt)
   if u.pos.distance_to(u.goal) < 8: u.order = "idle"
  elif u.order == "gather":
   var radius = 40.0 if target.has("progress") else 28.0
   if u.pos.distance_to(target.pos) > radius: move_towards(u,target.pos,dt)
   else:
    u.gather += dt
    if u.gather >= 1.0:
     u.gather -= 1.0
     var amount = 5
     var key: String = target.kind if target.has("amount") else "food"
     if target.has("amount"):
      amount = mini(amount,target.amount)
      target.amount -= amount
      if target.amount <= 0: u.order = "idle"
     wallets[u.team][key] += amount
  elif u.order == "build":
   if u.pos.distance_to(target.pos) > Rules.BUILDINGS[target.kind].size+18: move_towards(u,target.pos,dt)
   else:
    target.progress = minf(1.0,target.progress+dt/Rules.BUILDINGS[target.kind].time)
    if target.progress >= 1.0: u.order = "idle"
  elif u.order == "attack":
   var extra = Rules.BUILDINGS[target.kind].size if target.has("progress") else 8.0
   if u.pos.distance_to(target.pos) > Rules.UNITS[u.kind].range+extra: move_towards(u,target.pos,dt)
   elif u.cooldown <= 0:
    u.cooldown = 1.0
    var damage: float = Rules.UNITS[u.kind].damage
    if u.kind == "sword" and target.kind == "spear": damage *= 1.6
    if u.kind == "archer" and target.kind in ["sword","spear"]: damage *= 1.3
    target.hp -= damage
  if u.order == "idle" and u.kind != "worker":
   for enemy in units:
    if enemy.team != u.team and enemy.hp > 0 and u.pos.distance_to(enemy.pos) < 180.0 and visible(enemy.pos,u.team):
     u.order = "attack"
     u.target = enemy.id
     break
 for b in buildings:
  if b.hp <= 0 and b.kind == "town": winner = 1-b.team
 units = units.filter(func(u): return u.hp > 0)
 buildings = buildings.filter(func(b): return b.hp > 0)
 ai_clock += dt
 if ai_clock >= 2.0:
  ai_clock = 0.0
  ai_step()
 update_discovery()

func ai_step():
 var home: Dictionary = {}
 var workers: Array = []
 var army: Array = []
 var kinds: Array = []
 for u in units:
  if u.team != 1: continue
  if u.kind == "worker": workers.append(u)
  elif u.kind != "scout": army.append(u)
 for b in buildings:
  if b.team != 1: continue
  kinds.append(b.kind)
  if b.kind == "town": home = b
  if b.kind == "barracks": train(b.id,"sword")
 if home.is_empty(): return
 if workers.size() < 7: train(home.id,"worker")
 for i in range(workers.size()):
  var w: Dictionary = workers[i]
  if w.order != "idle": continue
  var desired = "wood" if i%3==0 else ("food" if i%3==1 else "gold")
  var best: Dictionary = {}
  var distance = INF
  for r in resources:
   if r.kind == desired and r.amount > 0 and w.pos.distance_to(r.pos) < distance:
    best = r
    distance = w.pos.distance_to(r.pos)
  if not best.is_empty(): command([w.id],best.pos,best.id)
 # Finish existing construction before assigning another building.
 for b in buildings:
  if b.team == 1 and b.progress < 1.0:
   if not workers.any(func(w): return w.order == "build" and w.target == b.id) and not workers.is_empty():
    workers[0].order = "build"
    workers[0].target = b.id
   return
 var to_build = ""
 if not "barracks" in kinds: to_build = "barracks"
 elif population(1) >= capacity(1)-2: to_build = "house"
 if not to_build.is_empty() and not workers.is_empty():
  for i in range(16):
   var point: Vector2 = home.pos+Vector2(-180+(i%4)*110,-350+(i/4)*110)
   if can_place(to_build,point) and build(to_build,1,point,[workers[0].id]): break
 if army.size() >= 5 or elapsed > 200:
  var enemy_home: Dictionary = {}
  for b in buildings:
   if b.team == 0 and b.kind == "town": enemy_home = b
  if not enemy_home.is_empty():
   for u in army:
    if u.order != "attack": command([u.id],enemy_home.pos,enemy_home.id)
