using DataStructures
using BenchmarkTools

const MAX = 1000000
const direct = [(-1, 0), (1, 0), (0, 1), (0, -1)]

function readmap(name::String)
    lines = readlines("dat/" * name)
    h = parse(Int, split(lines[2])[2])
    w = parse(Int, split(lines[3])[2])
    map = Matrix{Int64}(undef, h, w)
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
    println("  Distance D → A             : $cost")
    println("  Number of states evaluated : $states")
    path_str = join(["($(p[1]), $(p[2]))" for p in path], "->")
    println("  Path D → A                 : $path_str")
end

function algoBFS(fname, vD, vA)
    states = 0
    map, h, w = readmap(fname)
    queue = Queue{Tuple{Int64, Int64}}()
    parent = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()
    enqueue!(queue, vD)
    parent[vD] = (-1, -1)

    while (isempty(queue) != true)
        current = dequeue!(queue) # (x, y)
        states += 1
        
        if current == vA
            path = backtrack(vD, vA, parent)
            return path, pathCost(map, path), states 
        end

        for (hr, vr) in direct
            newTile = (current[1] + hr,current[2] +vr)
            inbound = (newTile[1] in 1:h) && (newTile[2] in  1:w)
            
            if inbound && !haskey(parent, newTile) && (map[newTile[1], newTile[2]] != MAX)
                enqueue!(queue, newTile) 
                parent[newTile] = current
            end
        end
    end
    return nothing, MAX, states
end

function backtrack(vD::Tuple{Int64, Int64}, vA::Tuple{Int64, Int64}, parent::Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}})
    path = Vector{Tuple{Int64, Int64}}()
    current = vA
    while current != vD
        push!(path, current)
        current = parent[current]
    end
    push!(path, vD)
    return reverse(path)
end

function algoDijkstra(fname, vD, vA)
    states = 0
    map, h, w = readmap(fname)
    L = PriorityQueue{Tuple{Int64, Int64}, Int64}()
    cost2 = fill(MAX, (h, w))
    parent = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()

    L[vD] = 0
    cost2[vD[1], vD[2]] = 0
    parent[vD] = (-1, -1)

    while !(isempty(L))
        curr1, curr2 = dequeue!(L)
        states += 1

        if (curr1, curr2) == vA
            finalpath = backtrack(vD, vA, parent)
            return finalpath,  pathCost(map, finalpath), states
        end

        for (hr, vr) in direct
            newTile = ((curr1 + hr), (curr2 + vr))
            inbound= ( 1 <= newTile[1] <= h) && (1 <= newTile[2] <= w)
            if inbound && map[newTile[1], newTile[2]] != MAX
                cost = map[newTile[1], newTile[2]] + cost2[curr1, curr2]
                if cost < (cost2[newTile[1], newTile[2]])
                    parent[newTile] = (curr1, curr2)
                    cost2[newTile[1], newTile[2]] = cost
                    L[newTile] = cost
                end
            end
        end
    end
    return nothing, MAX, states
end

function algoGlouton(fname, vD, vA)
    states = 0
    map, h, w = readmap(fname)
    L = PriorityQueue{Tuple{Int64, Int64}, Int64}()
    dist2 = fill(MAX, (h, w))
    parent = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()

    L[vD] = 0
    dist2[vD[1], vD[2]] = 0
    parent[vD] = (-1, -1)
    while !(isempty(L))
        cX, cY = dequeue!(L)
        states += 1

        if (cX, cY) == vA
            path = backtrack(vD, vA, parent)
            return path, pathCost(map, path), states
        end

        for (hr, vr) in direct
            newTile = ((cX + hr), (cY + vr))
            inbound= ( 1<= newTile[1] <= h) && (1 <= newTile[2] <= w) 
            if inbound && map[newTile[1], newTile[2]] != MAX && !haskey(parent, newTile)
                cost = abs(newTile[1] - vA[1]) + abs(newTile[2] - vA[2])
                parent[newTile] = (cX, cY)
                dist2[newTile[1], newTile[2]] = cost
                L[newTile] = cost
            end
        end
    end
    return nothing, MAX, states
end

function algoAstar(fname, vD, vA)
    map, h, w = readmap(fname)
    L = PriorityQueue{Tuple{Int64, Int64}, Int64}()
    prio = fill(MAX, (h, w))
    cost = fill(MAX, (h, w))
    parent = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()
    states = 0

    L[vD] = 0
    prio[vD[1], vD[2]] = 0
    cost[vD[1], vD[2]] = 0
    parent[vD] = (-1, -1)

    while !(isempty(L))
        cX, cY = dequeue!(L)
        states += 1

        if (cX, cY) == vA
            path = backtrack(vD, vA, parent)
            return path, pathCost(map, path), states 
        end

        for (hr, vr) in direct
            newTile = ((cX + hr), (cY + vr))
            inbound= ( 1<= newTile[1] <= h) && (1 <= newTile[2] <= w)
            
            if inbound
                cost2 = map[newTile[1], newTile[2]] + cost[cX, cY]
                dist = abs(newTile[1] - vA[1]) + abs(newTile[2] - vA[2])
                priotot = dist + cost2

                if cost2 < (cost[newTile[1], newTile[2]])
                    parent[newTile] = (cX, cY)
                    cost[newTile[1], newTile[2]] = cost2
                    prio[newTile[1], newTile[2]] = priotot
                    L[newTile] = priotot

                end
            end
        end
    end
    return nothing, MAX, states
end


t1 = @benchmark algoBFS("Berlin_0_256.map", (151, 2), (1, 2))
t2 = @benchmark algoDijkstra("Berlin_0_256.map", (151, 2), (1, 2))
t3 = @benchmark algoGlouton("Berlin_0_256.map", (151, 2), (1, 2))
t4 = @benchmark algoAstar("Berlin_0_256.map", (151, 2), (1, 2))

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
println("Instance 3, swampofsorrows")

path, cost, states = algoBFS("swampofsorrows.map", (426, 45), (484, 419))
printResults("BFS", path, cost, states)

path, cost, states = algoDijkstra("swampofsorrows.map", (426, 45), (484, 419))
printResults("Dijkstra", path, cost, states)

path, cost, states = algoGlouton("swampofsorrows.map", (426, 45), (484, 419))
printResults("Gouton", path, cost, states)

path, cost, states = algoAstar("swampofsorrows.map", (426, 45), (484, 419))
printResults("Astar", path, cost, states)