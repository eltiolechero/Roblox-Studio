"""Construye un lugar XML de Roblox sin dependencias externas: python tools/build_place.py."""
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
doc = ET.Element('roblox', {'version': '4'})
ET.SubElement(doc, 'External').text = 'null'
ET.SubElement(doc, 'External').text = 'nil'

def item(parent, cls, name):
    node = ET.SubElement(parent, 'Item', {'class': cls, 'referent': 'RBX' + name})
    props = ET.SubElement(node, 'Properties')
    ET.SubElement(props, 'string', {'name': 'Name'}).text = name
    return node, props

server, _ = item(doc, 'ServerScriptService', 'ServerScriptService')
starter, _ = item(doc, 'StarterPlayer', 'StarterPlayer')
client, _ = item(starter, 'StarterPlayerScripts', 'StarterPlayerScripts')
for parent, cls, name, path in [
    (server, 'ModuleScript', 'Rules', 'src/server/Rules.luau'),
    (server, 'Script', 'GameServer', 'src/server/GameServer.server.luau'),
    (client, 'LocalScript', 'GameClient', 'src/client/GameClient.client.luau'),
]:
    _, props = item(parent, cls, name)
    ET.SubElement(props, 'ProtectedString', {'name': 'Source'}).text = (ROOT / path).read_text()
world, _ = item(doc, 'Workspace', 'Workspace')
for cls, name, dims, pos in [('Part', 'Baseplate', (160, 1, 160), (0, -1, 0)),
                             ('SpawnLocation', 'SpawnLocation', (6, 1, 6), (0, 1, 0))]:
    _, props = item(world, cls, name)
    ET.SubElement(props, 'bool', {'name': 'Anchored'}).text = 'true'
    size = ET.SubElement(props, 'Vector3', {'name': 'size'})
    for axis, value in zip('XYZ', dims): ET.SubElement(size, axis).text = str(value)
    frame = ET.SubElement(props, 'CoordinateFrame', {'name': 'CFrame'})
    for axis, value in zip('XYZ', pos): ET.SubElement(frame, axis).text = str(value)
    for row in range(3):
        for col in range(3):
            ET.SubElement(frame, f'R{row}{col}').text = str(int(row == col))
ET.indent(doc)
ET.ElementTree(doc).write(ROOT / 'Multiplicaciones.rbxlx', encoding='utf-8', xml_declaration=True)
print('Creado Multiplicaciones.rbxlx')
