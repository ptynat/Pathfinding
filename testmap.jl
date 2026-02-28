using DataStructures
using Plots
using BenchmarkTools

const MAX = 1000000

function readmap(name::String)
    lines = readlines(name)
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

(m, h1, w1) = readmap("swampofsorrows.map")

#println(arraysize(m))
findall(x->x == 8, m)

const direct = [(-1, 0), (1, 0), (0, 1), (0, -1)]

function BFS(fname, vD, vA)
    println("...init...")
    map, h, w = readmap(fname)
    queue = Queue{Tuple{Int64, Int64}}()
    parent = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()
    enqueue!(queue, vD)
    parent[vD] = (-1, -1)

    while(isempty(queue) != true)
        current = dequeue!(queue) # (x, y)
        
        if current == vA
            println("...found...")
            return backtrack(vD, vA, parent)
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
    return []
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

function Dijkstra(fname, vD, vA)
    map, h, w = readmap(fname)
    L = PriorityQueue{Tuple{Int64, Int64}, Int64}()
    cost2 = fill(MAX, (h, w))
    parent = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()

    L[vD] = 0
    cost2[vD[1], vD[2]] = 0
    parent[vD] = (-1, -1)

    while !(isempty(L))
        curr1, curr2 = dequeue!(L)

        if (curr1, curr2) == vA
            return backtrack(vD, vA, parent), cost2
        end

        for (hr, vr) in direct
            newTile = ((curr1 + hr), (curr2 + vr))
            inbound= ( 1 <= newTile[1] <= h) && (1 <= newTile[2] <= w)
            if inbound
                cost = map[newTile[1], newTile[2]] + cost2[curr1, curr2]
                if cost < (cost2[newTile[1], newTile[2]])
                    parent[newTile] = (curr1, curr2)
                    cost2[newTile[1], newTile[2]] = cost
                    L[newTile] = cost
                end
            end
        end
    end
    return nothing
end

function Gloutton(fname, vD, vA)
    map, h, w = readmap(fname)
    L = PriorityQueue{Tuple{Int64, Int64}, Int64}()
    dist2 = fill(MAX, (h, w))
    parent = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()

    L[vD] = 0
    dist2[vD[1], vD[2]] = 0
    parent[vD] = (-1, -1)
    println("...initialized Gloutton...")
    while !(isempty(L))
        cX, cY = dequeue!(L)
        if (cX, cY) == vA
            println("finished Gloutton")
            return backtrack(vD, vA, parent), dist2
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
    return nothing
end

function Astar(fname, vD, vA)
    map, h, w = readmap(fname)
    L = PriorityQueue{Tuple{Int64, Int64}, Int64}()
    prio = fill(MAX, (h, w))
    cost = fill(MAX, (h, w))
    parent = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()

    L[vD] = 0
    prio[vD[1], vD[2]] = 0
    cost[vD[1], vD[2]] = 0
    parent[vD] = (-1, -1)

    println("...initialized Astar...")

    while !(isempty(L))
        cX, cY = dequeue!(L)
        if (cX, cY) == vA
            return backtrack(vD, vA, parent), cost
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
    return nothing
end

t1 = @benchmark BFS("Berlin_0_256.map", (151, 2), (1, 2))
t2 = @benchmark Dijkstra("Berlin_0_256.map", (151, 2), (1, 2))
t3 = @benchmark Gloutton("Berlin_0_256.map", (151, 2), (1, 2))
t4 = @benchmark Astar("Berlin_0_256.map", (151, 2), (1, 2))

println("BFS: ", median(t1.times), " ns")
println("Dijkstra: ", median(t2.times), " ns")
println("Gloutton: ", median(t3.times), " ns")
println("Astar: ", median(t4.times), " ns")