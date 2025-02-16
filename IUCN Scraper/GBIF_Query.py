import json
import requests
import urllib.parse
import os
import time

# File paths
input_file = "cleaned_bird_data.json"  # JSON with common bird names
output_file = "gbif_species_ids.json"  # JSON to store species IDs

# Function to get GBIF scientific name from a common name
def get_gbif_scientific_name(common_name):
    """Fetch GBIF scientific name using a common name."""
    search_url = (
        f"https://api.gbif.org/v1/species/search?"
        f"q={urllib.parse.quote(common_name)}"
        f"&qField=VERNACULAR"
        f"&rank=SPECIES"
        f"&status=ACCEPTED"
        f"&datasetKey=d7dddbf4-2cf0-4f39-9b2a-bb099caae36c"  # GBIF Backbone Taxonomy
    )

    response = requests.get(search_url, timeout=10)
    if response.status_code == 200:
        data = response.json()
        
        for species in data.get("results", []):
            if species.get("kingdom") == "Animalia":  # Ensure it's an animal
                return species.get("scientificName")

    return None  # No match found

# Function to get GBIF usageKey using the scientific name
def get_gbif_usage_key(scientific_name):
    """Fetch GBIF usageKey (species ID) using a scientific name."""
    if not scientific_name:
        return None

    match_url = f"https://api.gbif.org/v1/species/match?name={urllib.parse.quote(scientific_name)}"
    response = requests.get(match_url, timeout=10)

    if response.status_code == 200:
        data = response.json()
        if "usageKey" in data:
            return data["usageKey"]
    return None  # No match found

# Load bird names from JSON
with open(input_file, "r") as f:
    bird_data = json.load(f)

# Try to load existing results to avoid duplicate requests
if os.path.exists(output_file):
    with open(output_file, "r") as f:
        try:
            species_ids = json.load(f)
        except json.JSONDecodeError:
            species_ids = {}  # Start fresh if file is corrupted
else:
    species_ids = {}

# Process each bird
for bird_number, common_name in bird_data.items():
    if bird_number in species_ids:
        print(f"Skipping {common_name} (already processed)")
        continue

    print(f"Fetching GBIF scientific name for: {common_name}...")

    # Get scientific name from GBIF
    scientific_name = get_gbif_scientific_name(common_name)

    if scientific_name:
        print(f"Found Scientific Name: {scientific_name}")

        # Get GBIF usageKey using the scientific name
        species_id = get_gbif_usage_key(scientific_name)
        print(f"GBIF usageKey for {scientific_name}: {species_id}")
    else:
        print(f"Could not find an exact species match for {common_name}")
        scientific_name = "No species match"
        species_id = "Unknown"

    # Store results in JSON
    species_ids[bird_number] = {
        "name": common_name,
        "scientific_name": scientific_name,
        "gbif_id": species_id
    }

    # Save to file after each request to avoid data loss
    with open(output_file, "w") as f:
        json.dump(species_ids, f, indent=4)

    # Pause to avoid exceeding GBIF API limits
    time.sleep(1)

print(f"GBIF species IDs saved to {output_file}")
