using DataStructures


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

    #permet de traiter de manière efficasse les meilleurs candidats en premier, meilleur cout en moyenne
    L = PriorityQueue{Tuple{Int64, Int64}, Int64}()
    cost = fill(MAX, (h, w))
    #Parent: retrouver les prédécesseur une fois le but atteint.
    parent = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()
    states = 0
    L[vD] = 0

    cost[vD[1], vD[2]] = 0
    parent[vD] = (-1, -1)

    while !(isempty(L))
        cX, cY = dequeue!(L)
        states += 1
        #Cas de base
        if (cX, cY) == vA 
            path = backtrack(vD, vA, parent)
            return path, pathCost(map, path), states 
        end

        #Quatre directions
        for (hr, vr) in direct
            newTile = ((cX + hr), (cY + vr))
            inbound= ( 1<= newTile[1] <= h) && (1 <= newTile[2] <= w)
            
            if inbound
                cost2 = map[newTile[1], newTile[2]] + cost[cX, cY]#g(x)
                dist = abs(newTile[1] - vA[1]) + abs(newTile[2] - vA[2])#h(x)
                priotot = dist + cost2 #heuristic

                if cost2 < (cost[newTile[1], newTile[2]]) #rexploration, default at MAX
                    parent[newTile] = (cX, cY)
                    cost[newTile[1], newTile[2]] = cost2
                    L[newTile] = priotot

                end
            end
        end
    end
    return nothing, MAX, states
end