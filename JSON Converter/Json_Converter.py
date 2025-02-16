import json

birdclasses = 'classes.txt'

bird_dict = {}

with open(birdclasses) as fc:
    for line in fc:
        birdnumber, birdname = line.strip().split(None,1)
        bird_dict[birdnumber] = birdname.strip()
    
out_file = open("bird_classification.json", "w")
json.dump(bird_dict, out_file, indent = 4, sort_keys = False)
out_file.close()