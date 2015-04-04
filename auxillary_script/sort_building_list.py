fp = open("build_master.txt")

d = {}
for line in fp:
    n = line.split(',')[7].strip()
    d[n] = line

ks = sorted(d, key=lambda key: d[key])
ks = sorted(ks)
fw = open("building_sorted.txt", 'w')
for k in ks:
    print "Key: '", k, "'"
    fw.write(d[k])

fw.close()
fp.close()