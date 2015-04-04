fp = open("../msu_map/map_system.txt")

vertices = {}
vIndexes = {}
vIndexList = []
edges = []
vc = 0
comments = ""

for line in fp:
    if line.startswith("#"): comments += line
    elif line.startswith("E"):
        edges.append(line)
    elif line.startswith("V"):
        vIndex = line.split('|')[1]
        vIndexes[vIndex] = vc
        vIndexList.append(vIndex)
        vertices[vIndex] = line.strip("\n") + "|"
        vc += 1

fw = open("map_system_with_adjacency_list.txt", 'w')

for i in range(0, len(edges)):
    lineList = edges[i].split('|')
    aVertex = lineList[1]
    bVertex = lineList[2]
    edgeLength = lineList[4]
    try:
        vertices[aVertex] += str(vIndexes[bVertex]) + "," + str(i) + ";"
        vertices[bVertex] += str(vIndexes[aVertex]) + "," + str(i) + ";"
    except KeyError, msg:
        if '0' not in msg : print "KeyError:", msg

fw.write(comments)
for i in vIndexList:
    fw.write(vertices[i].strip(";") + "\n")
for line in edges:
    fw.write(line)

fw.close()
fp.close()