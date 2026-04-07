using DataStructures
using BenchmarkTools
using Images, Colors, FileIO

const MAX = 1000000
const direct = [(-1, 0), (1, 0), (0, 1), (0, -1)]

function readmap(name::String)
    lines = readlines("dat/" * name)
    h = parse(Int, split(lines[2])[2])
    w = parse(Int, split(lines[3])[2])
    map = Matrix{Int64}(undef, h, w)
    #replacing the right cost on each tile.
    for (i, line) in enumerate(lines[5:end])
        for (j, char) in enumerate(line)
            map[i, j] = (char == '.' ? 1 : (char == 'S' ? 5 : (char == 'W' ? 8 : MAX)))
        end
    end
    return (map, h, w)
end

function pathCost(map::Matrix{Int64}, path::Vector{Tuple{Int64, Int64}})
    length(path) <= 1 && return 0
    return sum(map[p[1], p[2]] for p in path[2:end])
end

function printResults(algo_name::String, path, cost, states)
    println("Algorithm: $algo_name ")
    if path === nothing
        println("pas de chemin trouvé")
        println("evaluated: $states")
        return
    end 
    println("  Distance D -> A             : $cost")
    println("  Number of states evaluated : $states")

    println("  Path D -> A                 : $path")
end

#Function takes a successor dict to find the best path.
function backtrack(vD::Tuple{Int64, Int64}, vA::Tuple{Int64, Int64}, parent::Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}})
    path = Vector{Tuple{Int64, Int64}}()
    current = vA
    #going back using the parent dict
    while current != vD
        push!(path, current)
        current = parent[current]
    end
    push!(path, vD)
    return reverse(path) #path is from end to start, hence the reverse.
end

#Creates an image from a given Matrix input using Images.
function mapToImage(map::Matrix{Int64}, h, w, MAX)
    img = zeros(RGB{N0f8}, h, w) #Création de la carte. Avec des RGB, en normalisé 8bits.


    for i in 1:h, j in 1:w
        if map[i, j] == MAX
            # Mur = Noir
            img[i, j] = RGB(0, 0, 0)
        elseif map[i, j] == 8  # Water (W)
            # Eau = Bleu
            img[i, j] = RGB(0, 0.5, 1)
        elseif map[i, j] > 1
            # Zone lente (S) = Jaune
            img[i, j] = RGB(1, 1, 0)
        else
            # Normal (.) = Blanc
            img[i, j] = RGB(1, 1, 1)
        end
    end
    return img
end

#colors a path
function dPath(img, path, color=RGB(1, 0, 0))
    for (x, y) in path
        img[x, y] = color #colorisation du chemin
    end
    return img
end

#Draw a single path on the map (from file name).
function pathOnMap(file, path, vD, vA, name)
    map, h, w = readmap(file)
    img = mapToImage(map, h, w, MAX)

    if !(isnothing(path))
        dPath(img, path, RGB(1, 0, 0)) #color can be changed
    end
    img[vD[1], vD[2]] = RGB(0, 1, 0)#Start
    img[vA[1], vA[2]] = RGB(0, 0, 1)#End

    filename = "out$name.png"
    save(filename, img)

end

#same principle as above, but with multiple path.
function saveMissionsMap(fname, pathes, outputname="output")
    map, h, w = readmap(fname)
    img = mapToImage(map, h, w, MAX)

    # 5 colors, max 5 AMR
    colors = [
        RGB(1, 0, 0),      # Rouge
        RGB(0, 0, 1),      # Bleu
        RGB(0, 1, 0),      # Vert
        RGB(1, 0.5, 0)    # Orange
    ]

    for (id, apath, vD, vA) in pathes
        #color choice (limited to 4 but can be increased)
        if !isnothing(apath)
            color = colors[id]
            dPath(img, apath, color) #marking the path on the image
        end
        #making start and end
        img[vD[1], vD[2]] = RGB(0, 1, 0)
        img[vA[1], vA[2]] = RGB(0, 0, 1)
    end

    outname = "$outputname.png"
    save(outname, img)

end



#=
#REMOVE COMMENTAIRY TO SHOW BENCHMARK AND RUNNING RESULTS
t1 = @benchmark algoBFS("theglaive.map", (189, 193), (226, 437))
t2 = @benchmark algoDijkstra("theglaive.map", (189, 193), (226, 437))
t3 = @benchmark algoGlouton("theglaive.map", (189, 193), (226, 437))
t4 = @benchmark algoAstar("theglaive.map", (189, 193), (226, 437))

println("algoBFS: ", median(t1.times), " ns")
println("algoDijkstra: ", median(t2.times), " ns")
println("algoGlouton: ", median(t3.times), " ns")
println("algoAstar: ", median(t4.times), " ns")


println("Instance 1, Berlin")

path, cost, states = algoBFS("Berlin_0_256.map", (151, 2), (1, 2))
printResults("BFS", path, cost, states)

path, cost, states = algoDijkstra("Berlin_0_256.map", (151, 2), (1, 2))
printResults("Dijkstra", path, cost, states)

path, cost, states = algoGlouton("Berlin_0_256.map", (151, 2), (1, 2))
printResults("Gouton", path, cost, states)

path, cost, states = algoAstar("Berlin_0_256.map", (151, 2), (1, 2))
printResults("Astar", path, cost, states)

#-------------------------Map 2----------------------------------------
println("Instance 2, AcrosstheCape")

path, cost, states = algoBFS("AcrosstheCape.map", (151, 2), (1, 2))
printResults("BFS", path, cost, states)

path, cost, states = algoDijkstra("AcrosstheCape.map", (151, 2), (1, 2))
printResults("Dijkstra", path, cost, states)

path, cost, states = algoGlouton("AcrosstheCape.map", (151, 2), (1, 2))
printResults("Gouton", path, cost, states)

path, cost, states = algoAstar("AcrosstheCape.map", (151, 2), (1, 2))
printResults("Astar", path, cost, states)

#-------------------------Map 3---------------------------------------
println("Instance 3, theglaive")

@time path, cost, states = algoBFS("theglaive.map", (189, 193), (226, 437))
printResults("BFS", path, cost, states)

@time path, cost, states = algoDijkstra("theglaive.map", (189, 193), (226, 437))
printResults("Dijkstra", path, cost, states)

@time path, cost, states = algoGlouton("theglaive.map", (189, 193), (226, 437))
printResults("Gouton", path, cost, states)

@time path, cost, states = algoAstar("theglaive.map", (189, 193), (226, 437))
printResults("Astar", path, cost, states)
=#