--[[
A* algorithm for LUA
Ported to LUA by Altair
21 septembre 2006
courseplay edit by hummel 2011
--]]


function round(num, idp)
  return math.floor(num /idp) * idp
end

function CalcMoves(px, py, tx, ty)	-- Based on some code of LMelior but made it work and improved way beyond his code, still thx LMelior!
 if not courseplay:is_field(py, px) then
    return nil
  end

 local interval = 5
 local vertical_costs = 10
 local diagnoal_costs = 14
 
 px = round(px, interval)
 py = round(py, interval)
 tx = round(tx, interval)
 ty = round(ty, interval)

--[[ PRE:
mapmat is a 2d array
px is the player's current x
py is the player's current y
tx is the target x
ty is the target y

Note: all the x and y are the x and y to be used in the table.
By this I mean, if the table is 3 by 2, the x can be 1,2,3 and the y can be 1 or 2.
--]]

--[[ POST:
closedlist is a list with the checked nodes.
It will return nil if all the available nodes have been checked but the target hasn't been found.
--]]

	-- variables
	local openlist={}                 		-- Initialize table to store possible moves
	local closedlist={}						-- Initialize table to store checked gridsquares
	local listk=1                   				-- List counter
        local closedk=0                					-- Closedlist counter
	local tempH=math.abs(px-tx)+math.abs(py-ty)
	local tempG=0
	openlist[1]={x=px, y=py, g=0, h=tempH, f=0+tempH ,par=1}   	-- Make starting point in list
	local xsize=1024 				-- horizontal map size
	local ysize=1024					-- vertical map size
	local curbase={}						-- Current square from which to check possible moves
	local basis=1						-- Index of current base	
	local max_tries = 3000
	local max_distance_factor = 10
	local air_distance = tempH
	
	-- Growing loop
	while listk>0 do

	    -- Get the lowest f of the openlist
	    local lowestF=openlist[listk].f
	    basis=listk
		for k=listk,1,-1 do
  		    if openlist[k].f<lowestF then
  		       lowestF=openlist[k].f
               basis=k
	       	end
		end

		if closedk >= max_tries then
		  return nil		
		end

		closedk=closedk+1
		table.insert(closedlist,closedk,openlist[basis])
		
		curbase=closedlist[closedk]				 -- define current base from which to grow list
		
		--print(string.format("a star check x: %f y %f - closedk: %d", curbase.x, curbase.y, closedk ))
		
		local wOK=true
		local eOK=true           				 -- Booleans defining if they're OK to add
		local sOK=true             				 -- (must be reset for each while loop)
		local nOK=true

		local nwOK=true
		local seOK=true           				 
		local swOK=true             				 
		local noOK=true

		-- Look through closedlist
		if closedk>0 then
		    for k=1,closedk do
				if closedlist[k].x==curbase.x+interval and closedlist[k].y==curbase.y then
					wOK=false
				end
				if closedlist[k].x==curbase.x-interval and closedlist[k].y==curbase.y then
					eOK=false
				end
				if closedlist[k].x==curbase.x and closedlist[k].y==curbase.y+interval then
					sOK=false
				end
				if closedlist[k].x==curbase.x and closedlist[k].y==curbase.y-interval then
					nOK=false
				end
				
				if closedlist[k].x==curbase.x+interval and closedlist[k].y==curbase.y-interval then
					nwOK=false
				end
				
				if closedlist[k].x==curbase.x-interval and closedlist[k].y==curbase.y-interval then
					neOK=false
				end
				
				if closedlist[k].x==curbase.x+interval and closedlist[k].y==curbase.y+interval then
					swOK=false
				end
				
				if closedlist[k].x==curbase.x-interval and closedlist[k].y==curbase.y+interval then
					seOK=false
				end
		    end
		end

		-- Check if next points are on the map and within moving distance
		if curbase.x+interval>xsize then
			wOK=false
			nwOK=false
			swOK=false
		end
		if curbase.x-interval<-1024 then
			eOK=false
			neOK=false
			seOK=false
		end
		if curbase.y+interval>ysize then
			sOK=false
			swOK=false
			seOK=false
		end
		if curbase.y-interval<-1024 then
			nOK=false
			nwOK=false
			neOK=false
		end

		-- If it IS on the map, check map for obstacles
		--(Lua returns an error if you try to access a table position that doesn't exist, so you can't combine it with above)
		if wOK and curbase.x+interval<=xsize and courseplay:area_has_fruit(curbase.y, curbase.x+interval) then
			wOK=false
		end
		if eOK and curbase.x-interval>=-1024 and courseplay:area_has_fruit(curbase.y, curbase.x-interval) then
			eOK=false
		end
		if sOK and curbase.y+interval<=ysize and courseplay:area_has_fruit(curbase.y+interval, curbase.x) then
			sOK=false
		end
		if nOK and curbase.y-interval>=-1024 and courseplay:area_has_fruit(curbase.y-interval, curbase.x) then
			nOK=false
		end

		-- check if the move from the current base is shorter then from the former parrent
		tempG=curbase.g+interval
		for k=1,listk do
		    if wOK and openlist[k].x==curbase.x+interval and openlist[k].y==curbase.y then
		      if openlist[k].g>tempG  then
		      	  --print("right OK 1")
				  tempH=math.abs((curbase.x+interval)-tx)+math.abs(curbase.y-ty)
				  table.insert(openlist,k,{x=curbase.x+interval, y=curbase.y, g=tempG, h=tempH, f=tempG+tempH, par=closedk})				 
			  end
			  wOK=false
		    end

		    if eOK and openlist[k].x==curbase.x-interval and openlist[k].y==curbase.y then		      
		      if openlist[k].g>tempG  then
		        --print("left OK 1")
			    tempH=math.abs((curbase.x-interval)-tx)+math.abs(curbase.y-ty)
			    table.insert(openlist,k,{x=curbase.x-interval, y=curbase.y, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
			   
			  end
			  eOK=false
		    end

		    if sOK and openlist[k].x==curbase.x and openlist[k].y==curbase.y+interval then		      
		      if openlist[k].g>tempG  then
		        --print("down OK 1")
			    tempH=math.abs((curbase.x)-tx)+math.abs(curbase.y+interval-ty)
				
			    table.insert(openlist,k,{x=curbase.x, y=curbase.y+interval, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
			  
			  end
			  sOK=false
		    end

		    if nOK and openlist[k].x==curbase.x and openlist[k].y==curbase.y-interval then
		      if openlist[k].g>tempG then
		        --print("up OK 1")
			    tempH=math.abs((curbase.x)-tx)+math.abs(curbase.y-interval-ty)
			    table.insert(openlist,k,{x=curbase.x, y=curbase.y-interval, g=tempG, h=tempH, f=tempG+tempH, par=closedk})
			    
			  end
			  nOK=false
		    end
   		end

		-- Add points to openlist
		-- Add point to the right of current base point
		if wOK then
			--print("right OK")
			listk=listk+1
			tempH=math.abs((curbase.x+interval)-tx)+math.abs(curbase.y-ty)
			
			table.insert(openlist,listk,{x=curbase.x+interval, y=curbase.y, g=tempG, h=tempH, f=tempG+tempH, par=closedk})			
		end

		-- Add point to the left of current base point
		if eOK then
			--print("left OK")
			listk=listk+1
			tempH=math.abs((curbase.x-interval)-tx)+math.abs(curbase.y-ty)			
			table.insert(openlist,listk,{x=curbase.x-interval, y=curbase.y, g=tempG, h=tempH, f=tempG+tempH, par=closedk})			
		end

		-- Add point on the top of current base point
		if sOK then
			--print("down OK")
			listk=listk+1
			tempH=math.abs(curbase.x-tx)+math.abs((curbase.y+interval)-ty)
			
			table.insert(openlist,listk,{x=curbase.x, y=curbase.y+interval, g=tempG, h=tempH, f=tempG+tempH, par=closedk})			
		end

		-- Add point on the bottom of current base point
		if nOK then
			--print("up OK")
			listk=listk+1
			tempH=math.abs(curbase.x-tx)+math.abs((curbase.y-interval)-ty)
			
			table.insert(openlist,listk,{x=curbase.x, y=curbase.y-interval, g=tempG, h=tempH, f=tempG+tempH, par=closedk})			
		end

		table.remove(openlist,basis)
		listk=listk-1

        if closedlist[closedk].x==tx and closedlist[closedk].y==ty then
           return CalcPath(closedlist)
        end
	end

	return nil
end

function CalcPath(closedlist)
--[[ PRE:
closedlist is a list with the checked nodes.
OR nil if all the available nodes have been checked but the target hasn't been found.
--]]

--[[ POST:
path is a list with all the x and y coords of the nodes of the path to the target.
OR nil if closedlist==nil
--]]

    if closedlist==nil then
       return nil
    end
	 local path={}
	 local pathIndex={}
	 local last=table.getn(closedlist)
	 table.insert(pathIndex,1,last)

	 local i=1
	 while pathIndex[i]>1 do
		i=i+1
	 	table.insert(pathIndex,i,closedlist[pathIndex[i-1]].par)
	 end

	 for n=table.getn(pathIndex),1,-1 do
	     table.insert(path,{x=closedlist[pathIndex[n]].x, y=closedlist[pathIndex[n]].y})
  	 end

	 closedlist=nil
	 return path
end
