extends RefCounted
# All economic and combat balance lives here; simulation has no rendering dependency.
const MAP_SIZE = Vector2(1800, 1100)
const UNITS = {
 "worker": {"name":"Arbeiter", "cost":{"food":50}, "hp":45.0,"speed":78.0,"damage":3.0,"range":22.0,"time":5.0},
 "scout": {"name":"Kundschafter", "cost":{"food":60},"hp":70.0,"speed":125.0,"damage":5.0,"range":24.0,"time":7.0},
 "sword": {"name":"Schwert", "cost":{"food":55,"gold":15},"hp":95.0,"speed":72.0,"damage":13.0,"range":24.0,"time":7.0},
 "spear": {"name":"Speer", "cost":{"food":40,"wood":25},"hp":80.0,"speed":74.0,"damage":10.0,"range":30.0,"time":6.0},
 "archer": {"name":"Bogen", "cost":{"wood":40,"gold":20},"hp":55.0,"speed":74.0,"damage":8.0,"range":150.0,"time":8.0}
}
const BUILDINGS = {
 "town": {"name":"Rathaus", "cost":{"wood":300,"stone":100},"hp":1100.0,"size":44.0,"time":20.0,"trains":["worker","scout"]},
 "house": {"name":"Haus", "cost":{"wood":60},"hp":280.0,"size":25.0,"time":7.0,"trains":[]},
 "farm": {"name":"Farm", "cost":{"wood":70},"hp":180.0,"size":30.0,"time":8.0,"trains":[]},
 "lumber": {"name":"Holzlager", "cost":{"wood":80},"hp":300.0,"size":28.0,"time":8.0,"trains":[]},
 "barracks": {"name":"Kaserne", "cost":{"wood":150},"hp":550.0,"size":36.0,"time":12.0,"trains":["sword","spear"]},
 "range": {"name":"Bogenplatz", "cost":{"wood":160},"hp":450.0,"size":34.0,"time":12.0,"trains":["archer"]}
}
const RESOURCE_NAMES = {"wood":"Holz", "food":"Nahrung", "stone":"Stein", "gold":"Gold"}
