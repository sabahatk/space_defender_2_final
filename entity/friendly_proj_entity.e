note
	description: "Summary description for {FRIENDLY_PROJ_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FRIENDLY_PROJ_ENTITY
inherit
	PROJ_ENTITY
		redefine
			make
		end

create make, make_type

feature --make

	make
		do
			Precursor
			create proj_direction.make_empty
			symbol := '*'
		end

	make_type(distance: INTEGER; cost: INTEGER; direction: STRING; damage: INTEGER)
		do
			make
			model.next_proj_id
			id:= model.proj_id_counter
			proj_distance:= distance
			proj_cost:= cost
			proj_direction:= direction
			proj_damage:= damage
		end



feature -- set commands
	set_proj_distance(distance: INTEGER)
		do
			proj_distance := distance
		end

	set_proj_damage(damage: INTEGER)
		do
			proj_damage := damage
		end

	add_proj_damage(damage: INTEGER)
		do
			proj_damage:=proj_damage + damage
		end

	subtract_proj_damage(damage: INTEGER)
		do
			proj_damage:=proj_damage - damage
		end





end
