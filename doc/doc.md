## Fonctions de Pathfinding

### Algorithmes Standard (main.jl / pathFinding.jl)

| Algorithme | Berlin | theglaive | 
|-----------|--------|-----------|
| algoBFS | 6.8907e6 ns | 5.14989e7 ns |
| algoDijkstra | 8.9197e6 ns | 7.00048e7 ns |
| algoGlouton | 848050.0 ns | 4.4995e6 ns |
| algoAstar | 2.6975e6 ns | 1.04811e7 ns |

#### algoBFS
**Signature:** `algoBFS(fname::String, vD::Tuple, vA::Tuple) -> (path, cost, states)`
- Breadth-First Search, chemin le plus court en nombre de cases
- **Retour:** chemin, coût, nombre d'états explorés

#### algoDijkstra
**Signature:** `algoDijkstra(fname::String, vD::Tuple, vA::Tuple) -> (path, cost, states)`
- Dijkstra, optimal en coût (terrain variable)
- **Retour:** chemin, coût, états explorés

#### algoGlouton
**Signature:** `algoGlouton(fname::String, vD::Tuple, vA::Tuple) -> (path, cost, states)`
- Greedy Manhattan, plus rapide mais pas optimal
- **Retour:** chemin, coût, états explorés

#### algoAstar
**Signature:** `algoAstar(fname::String, vD::Tuple, vA::Tuple) -> (path, cost, states)`
- A*, optimal (coût réel + heuristique)
- **Retour:** chemin, coût, nombre d'états explorés

---

### Pathfinding Temporel avec Collision (SIPP.jl)

#### Struct AMRs
mutable struct AMRs
    nb::Int64                           # ID du robot
    position::Tuple{Int64, Int64}       # Position actuelle (row, col)
    time::Int64                         # disponible pour démarrer une mission à t
end

#### algoAstarMod
**Signature:** `algoAstarMod(vD::Tuple, vA::Tuple, D::Dict, st::Int64) -> (path, cost, D)`
- A* avec collision gérée
- Paramètres:
  - vD: départ
  - vA: arrivée
  - D: timeline `(Dict{time, Set{positions_occupées}})`
  - st: temps de départ
- Retour: chemin, coût (temps absolu), timeline mise à jour

#### planMission
**Signature:** `planMission(amrs::Vector{AMRs}, vD::Tuple, vA::Tuple, timeLine::Dict, stime::Int64, output=true) -> (amr_selected, path, cost)`
- Sélectionne le meilleur AMR pour une mission (pickup → delivery)
- Paramètres:
  - amrs: liste des AMR
  - vD: Position du colis
  - vA: destination
  - timeLine: contraintes temporelles
  - stime: début de mission
  - output: afficher logs (true/false)
- Retour: AMR sélectionné, chemin complet (pickup + delivery), temps d'arrivée

#### updateTimeline
**Signature:** `updateTimeline(map::Matrix, V::Vector{Tuple}, D::Dict, startingTime::Int64) -> Dict`
- Enregistre les cases occupées par un chemin dans la timeline
- Tient compte du coût des cases
- Paramètres:
  - map: matrice des coûts
  - V: chemin à mettre à jour
  - D: timeline à mettre à jour
  - startingTime: temps actuel
- Retour: timeline mise à jour

#### runMissions
**Signature:** `runMissions(missions::Vector{Tuple}, amrs::Vector{AMRs}, timeline::Dict) -> Vector`
- Exécute plusieurs missions séquentiellement
- Chaque mission devient une contrainte pour les suivantes
- Format: `[(pickup::Tuple, delivery::Tuple, start_time::Int64), ...]`
- Retour: logs:  `[(amr_id, path, pickup, delivery), ...]`

---

### Utilitaires de Visualisation (main.jl)

#### mapToImage
**Signature:** `mapToImage(map::Matrix{Int64}, h, w, MAX) -> Matrix{RGB}`
Légende des couleurs:
- Noir: Murs (@)
- Blanc: Cases libres (.)
- Jaune: Zones lentes (S, coût 5)
- Bleu: Eau (W, coût 8)

#### pathOnMap
**Signature:** `pathOnMap(file::String, path, vD::Tuple, vA::Tuple, name::String)`
- Trace un chemin simple sur la carte
- Sauvegarde en PNG: out{name}.png
- Couleurs: chemin=rouge, départ=vert, arrivée=bleu

#### saveMissionsMap
**Signature:** `saveMissionsMap(fname::String, pathes::Vector, outputname::String="output")`
- Trace PLUSIEURS chemins (missions)
- Chaque AMR en couleur différente
- Sauvegarde en PNG: {outputname}.png
- Format pathes: [(amr_id, path, pickup, delivery), ...]

---

### Utilitaires Généraux

#### pathCost
**Signature:** `pathCost(map::Matrix{Int64}, path::Vector{Tuple}) -> Int64`
- Calcule le coût total d'un chemin (somme des cases)
- Retour: coût total

#### backtrack
**Signature:** `backtrack(vD::Tuple, vA::Tuple, parent::Dict) -> Vector{Tuple}`
- Reconstruit le chemin depuis le dict parent (A*/Dijkstra)
- Retour: chemin du départ à l'arrivée

#### printResults
**Signature:** `printResults(algo_name::String, path, cost, states)`
- Affiche les résultats de pathfinding (coût, états, chemin)

#### readmap
**Signature:** `readmap(name::String) -> (map, h, w)`
- Charge une carte depuis le dossier /dat
- ATTENTION: le fichier en .map doit être dans /dat et le nom simple du fichier suffit
- Retour: matrice de coûts, hauteur, largeur