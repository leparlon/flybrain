# FlyBrain
Information on how this was done: [How it was done](./DataProcessing/README.md)

Similar to WormBrain, this GODOT plugin is simulating a drosophila fly brain (fruit fly), using a similar map. Since this animal is much more complex, the simulation is much much worse.

Warning: Just loading this plugin might freeze or slowdown your IDE, it's big.

## Installation
1. Download the plugin from the Godot Asset Library or clone the repository.
2. Copy the `GodotPlugin/addons/fly_brain_plugin` folder into your project's `addons` directory
3. Enable the plugin in `Project > Project Settings > Plugins`.

## Quick Usage
1. Add the `FlyNode` to your scene.
2. Customize the worm's properties in the inspector.
3. The fly will "collide" with any `Area2D`, and will eat any that is part of the group `fly_food`.
4. If you want to contain the fly, make sure to decrease the limiting rect in the inspector.

This plugin contains some supporting files that contains the neurons and what they mean. If you want information on these, go [here](./DataProcessing/README.md).
 2 files are important for understanding and using this:
 `drosophila.gd` and `brain.gd`

### Brain
   This file loads up all the neurons, weights and manages the connections. 
    You can modify this file slightly if you want to stimulate specific neurons on specific ways. 
    The current iteration is pretty blunt, just stimulate all neurons of one fuction of one side the same ammount. 
    It probably feels like inhalling a m3 of clorine.

#### How movement is simulated
   There are just too many neurons and I could not find anything more fine tunned about what each does. 
    So, the movement calculation is pretty simple: 
    Sum all the values the neuron VHC related neurons of each side (divide by 100 because it is too much), and move the sprite to the side of which this value was bigger a proportional ammount.

#### How neurons are stimulated
   Neurons are stimulated using `dendrite_accumulate` that will simply add up each neuron weight to its connections.
 
####
### Drosophila
   This file is just a simplistic way to interact with the brain. Built mostly as an example because I, frankly, have no idea on what to do with this brain. Hence, open source.  
   Some utility flags and variables:  
    accumleft and accumright are what holds the accumulated values of the (sort of) "motor" neurons. 
    All the next are arrays of 2 booleans, representing [left, right]
    
     stimulate_vision
     stimulate_olfactory
     stimulate_warm
     stimulate_cold
     stimulate_taste_external
     stimulate_taste_internal

   To use them, if in drosophila code you do: 
    ```Brain.stimulate_vision = [true, false]```  
    All the neurons related to vision on the left side will be stimulated (dendrite_accumulate will run on them)

## License
This project is licensed under the MIT License.

## Acknowledgements
This project was based on WormBrain which in turn was based on the worm-sim made by Seth Miller.  
Huge thanks to him for sharing that online.

All the data used to convert a fly brain to Godot came from this article:
[Link to article](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7614541/)
Winding M, Pedigo BD, Barnes CL, Patsolic HG, Park Y, Kazimiers T, Fushiki A, Andrade IV, Khandelwal A, Valdes-Aleman J, Li F, Randel N, Barsotti E, Correia A, Fetter RD, Hartenstein V, Priebe CE, Vogelstein JT, Cardona A, Zlatic M. The connectome of an insect brain. Science. 2023 Mar 10;379(6636):eadd9330. doi: 10.1126/science.add9330. Epub 2023 Mar 10. PMID: 36893230; PMCID: PMC7614541.
