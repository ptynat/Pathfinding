## fonctions

résultats | Berlin | theglaive | 
algoBFS | 6.8907e6 ns | 5.14989e7 ns |
algoDijkstra|8.9197e6 ns | 7.00048e7 ns |
algoGlouton | 848050.0 ns | 4.4995e6 ns |
algoAstar |2.6975e6 ns | 1.04811e7 ns |

### BFS
signature: algoBFS(fname, vD, vA)
retour: path, path_cost(map, path), states
### Dikjstra

signature: algoBFS(fname, vD, vA)
retour: path, path_cost(map, path), states

### Glouton

signature: algoBFS(fname, vD, vA)
retour: path, path_cost(map, path), states

### Astar

signature: algoBFS(fname, vD, vA)
retour: path, path_cost(map, path), states

### path_cost

signature: algoBFS(fname, vD, vA)
retour: path, path_cost(map, path), states

### print_results

signature: print_results(algo_name::String, path, cost, states)
retour: nothing

### readmap
readmap(name::String) 
retour: map, heigth, width
ATTENTION: le fichier en .map doit être dans /src/dat et donc le nom simple du fichier suffit.