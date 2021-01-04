note
	description: "Summary description for {ENEMY_PROJ_HELPER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENEMY_PROJ_HELPER
inherit
	PARENT_PROJ_HELPER
		redefine
			make
		end

create make

feature --make
	make
		do
			Precursor
			create proj_list.make(0)
			create proj_info_message.make_empty
			create proj_action_message.make_empty
		end

feature --Attributes
	proj_list: ARRAYED_LIST[ENEMY_PROJ_ENTITY]
	proj_info_message, proj_action_message: STRING


feature -- proj list related commands		

	add_proj(proj: ENEMY_PROJ_ENTITY)
		do
			proj_list.extend (proj)
		end

	remove_proj(proj: ENEMY_PROJ_ENTITY)
		do
			proj_list.prune(proj)
		end

	append_proj_action_message(s: STRING)
		do
			proj_action_message:=proj_action_message + s
		end

	append_proj_info_message(s: STRING)
		do
			proj_info_message:=proj_info_message + s
		end

	reset_action_message
		do
			proj_action_message.make_empty
		end

	reset_proj_info_message
		do
			proj_info_message.make_empty
		end

	setup_proj_info_message
		local
			remove_proj_check: BOOLEAN
		do
			reset_proj_info_message
			remove_proj_check:=False

			from
				proj_list.start
			until
				proj_list.exhausted
			loop
					if model.within_bounds (proj_list.item.location.x, proj_list.item.location.y) and proj_list.item.removed = False then
						append_proj_info_message("    [" + proj_list.item.id.out + "," + proj_list.item.symbol.out
						+ "]->damage:" + proj_list.item.proj_damage.out + ", move:" + proj_list.item.proj_distance.out +
						", location:[" + proj_list.item.location.x.out + "," + proj_list.item.location.y.out + "]%N")
					else
						remove_proj_check:=True
					end
				proj_list.forth
			end

			if remove_proj_check then
				delete_out_of_board_proj
				remove_removed_proj
			end


		end

	delete_out_of_board_proj
			do
				from
					proj_list.start
				until
					proj_list.exhausted
				loop
					if (proj_list.item.location.y < 1) or (proj_list.item.location.x <'A') or (proj_list.item.location.x > model.max_row_letter) then
						proj_list.remove
					else
						proj_list.forth
					end
				end
			end

	remove_removed_proj
		do
			from
				proj_list.start
			until
				proj_list.exhausted
			loop
				if proj_list.item.removed then
					proj_list.remove
				else
					proj_list.forth
				end
			end
		end

	update_enemy_fire
		local
			temp_loc, init_pos, final_pos: TUPLE[x:CHARACTER; y:INTEGER]
			temp_index, l_c: INTEGER
			outside_board: BOOLEAN
			temp_message: STRING
		do
			reset_action_message
			create temp_message.make_empty
			from
				proj_list.start
			until
				proj_list.exhausted or model.star_entity.health <= 0
			loop
				temp_message.make_empty
				outside_board:= False
				if (proj_list.item.location.y >= 1) and (proj_list.item.location.y <= model.col) then
					temp_loc:= proj_list.item.location
					init_pos:= temp_loc.deep_twin

					if (init_pos.y >= 1) and (init_pos.y <=model.col) then
						temp_index:= model.get_location_index (temp_loc.x, temp_loc.y)
					end

					if model.board.at (temp_index) = '<' and model.within_bounds (temp_loc.x, temp_loc.y)then
						model.board.replace_substring ("_", temp_index, temp_index)
					end

					proj_list.item.set_proj_location ([proj_list.item.location.x, proj_list.item.location.y - proj_list.item.proj_distance])
					final_pos := proj_list.item.location

					from
						l_c:= init_pos.y
					until
						l_c = final_pos.y - 1 or proj_list.item.removed
					loop
						temp_message:= temp_message + check_collision(final_pos.x, l_c, proj_list.item)
						l_c:=l_c - 1
					end

					if proj_list.item.removed = False then
						if (final_pos.y >= 1) and (final_pos.y <=model.col) then
							temp_index:= model.get_location_index (proj_list.item.location.x, proj_list.item.location.y)
							if model.board.at (temp_index) = '_' and model.board.at (temp_index) /= '?' then
								model.board.replace_substring (proj_list.item.symbol.out, temp_index, temp_index)
							end
						else
							outside_board:=True
						end
					else
						final_pos:= proj_list.item.location
					end

					if init_pos/~ final_pos then
						if outside_board=False then
							append_proj_action_message ("    A enemy projectile(id:" + proj_list.item.id.out
							+ ") moves: [" + init_pos.x.out + "," + init_pos.y.out + "] -> [" + final_pos.x.out + "," + final_pos.y.out + "]%N")
							append_proj_action_message(temp_message)
						else
							append_proj_action_message ("    A enemy projectile(id:" + proj_list.item.id.out
							+ ") moves: [" + init_pos.x.out + "," + init_pos.y.out + "] -> out of board%N")
							append_proj_action_message(temp_message)
						end
					end
				end

				proj_list.forth
			end
			delete_out_of_board_proj
			remove_removed_proj
		end


	check_collision(row: CHARACTER; col: INTEGER; proj_entity: ENEMY_PROJ_ENTITY): STRING
    	local
    		temp_loc: TUPLE[x: CHARACTER; y: INTEGER]
    		stop_search: BOOLEAN
    		temp_index, l_c: INTEGER
    	do
    		create temp_loc
    		create Result.make_empty

    		temp_loc.x := row
    		temp_loc.y := col
    		stop_search := False

    		--Check if proj collided with starship
    		if model.star_entity.location.x = row  and model.star_entity.location.y = col then
				model.star_entity.subtract_health (proj_entity.proj_damage - model.star_entity.armour)
				Result:= Result +"      The projectile collides with Starfighter(id:" + model.star_entity.id.out + ") at location ["
				+ model.star_entity.location.x.out + "," + model.star_entity.location.y.out + "], dealing "
				+ (proj_entity.proj_damage -model.star_entity.armour).out + " damage.%N"

				temp_index:=model.get_location_index (proj_entity.location.x, proj_entity.location.y)
				proj_entity.set_proj_location (model.star_entity.location)
				stop_search:= True
				proj_entity.set_removed
				if model.star_entity.health <= 0 then
					model.star_entity.set_location (row, col)
					model.set_message (model.star_entity.set_normal_info_message (model.weapon, model.power, model.score))
					Result:=Result + "      The Starfighter at location [" + model.star_entity.location.x.out
					+ "," + model.star_entity.location.y.out +"] has been destroyed.%N"
					model.set_death
				end
    		end

