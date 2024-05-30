import pandas as pd

# Load the CSV file into a DataFrame
file_path = 'EMS175448-supplement-Supplementary_Data_S2.csv'  # Update with your actual file path
df = pd.read_csv(file_path)

# Create a dictionary to categorize neurons by their cell type and additional annotations
neuron_categories = {}

# Iterate through the DataFrame to populate the dictionary
for _, row in df.iterrows():
    celltype = row['celltype']
    annotation = row['additional_annotations']
    left_id = row['left_id']
    right_id = row['right_id']
    
    # Initialize nested dictionaries if they do not exist
    if annotation not in neuron_categories:
        neuron_categories[annotation] = {'left': [], 'right': []}
    
    # Add the neuron IDs to the appropriate lists
    if left_id != 'no pair':
        neuron_categories[annotation]['left'].append(left_id)
    if right_id != 'no pair':
        neuron_categories[annotation]['right'].append(right_id)

# Output the dictionary to a Python file
output_file_path = 'neuron_categories.py'  # Update with your desired output file path
with open(output_file_path, 'w') as file:
    file.write("neuron_categories = {\n")
    for annotation, sides in neuron_categories.items():
        file.write(f"    '{annotation}': {{\n")
        for side, ids in sides.items():
            file.write(f"        '{side}': {ids},\n")
        file.write("    },\n")
    file.write("}\n")

print(f"Neuron categories have been written to {output_file_path}")
