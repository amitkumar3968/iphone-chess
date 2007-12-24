import sys
args = sys.argv[1:]
args = map(float, args)
print map((255.0).__rdiv__, args)

