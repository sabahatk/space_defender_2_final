note
	description: "Summary description for {ENEMY_PROJ_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENEMY_PROJ_ENTITY
inherit
	PROJ_ENTITY
		redefine
			make
		end

create make

feature --make
	make
		do
			Precursor
			create proj_direction.make_empty
			proj_direction := "L"
			symbol:= '<'
			model.next_proj_id
			id:= model.proj_id_counter
		end

	set_proj_distance(distance: INTEGER)
		do
			proj_distance:= distance
		end

	set_proj_damage(damage: INTEGER)
		do
			proj_damage := damage
		end

	add_proj_damage(damage: INTEGER)
		do
			proj_damage:= proj_damage + damage
		end

	subtract_proj_damage(damage: INTEGER)
		do
			proj_damage:= proj_damage - damage
		end


end
