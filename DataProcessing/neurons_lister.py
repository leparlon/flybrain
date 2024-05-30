import pandas as pd

# Load the adjacency matrix from the provided CSV file
file_path = 'all-all_connectivity_matrix.csv'

# Load the CSV file into a DataFrame
adj_matrix = pd.read_csv(file_path, index_col=0)

# Extract the list of neurons
neurons = list(adj_matrix.index)

# Define the output file path
output_file_path = 'neurons.gd'

# Write the list of neurons to a text file in the specified format
with open(output_file_path, 'w') as file:
    file.write('var neurons = [\n')
    for neuron in neurons:
        file.write(f'    "{neuron}",\n')
    file.write(']\n')

print(f"Neuron list has been written to {output_file_path}")
