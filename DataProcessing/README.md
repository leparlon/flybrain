# Fly Brain Data

## How was it done
### Source:
All the data used to convert a fly brain to Godot came from this article:
[Link to article](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7614541/)
Winding M, Pedigo BD, Barnes CL, Patsolic HG, Park Y, Kazimiers T, Fushiki A, Andrade IV, Khandelwal A, Valdes-Aleman J, Li F, Randel N, Barsotti E, Correia A, Fetter RD, Hartenstein V, Priebe CE, Vogelstein JT, Cardona A, Zlatic M. The connectome of an insect brain. Science. 2023 Mar 10;379(6636):eadd9330. doi: 10.1126/science.add9330. Epub 2023 Mar 10. PMID: 36893230; PMCID: PMC7614541.   
It was a pretty simple process, given all the data was readily available for download on csv format.
### Process
#### Weights and connections
On the article's Supplementary Material section, there is a Supplementary Data S1 zip file, which contains a bunch of csv files representing the connections between neurons. The files represent specific types of connections between the neurons and their dendrites and axoms. I wanted a general, and I believe I found it on `all-all_connectivity_matrix.csv` (not included on this repo).
In order to format it in a way that I could use it on Godot, I ran `converter.py` that transformed the huge 3000x3000 sparse csv matrix to a list of connections and weights: 
    
'Neuron Name' = [Connected Neuron = weight, Connected Neuron = weight, ...]   
'Neuron Name' = [Connected Neuron = weight, Connected Neuron = weight, ...]   
...   
    
(`\GodotPlugin\addons\fly_brain_plugin\weights.gd` was edited to be used)
   
#### Neuron function
In order to be simulated, I needed to know which of the neurons are sensory and which are responsible (or almost) for muscle movement. That information I've found on another suplementary file, Suplementary Data S2, which contained `EMS175448-supplement-Supplementary_Data_S2.csv`.
On that file, the header read: left_id,right_id,celltype,additional_annotations,level_7_cluster
I ignored level_7_cluster, but the rest told me if the neuron was left or right side, and its macro function (ie: celltype tells if it is sensory for example). And using the annotations it was possible to accertain its micro function (ie: a sensory neuron with a visual anotation is visual)
`categorizer_v2.py` was created to categorize every neuron, and create 3 files:
   
`sensory_neurons.gd` listing sensory related neurons:
    'Visual', 'Olfactory (Smell)', 'Thermo-Warm (Warm Temperature)', 'Gustatory External (Taste External)', 'Gustatory Pharynx (Taste Internal)' and 'Thermo-Cold (Cold Temperature)':

`ascending_neurons.gd` listing ascending sensory related neurons: 
    'Mechanosensory Chordotonals', 'Nociceptive (Pain Sensing)', 'Mechanosensory Class II/III':,'Proprioceptive (Body Position)'

`additional_neurons.gd` which was everything else. And here, I was only interested on the neurons that might create movement, so my assumption from the article was that these were the ones Descending Neurons to the Ventral Nerve Cord, annotated as `DN-VNC`

#### List of Neurons
The plugin code needs a simple list of all the neurons in order to run the connectome, so that is what `neurons_lister.py` does.

All the above mentioned files can be found (slighly edited from the scripts output) on `\GodotPlugin\addons\fly_brain_plugin\`