extends SceneTree
const Sim = preload("res://scripts/simulation.gd")
const Navigation = preload("res://scripts/navigation.gd")
var failures = 0
func check(condition: bool, message: String):
 if not condition:
  failures += 1
  push_error(message)
func _initialize():
 var sim = Sim.new()
 check(sim.units.size()==10,"Starting units")
 check(sim.buildings.size()==2,"Starting towns")
 var worker = sim.units[0]
 var source = sim.resources[0]
 var before: int = sim.wallets[0].wood
 var source_amount: int = source.amount
 sim.command([worker.id],source.pos,source.id)
 for i in range(400): sim.tick(0.1)
 check(source.amount<source_amount,"Worker reaches resource and gathers it")
 check(sim.wallets[0].wood>before,"Worker returns carried resources to storage")
 check(worker.carry_amount==0 and worker.order=="gather","Worker unloads and resumes the resource job")
 var town = sim.buildings[0]
 check(sim.train(town.id,"worker"),"Worker queues")
 var count: int = sim.units.filter(func(u): return u.team==0).size()
 for i in range(60): sim.tick(0.1)
 check(sim.units.filter(func(u): return u.team==0).size()==count+1,"Production completes")
 check(not sim.train(town.id,"archer"),"Invalid producer rejected")
 before = sim.wallets[0].wood
 check(not sim.build("house",0,town.pos,[worker.id]),"Overlapping build rejected")
 check(sim.wallets[0].wood==before,"Rejected build does not charge")
 var site = Vector2(420,300)
 check(sim.build("house",0,site,[worker.id]),"House placed")
 for i in range(150): sim.tick(0.1)
 check(sim.capacity(0)==15,"Worker completes house")
 for i in range(500): sim.tick(0.1)
 check(sim.buildings.any(func(b): return b.team==1 and b.kind=="barracks" and b.progress==1.0),"AI constructs barracks using workers")
 check(sim.units.any(func(u): return u.team==1 and u.kind=="sword"),"AI produces real army")
 var obstacle = {"id":9999,"kind":"town","team":0,"pos":Vector2(350,550),"hp":1000.0,"progress":1.0}
 var route = Navigation.route(Vector2(100,550),Vector2(600,550),[obstacle],[])
 check(not route.is_empty(),"Pathfinder finds a route around blocked tiles")
 var crosses_town = false
 for point in route:
  if point.distance_to(obstacle.pos)<57.0: crosses_town = true
 check(not crosses_town,"Pathfinder does not route through the starting town")
 var enemy_town = sim.buildings.filter(func(b): return b.team==1 and b.kind=="town")[0]
 sim.winner = -1
 enemy_town.hp = 1.0
 var soldier = sim.add_unit("sword",0,enemy_town.pos+Vector2(20,0))
 sim.command([soldier.id],enemy_town.pos,enemy_town.id)
 sim.tick(0.1)
 check(sim.winner==0,"Town destruction yields victory")
 var ended: float = sim.elapsed
 sim.tick(1.0)
 check(sim.elapsed==ended,"Finished game stops simulation")
 print("CROWNLANDS smoke tests: %d failures" % failures)
 quit(1 if failures else 0)
