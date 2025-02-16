import json
import requests
import os
import time

# File paths
input_file = "gbif_species_ids.json"  # JSON with GBIF species IDs
output_file = "gbif_iucn_status.json"  # JSON to store IUCN status results

# Function to get IUCN Red List Category from GBIF
def get_iucn_status(species_id):
    """Fetch IUCN Red List Category from GBIF using the species ID (usageKey)."""
    if not species_id or species_id == "Unknown":
        return None

    iucn_url = f"https://api.gbif.org/v1/species/{species_id}/iucnRedListCategory"
    response = requests.get(iucn_url, timeout=10)

    if response.status_code == 200:
        return response.json()  # Returns the full IUCN data
    return None  # No data found

# Load species data from JSON
with open(input_file, "r") as f:
    species_data = json.load(f)

# Try to load existing results to avoid duplicate requests
if os.path.exists(output_file):
    with open(output_file, "r") as f:
        try:
            iucn_status_data = json.load(f)
        except json.JSONDecodeError:
            iucn_status_data = {}  # Start fresh if file is corrupted
else:
    iucn_status_data = {}

# Process each species
for bird_number, species_info in species_data.items():
    species_id = species_info.get("gbif_id")

    if bird_number in iucn_status_data:
        print(f"Skipping {species_info['name']} (already processed)")
        continue

    if species_id == "Unknown":
        print(f"Skipping {species_info['name']} (No valid GBIF ID)")
        continue

    print(f"Fetching IUCN status for {species_info['scientific_name']} (GBIF ID: {species_id})...")

    # Get IUCN status from GBIF
    iucn_data = get_iucn_status(species_id)

    if iucn_data:
        print(f"IUCN Red List Category for {species_info['scientific_name']}: {iucn_data.get('category')}")
    else:
        print(f"No IUCN data found for {species_info['scientific_name']}")
        iucn_data = {"category": "Not Available"}

    # Store results in JSON
    iucn_status_data[bird_number] = {
        "name": species_info["name"],
        "scientific_name": species_info["scientific_name"],
        "gbif_id": species_id,
        "iucn_status": iucn_data.get("category"),
    }

    # Save to file after each request to avoid data loss
    with open(output_file, "w") as f:
        json.dump(iucn_status_data, f, indent=4)

    # Pause to avoid exceeding GBIF API limits
    time.sleep(1)