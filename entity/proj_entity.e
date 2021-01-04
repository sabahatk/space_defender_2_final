note
	description: "Summary description for {PROJ_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PROJ_ENTITY


feature -- make
	model: GAME

	make
		local
			ga:GAME_ACCESS
		do
			create proj_direction.make_empty
			create location
			model:=ga.m
			proj_distance:=0
			proj_damage:=0
			removed:= False
		end

feature -- Attributes

	symbol: CHARACTER
	id_counter: INTEGER
	id: INTEGER
	proj_distance: INTEGER
	proj_damage: INTEGER
	proj_cost: INTEGER
	proj_direction: STRING
	location: TUPLE[x: CHARACTER; y: INTEGER]
	removed: BOOLEAN

feature -- set commands

	next_id
		do
			id_counter:=id_counter-1
		end

	set_proj_distance(distance: INTEGER) deferred end

	set_proj_damage(damage: INTEGER) deferred end

	add_proj_damage(damage: INTEGER) deferred end

	subtract_proj_damage(damage: INTEGER) deferred end

	set_removed
		do
			removed:=True
		end

	unset_removed
		do
			removed:=False
		end

	set_proj_location(loc: TUPLE[row:CHARACTER;col:INTEGER])
		do
			location := loc
		end


end
