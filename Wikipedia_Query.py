import json
import wikipediaapi
import time
import requests
import os

input_file = "cleaned_bird_data.json"  
output_file = "bird_descriptions.json"

wiki_wiki = wikipediaapi.Wikipedia(
    user_agent='BirdQueryBot1 (breachexe@gmail.com)',
    language='en'
)

with open(input_file, "r") as f:
    bird_data = json.load(f)

# Try to load existing data (if the file exists) to avoid duplicate processing
if os.path.exists(output_file):
    with open(output_file, "r") as f:
        try:
            bird_descriptions = json.load(f)
        except json.JSONDecodeError:
            bird_descriptions = {}  # Start fresh if JSON is corrupted
else:
    bird_descriptions = {}

# Loop through each bird and fetch its Wikipedia description
for bird_number, bird_name in bird_data.items():
    if bird_number in bird_descriptions:
        print(f"Skipping {bird_name} (already processed)")
        continue  # Skip if already processed

    retries = 3  # Number of retries
    success = False
    attempt = 0

    while not success and attempt < retries:
        try:
            print(f"Fetching Wikipedia description for: {bird_name}... (Attempt {attempt + 1})")
            page = wiki_wiki.page(bird_name)
            
            if page.exists():
                description = page.summary
            else:
                description = "No description available."

            # Store in dictionary
            bird_descriptions[bird_number] = {
                "name": bird_name,
                "description": description
            }

            # **Write to JSON file after each bird is processed**
            with open(output_file, "w") as f:
                json.dump(bird_descriptions, f, indent=4)

            success = True  # Set success flag to break the loop
            
        except requests.exceptions.ReadTimeout as e:
            print(f"Timeout error: {e}. Retrying...")
            attempt += 1
            time.sleep(2)  # Wait before retrying
            
        except Exception as e:
            print(f"Error occurred: {e}")
            break
        
    time.sleep(1)
