import pandas as pd
import json

# Load the adjacency matrix from the provided CSV file
file_path = 'all-all_connectivity_matrix.csv'

# Load the CSV file into a DataFrame
adj_matrix = pd.read_csv(file_path, index_col=0)

# Convert the DataFrame to the desired dictionary format
weights = {}

for row in adj_matrix.index:
    connections = adj_matrix.loc[row]
    weights[str(row)] = {str(col): int(connections[col]) for col in adj_matrix.columns if connections[col] > 0}

# Define the output file path
output_file_path = 'weights.json'

# Write the dictionary to a JSON file
with open(output_file_path, 'w') as json_file:
    json.dump(weights, json_file, indent=4)

print(f"Dictionary has been written to {output_file_path}")
