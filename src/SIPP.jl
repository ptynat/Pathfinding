const FNAME = "version1.map"
const MAP, MAP_H, MAP_W = readmap(FNAME)
const M = fill(MAX, (MAP_H, MAP_W))

#Structure to keep track of AMRs: Where and Availability
mutable struct AMRs
    nb::Int64
    position::Tuple{Int64, Int64}
    time::Int64
end

function algoAstarMod(vD, vA, D, st)
    map, h, w = MAP, MAP_H, MAP_W
    L = PriorityQueue{Tuple{Int64, Int64}, Int64}()
    cost = fill(MAX, (MAP_H, MAP_W))
    parent = Dict{Tuple{Int64, Int64}, Tuple{Int64, Int64}}()


    L[vD] = 0
    cost[vD[1], vD[2]] = 0
    parent[vD] = (-1, -1)

    while !(isempty(L))
        cX, cY = dequeue!(L)

        if (cX, cY) == vA
            path = backtrack(vD, vA, parent)
            return path, pathCost(map, path), D
        end

        for (hr, vr) in direct
            newTile = ((cX + hr), (cY + vr))
            inbound= ( 1<= newTile[1] <= h) && (1 <= newTile[2] <= w)
            if inbound
                tcost = map[newTile[1], newTile[2]] #time cost
                cost2 = cost[cX, cY] + tcost

                #verifying all the timesteps 
                noColision = true
                for time in (st + cost2 - tcost):(st + cost2 - 1)
                    if haskey(D, time) && newTile in D[time]
                        noColision = false
                        break
                    end
                end
                
                if noColision
                    dist = abs(newTile[1] - vA[1]) + abs(newTile[2] - vA[2])
                    priotot = dist + cost2

                    if cost2 < (cost[newTile[1], newTile[2]])
                        parent[newTile] = (cX, cY)
                        cost[newTile[1], newTile[2]] = cost2
                        L[newTile] = priotot
                    end
                end
            end
        end
    end
    return nothing, MAX, D
end

#Plan a Mission from best AMR to cost and path return checking for colisions .
function planMission(amrs::Vector{AMRs}, vD::Tuple{Int64, Int64}, vA::Tuple{Int64, Int64}, timeLine::Dict, stime::Int64, output=True)
    choice = nothing
    cost = MAX
    path = nothing
    if output
        println("Mission from  $vD  to $vA :")
    end

    for amr in amrs
        #mission start is thelatest time of the two.
        startT = max(amr.time, stime)
        #pathing to pickup
        tPath, tCost, _ = algoAstarMod(amr.position, vD, timeLine, startT)
        
        if isnothing(tPath)
            continue
        end

        endtime = startT + tCost #updated starting time for Astar
        delPath, delCost, _ = algoAstarMod(vD, vA, timeLine, endtime)#pickup to delivery

        if isnothing(delPath)
            println("No valid path for delivery for mission for AMR: $(amr.nb)")
            continue
        end
        totalCost = endtime + delCost

        if totalCost < cost #pitching each AMR choice against each other.
            choice = amr
            path = vcat(tPath[1:end-1], delPath)
            cost = totalCost
            
        end
    end

    println("-- Result: $(isnothing(choice) ? "No path" : "Sucsess AMR number: $(choice.nb)") --\n")
    if (output)
        println("path: $path \n cost: $cost")
    end
    return choice, path, cost
end

#Adds all the occupied spaces over a mission in the timeline.
function updateTimeline(map::Matrix, V::Vector{Tuple{Int64, Int64}}, D::Dict{Int64, Set{Tuple{Int64, Int64}}}, startingTime::Int64)
    tm = startingTime
    #adding the occupied cases at the right time for the right duration
    for place in V
        cost = map[place[1], place[2]]
        for occ in tm:(tm+cost-1)
            if !(haskey(D, occ))
                D[occ] = Set{Tuple{Int64, Int64}}()
            end
            
            push!(D[occ], place)
        end
        tm += cost
    end
    return D
end


#---- Execution and example of use.
timeline1 = Dict{Int64, Set{Tuple{Int64, Int64}}}()
timeline2 = Dict{Int64, Set{Tuple{Int64, Int64}}}()


# This serves as a test to run the missions
function runMissions(missions, amrs, timeline, on=false)
    #Going through the missions one after another, and adding path to the constraints
    missionsLog = []
    for (pickup, delivery, stime) in missions
        amr, bpath, cost = planMission(amrs, pickup, delivery, timeline, stime, on)
        

        if !isnothing(amr)
            startT = max(amr.time, stime) #starting time
            delivery_time = cost #end time
            
            push!(missionsLog, (amr.nb, bpath, pickup, delivery))#logs of all missions
            amr.position = delivery
            amr.time = delivery_time
            updateTimeline(MAP, bpath, timeline, startT)#adding the constraint
        end
    end
    return missionsLog
end

missions1 = [
    ((1, 4), (11, 9), 0),     
    ((1, 14), (11, 4), 10)  

]
amrs1 = [
    AMRs(1, (1, 4), 0),


]

missions2 = [
    ((1, 4), (11, 9), 0),     
    ((1, 14), (11, 4), 3),    
    ((1, 4), (11, 4), 5),
    ((1, 14), (11, 9), 7)
]
amrs2 = [
    AMRs(1, (1, 4), 0),
    AMRs(2, (1, 9), 0),
    AMRs(3, (1, 14), 0),
    AMRs(4, (1, 19), 0)
]


missionsLog2 = runMissions(missions2, amrs2, timeline2, true)
missionsLog1 = runMissions(missions1, amrs1, timeline1, true)
# Visualization of the result saved to "test_missions.png"

#Example 1:
saveMissionsMap("version1.map", missionsLog1, "test_mission1")

println("----------------")
#Example 2
saveMissionsMap("version1.map", missionsLog2, "test_missions2")
