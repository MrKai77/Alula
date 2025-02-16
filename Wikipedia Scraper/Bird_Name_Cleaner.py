import json
import re


input_file = "bird_classification.json"
output_file = "cleaned_bird_data.json"

with open(input_file, "r") as f:
    bird_data = json.load(f)

pattern = r"\s*\(.*?\)"

cleaned_birds = {}

for bird_number, bird_name in bird_data.items():
    cleaned_name = re.sub(pattern, "", bird_name).strip()

    cleaned_birds[bird_number] = cleaned_name

with open(output_file, "w") as f:
    json.dump(cleaned_birds, f, indent=4)