--    		Search through all the friendly proj for location
			from
				model.proj_handler.proj_list.start
			until
				(model.proj_handler.proj_list.exhausted) or stop_search
			loop
				if model.proj_handler.proj_list.item.location ~ temp_loc then
					Result:= Result +"      The projectile collides with friendly projectile(id:" + model.proj_handler.proj_list.item.id.out
					 + ") at location [" + row.out + "," + col.out + "], negating damage.%N"


					temp_index:=model.get_location_index (model.proj_handler.proj_list.item.location.x, model.proj_handler.proj_list.item.location.y)
				--	model.board.replace_substring ("_", temp_index, temp_index)

					if proj_entity.proj_damage < model.proj_handler.proj_list.item.proj_damage then
					 	model.proj_handler.proj_list.item.subtract_proj_damage (proj_entity.proj_damage)
					 	proj_entity.set_proj_location ([row, col])
						model.board.replace_substring ("*", temp_index, temp_index)
						proj_entity.set_removed
					elseif proj_entity.proj_damage > model.proj_handler.proj_list.item.proj_damage then
						proj_entity.subtract_proj_damage (model.proj_handler.proj_list.item.proj_damage)
						model.board.replace_substring ("<", temp_index, temp_index)
						model.proj_handler.proj_list.remove
					else
						proj_entity.set_removed
						proj_entity.set_proj_location ([row, col])
						model.proj_handler.proj_list.remove
						model.board.replace_substring ("_", temp_index, temp_index)
					end

					stop_search:= True
				else
					model.proj_handler.proj_list.forth
				end
			end

			--Search through all the enemy proj for location
			from
				l_c:=1
			until
				(l_c = proj_list.count + 1) or stop_search
			loop
				if (proj_list.at(l_c).location ~ temp_loc) and proj_list.at (l_c).id /= proj_entity.id and proj_list.at (l_c).removed = False then
					Result:= Result +"      The projectile collides with enemy projectile(id:" + proj_list.at(l_c).id.out
					 + ") at location [" + row.out + "," + col.out + "], combining damage.%N"


					temp_index:=model.get_location_index (proj_list.at(l_c).location.x, model.enemy_proj_handler.proj_list.at(l_c).location.y)
					proj_entity.add_proj_damage(proj_list.at(l_c).proj_damage)
					proj_list.at(l_c).set_removed
--					model.board.replace_substring ("_", temp_index, temp_index)

					stop_search:= True
				else
					l_c:=l_c+1
				end
			end

--			--Search through all the enemies for location
			from
				model.enemy_handler.enemy_list.start
			until
				(model.enemy_handler.enemy_list.exhausted) or stop_search
			loop
				if model.enemy_handler.enemy_list.item.location.x = row and model.enemy_handler.enemy_list.item.location.y = col and model.enemy_handler.enemy_list.item.location.y >= 1 then
					Result:=Result + "      The projectile collides with " + model.enemy_handler.enemy_list.item.entity_type + "(id:" + model.enemy_handler.enemy_list.item.id.out
					 + ") at location [" + row.out + "," + col.out + "], healing " + proj_entity.proj_damage.out
					  + " damage.%N"
					temp_index:=model.get_location_index (proj_entity.location.x, proj_entity.location.y)
				--	model.board.replace_substring("_", temp_index, temp_index)
					model.enemy_handler.enemy_list.item.add_health (proj_entity.proj_damage)
					proj_entity.set_proj_location ([row, col])
					proj_entity.set_removed
					stop_search:= True
				else
					if model.enemy_handler.enemy_list.item.location.y < 1 then
						stop_search:=True
					else
						model.enemy_handler.enemy_list.forth
					end
				end
			end
		end


end
