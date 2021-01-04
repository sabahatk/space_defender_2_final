note
	description: "Summary description for {INTERCEPTOR_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	INTERCEPTOR_ENTITY
	inherit
		ENEMY_ENTITY
			redefine
				make
			end
create make

feature --make
	make
		do
			Precursor
			symbol:= 'I'
			entity_type:= "Interceptor"
			health:= 50
			health_total := 50
			regen:=0
			armour:=0
			vision:=5
			delay_turn:=0
			spawned_by_carrier:=False
			seen_by_starfighter:= False
			can_see_starfighter:= False
		end

feature --Attributes
	spawned_by_carrier: BOOLEAN
	delay_turn: INTEGER

feature -- commands

	play_preempt(turn: CHARACTER)
		local
			init_pos: TUPLE[x: CHARACTER; y: INTEGER]
		do


			if spawned_by_carrier = False then
				reset_spawn_message
				create init_pos
				if turn = 'F' then
					add_health(regen)
					init_pos:= location.deep_twin
					location.x := model.star_entity.location.x
					if Current.health > 0 and location.y >= 1 then
						if init_pos /~ location then
							move_vertical(init_pos)
						else
							model.enemy_handler.append_action_message("    A " + entity_type + "(id:" + id.out + ") stays at: [" + location.x.out +"," + location.y.out + "]%N")
						end
					end
					end_turn:=True
				else
					end_turn:=False
				end
			end
		end

	move_vertical(initial: TUPLE[x: CHARACTER; y: INTEGER])
		local
			temp_index: INTEGER
			temp_message: STRING
			row: CHARACTER
		do
			create temp_message.make_empty
			Current.set_stop_check (False)
			--if interceptor is above desired location
			if initial.x < location.x then
				from
					row:= initial.x
				until
					(row = location.x  + 1) or Current.stop_check
				loop
					temp_message:= check_collision(row, location.y, Current, "VA")
					row:= row + 1
				end
			-- if interceptor is below desired location
			elseif initial.x > location.x then
				from
					row:= initial.x
				until
					(row = location.x  - 1) or Current.stop_check
				loop
					temp_message:= check_collision(row, location.y, Current, "VB")
					row:= row - 1
				end
			end

			if initial /~ location then
				temp_index:= model.get_location_index (initial.x, initial.y)
				model.board.replace_substring ("_", temp_index, temp_index)
				temp_index:= model.get_location_index (location.x, location.y)
				model.board.replace_substring(symbol.out, temp_index, temp_index)
			end

			if initial ~ location then
				model.enemy_handler.append_action_message("    A " + entity_type + "(id:" + id.out + ") stays at: ["
				+ Current.location.x.out +"," + Current.location.y.out + "]%N")
			else
				model.enemy_handler.append_action_message("    A " + entity_type + "(id:" + id.out + ") moves: ["
			+ initial.x.out + "," + initial.y.out + "] -> [" + Current.location.x.out +"," + Current.location.y.out + "]%N")
			end

		end

	play_action
		do
			if spawned_by_carrier = False then
				reset_spawn_message
				if end_turn = False and location.y >= 1 and Current.health > 0 then
					add_health(regen)
					if can_see_starfighter then
						move_enemy(3)
					else
						move_enemy(3)
					end
				end
			end
			set_spawned_by_carrier(False)
		end

	drop_score
		do
			model.score_keeper.add (create {ORBMENT}.make ('B'))
		end

	align_rows
		local
			row_traverse: CHARACTER
			stop_search: BOOLEAN
		do

			if location.x > model.star_entity.location.x then

				from
					row_traverse:=location.x
				until
					(row_traverse = model.star_entity.location.x - 1) or stop_search
				loop
					stop_search:=check_entity([row_traverse, location.y])
					row_traverse:=row_traverse - 1
				end
			elseif location.x > model.star_entity.location.x then
				from
					row_traverse:=location.x
				until
					(row_traverse = model.star_entity.location.x + 1) or stop_search
				loop
					stop_search:=check_entity([row_traverse, location.y])
					row_traverse:=row_traverse + 1
				end
			end
		end

	check_entity(loc: TUPLE[row: CHARACTER; col: INTEGER]): BOOLEAN
		local
			stop_search: BOOLEAN
		do
			Result:=False
			stop_search := False
			from
				model.enemy_handler.enemy_list.start
			until
				(model.enemy_handler.enemy_list.exhausted) or stop_search
			loop
				if model.enemy_handler.enemy_list.item.location ~ loc then
					stop_search:=True
					Result:=True
					if model.star_entity.location.x > location.x then
						set_location([model.enemy_handler.enemy_list.item.location.x - 1, loc.col])
					elseif model.star_entity.location.x < location.x then
						set_location([model.enemy_handler.enemy_list.item.location.x + 1, loc.col])
					end

				end
				model.enemy_handler.enemy_list.forth
			end
		end

	set_spawned_by_carrier(b: BOOLEAN)
		do
			spawned_by_carrier:= b
		end
end
