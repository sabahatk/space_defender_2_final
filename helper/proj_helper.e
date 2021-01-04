note
	description: "Summary description for {PROJ_HELPER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PROJ_HELPER
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
	proj_list: ARRAYED_LIST[PROJ_ENTITY]
	proj_info_message, proj_action_message: STRING



feature -- proj list related commands
	add_proj(proj: PROJ_ENTITY)
		do
			proj_list.extend (proj)
		end

	remove_proj(proj: PROJ_ENTITY)
		do
			proj_list.prune(proj)
		end

	append_action_message(s: STRING)
		do
			proj_action_message:=proj_action_message + s
		end

	reset_action_message
		do
			proj_action_message.make_empty
		end

	setup_info_message
		local
			remove_proj_check: BOOLEAN
		do
			set_proj_info_message("")
			remove_proj_check:=False
			from
				proj_list.start
			until
				proj_list.exhausted
			loop
				if proj_list.item.symbol = '*' then
					if (proj_list.item.location.y <= model.col) and (proj_list.item.location.x >= 'A' and proj_list.item.location.x <= proj_list.item.model.max_row_letter) and proj_list.item.removed = False then
						append_proj_info_message("    [" + proj_list.item.id.out + "," + proj_list.item.symbol.out
						+ "]->damage:" + proj_list.item.proj_damage.out + ", move:" + proj_list.item.proj_distance.out +
						", location:[" + proj_list.item.location.x.out + "," + proj_list.item.location.y.out + "]%N")
					else
						remove_proj_check:=True
					end
				end
				proj_list.forth
			end
			if remove_proj_check then
				delete_out_of_board_proj
			end
		end

		setup_fire(x: CHARACTER; y:INTEGER; remove_check: BOOLEAN) : BOOLEAN
			local
				w_index: INTEGER
			do
				Result:=False
				if  model.within_bounds (x, y) then
					w_index:= model.get_location_index (x, y)
					if model.board.at (w_index) = '_' and remove_check = False then
						model.board.replace_substring ("*", w_index, w_index)
					end
				else
					Result:=True
				end
			end

		setup_proj_spawn(dist:INTEGER; cost:INTEGER; dir: STRING; damage: INTEGER; x: CHARACTER; y: INTEGER): STRING
			local
				temp_proj: FRIENDLY_PROJ_ENTITY
			do
				create Result.make_empty
				if model.star_entity.health > 0 then
					create temp_proj.make_type (dist, cost, dir, damage)
					temp_proj.set_proj_location ([x, y])
					add_proj (temp_proj)
					Result:=check_collision(temp_proj.location.x, temp_proj.location.y,proj_list.at (model.proj_handler.proj_list.count))
					model.set_message (model.star_entity.set_normal_info_message (model.weapon, model.power, model.score))
					if proj_list.at (proj_list.count).removed then
						erase_removed_proj
					end
				end
			end

		delete_out_of_board_proj
			do
				from
					proj_list.start
				until
					proj_list.exhausted
				loop
					if (proj_list.item.location.y < 1) or (proj_list.item.location.y > model.col) or (proj_list.item.location.x <'A') or (proj_list.item.location.x > model.max_row_letter) then
						proj_list.remove
					else
						proj_list.forth
					end
				end
			end

	set_proj_info_message(info: STRING)
		do
			proj_info_message := info
		end

	append_proj_info_message(info: STRING)
		do
			proj_info_message:= proj_info_message + info
		end

	set_spawn_action_message(num_proj: INTEGER)
		local
			l_c: INTEGER
		do
			from
				l_c:=num_proj
			until
				l_c = -1
			loop
				if  (proj_list[proj_list.count - l_c].location.y >= 1)
				and (proj_list[proj_list.count - l_c].location.y <= model.col)
				and (proj_list[proj_list.count - l_c].location.x >= 'A')
				and (proj_list[proj_list.count - l_c].location.x <= model.max_row_letter) then
					model.star_entity.append_action_message ("      A friendly projectile(id:"
					+ proj_list[proj_list.count - l_c].id.out + ") spawns at location ["
					+ proj_list[proj_list.count - l_c].location.x.out + "," + proj_list[proj_list.count - l_c].location.y.out
					+ "].%N")
				else
					model.star_entity.append_action_message ("      A friendly projectile(id:"
					+ proj_list[proj_list.count - l_c].id.out + ") spawns at location out of board.%N")
				end
				l_c:= l_c - 1
			end
		end

	erase_removed_proj
		local
			temp_index: INTEGER
		do
			from
				proj_list.start
			until
				proj_list.exhausted
			loop
				temp_index:= model.get_location_index (proj_list.item.location.x, proj_list.item.location.y)
				if proj_list.item.removed and model.board.at (temp_index) = '*' then
					model.board.replace_substring("_", temp_index, temp_index)
				end
				proj_list.forth
			end
		end

	remove_removed_proj
		do
			--erase_removed_proj
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



	reset_removed
		do
			from
				proj_list.start
			until
				proj_list.exhausted
			loop
				proj_list.item.unset_removed
				proj_list.forth
			end
		end


	update_fire
			local
				l_c, temp_index: INTEGER
				temp_message: STRING
				temp_loc, init_pos, end_pos: TUPLE[x: CHARACTER; y: INTEGER]
				outside_board:BOOLEAN

			do
				create temp_loc
				create init_pos
				create end_pos

				reset_action_message
				reset_removed
				from
					proj_list.start
				until
					proj_list.exhausted or model.star_entity.health <= 0
				loop
						outside_board:=False
						temp_loc.x := proj_list.item.location.x
						temp_loc.y := proj_list.item.location.y
						create temp_message.make_empty
						init_pos := temp_loc.deep_twin

						if (temp_loc.y <= model.col) and (temp_loc.x >= 'A') and (temp_loc.x <= model.max_row_letter) then
							temp_index:= model.get_location_index (temp_loc.x, temp_loc.y)
						end


						if model.within_bounds(temp_loc.x, temp_loc.y) then
							if model.board.at (temp_index) = '*' then
								model.board.replace_substring ("_", temp_index, temp_index)
							end
						end

						if proj_list.item.proj_direction ~ "R" then
							-- check for collision
							if model.weapon ~ "Rocket" or model.weapon ~ "Standard" or model.weapon ~ "Spread" then
								from
									l_c:=temp_loc.y
								until
									(l_c = temp_loc.y + proj_list.item.proj_distance + 1) or proj_list.item.removed
								loop

									temp_message:= temp_message + check_collision(temp_loc.x, l_c, proj_list.item)
									l_c:=l_c + 1
								end
							elseif model.weapon ~ "Snipe" then
								temp_message:= temp_message + check_collision(temp_loc.x, temp_loc.y + proj_list.item.proj_distance, proj_list.item)
							end

							if proj_list.item.removed = False then
								temp_loc.y:=temp_loc.y + proj_list.item.proj_distance
								end_pos:= temp_loc.deep_twin
								proj_list.item.set_proj_location ([temp_loc.x, temp_loc.y])

								if temp_loc.y <= model.col then
									temp_index:= model.get_location_index (temp_loc.x, temp_loc.y)
								else
									outside_board:=True
								end

								if model.weapon ~ "Rocket" then
									proj_list.item.set_proj_distance (proj_list.item.proj_distance*2)
								end
							else
								end_pos:=proj_list.item.location
							end


						elseif proj_list.item.proj_direction ~ "UR" then
							temp_loc.x := temp_loc.x - 1
							temp_loc.y:=temp_loc.y + proj_list.item.proj_distance
							end_pos:= temp_loc
							proj_list.item.set_proj_location ([temp_loc.x, temp_loc.y])
							temp_message:= temp_message + check_collision(end_pos.x, end_pos.y, proj_list.item)
							end_pos:=proj_list.item.location

							if model.within_bounds (temp_loc.x, temp_loc.y) then
								temp_index:= model.get_location_index (temp_loc.x, temp_loc.y)
							else
								outside_board:= True
							end

						elseif proj_list.item.proj_direction ~ "DR" then
							temp_loc.x := temp_loc.x + 1
							temp_loc.y:=temp_loc.y + proj_list.item.proj_distance
							end_pos:= temp_loc
							proj_list.item.set_proj_location ([temp_loc.x, temp_loc.y])
							temp_message:= temp_message + check_collision(end_pos.x, end_pos.y, proj_list.item)
							end_pos:=proj_list.item.location

							if model.within_bounds (temp_loc.x, temp_loc.y) then
								temp_index:= model.get_location_index (temp_loc.x, temp_loc.y)
							else
								outside_board := True
							end

						end

						if model.within_bounds (temp_loc.x, temp_loc.y) and outside_board = False then

							if model.board.at (temp_index) = '_' and proj_list.item.removed = False then
								model.board.replace_substring ("*", temp_index, temp_index)
							end
							if model.weapon ~ "Splitter" then
								append_action_message ("    A friendly projectile(id:" + proj_list.item.id.out
								+ ") stays at: [" + init_pos.x.out + "," + init_pos.y.out + "]%N")
								--append_action_message(temp_message)
							else
								if init_pos /~ end_pos then
									append_action_message ("    A friendly projectile(id:" + proj_list.item.id.out
								+ ") moves: [" + init_pos.x.out + "," + init_pos.y.out + "] -> [" + end_pos.x.out + "," + end_pos.y.out + "]%N")
								end
								--append_action_message(temp_message)
							end
						else
							append_action_message ("    A friendly projectile(id:" + proj_list.item.id.out
							+ ") moves: [" + init_pos.x.out + "," + init_pos.y.out + "] -> out of board%N")
						end
						append_action_message(temp_message)
					if proj_list.item.removed then
						proj_list.remove
					else
						proj_list.forth
					end
				end
				delete_out_of_board_proj
				remove_removed_proj
			end




	check_collision(row: CHARACTER; col: INTEGER; proj_entity: PROJ_ENTITY): STRING
    	local
    		temp_loc: TUPLE[x: CHARACTER; y: INTEGER]
    		stop_search: BOOLEAN
    		temp_index, l_c, damage_taken: INTEGER
    		temp_board:STRING
    	do
    		create temp_loc
    		create temp_board.make_empty
    		temp_board:=model.board.deep_twin
    		create Result.make_empty

    		temp_loc.x := row
    		temp_loc.y := col
    		stop_search := False

    		--Check if proj collided with starship
    		if model.star_entity.location.x = row  and model.star_entity.location.y = col then
 				temp_index:=model.get_location_index (row, col-1)
				temp_board.replace_substring ("_", temp_index, temp_index)
				if proj_entity.proj_damage - model.star_entity.armour > 0 then
					model.star_entity.subtract_health (proj_entity.proj_damage - model.star_entity.armour)
					damage_taken:= proj_entity.proj_damage - model.star_entity.armour
				else
					damage_taken:=0
				end

				Result:= Result +"      The projectile collides with Starfighter(id:" + model.star_entity.id.out + ") at location ["
				+ model.star_entity.location.x.out + "," + model.star_entity.location.y.out + "], dealing "
				+ damage_taken.out + " damage.%N"
				proj_entity.set_proj_location (model.star_entity.location)
				stop_search:= True
				proj_entity.set_removed

				if model.star_entity.health <= 0 then
--					temp_index:=model.get_location_index (row, col-1)
--					model.board.replace_substring ("_", temp_index, temp_index)
					model.star_entity.set_location (row, col)
					model.set_message (model.star_entity.set_normal_info_message (model.weapon, model.power, model.score))
					Result:=Result + "      The Starfighter at location [" + model.star_entity.location.x.out
				+ "," + model.star_entity.location.y.out +"] has been destroyed.%N"
					model.set_death
				end

    		end

--    		Search through all the friendly proj for location
			from
				l_c:= 1
			until
				(l_c = proj_list.count + 1) or stop_search
			loop
				if (proj_list.at(l_c).location ~ temp_loc) and (proj_list.at(l_c).id /= proj_entity.id) and proj_list.at (l_c).removed = False then
					Result:= Result +"      The projectile collides with friendly projectile(id:" + model.proj_handler.proj_list.at(l_c).id.out
				 	+ ") at location [" + row.out + "," + col.out + "], combining damage.%N"
					proj_entity.add_proj_damage(proj_list.at(l_c).proj_damage)
					proj_list.at (l_c).set_removed
					stop_search:= True
				else
					l_c:=l_c + 1
				end
			end

			--Search through all the enemy proj for location
			from
				model.enemy_proj_handler.proj_list.start
			until
				(model.enemy_proj_handler.proj_list.exhausted) or stop_search
			loop
				if model.enemy_proj_handler.proj_list.item.location ~ temp_loc and model.enemy_proj_handler.proj_list.item.removed = False then
					Result:= Result +"      The projectile collides with enemy projectile(id:" + model.enemy_proj_handler.proj_list.item.id.out
					 + ") at location [" + row.out + "," + col.out + "], negating damage.%N"


					temp_index:=model.get_location_index (model.enemy_proj_handler.proj_list.item.location.x, model.enemy_proj_handler.proj_list.item.location.y)
					model.board.replace_substring ("_", temp_index, temp_index)

					if proj_entity.proj_damage < model.enemy_proj_handler.proj_list.item.proj_damage then
					 	model.enemy_proj_handler.proj_list.item.subtract_proj_damage (proj_entity.proj_damage)
					 	--model.board.replace_substring ("<", temp_index, temp_index)
					 	proj_entity.set_removed
					 	proj_entity.set_proj_location ([row, col])
					elseif proj_entity.proj_damage > model.enemy_proj_handler.proj_list.item.proj_damage then
						proj_entity.subtract_proj_damage (model.enemy_proj_handler.proj_list.item.proj_damage)
						--model.board.replace_substring ("*", temp_index, temp_index)
						model.enemy_proj_handler.proj_list.remove
					else
						proj_entity.set_removed
						proj_entity.set_proj_location ([row, col])
						temp_index:=model.get_location_index (row, col)
						model.board.replace_substring ("_", temp_index, temp_index)
						model.enemy_proj_handler.proj_list.remove
					end

					stop_search:= True
				else
					model.enemy_proj_handler.proj_list.forth
				end
			end

			--Search through all the enemies for location
			from
				model.enemy_handler.enemy_list.start
			until
				(model.enemy_handler.enemy_list.exhausted) or stop_search
			loop
				if model.enemy_handler.enemy_list.item.location ~ temp_loc then

					if proj_entity.proj_damage - model.enemy_handler.enemy_list.item.armour > 0 then
						model.enemy_handler.enemy_list.item.sub_health (proj_entity.proj_damage - model.enemy_handler.enemy_list.item.armour)
						damage_taken:=proj_entity.proj_damage - model.enemy_handler.enemy_list.item.armour
					else
						damage_taken:=0
					end


					Result:=Result + "      The projectile collides with " + model.enemy_handler.enemy_list.item.entity_type + "(id:" + model.enemy_handler.enemy_list.item.id.out
					 + ") at location [" + row.out + "," + col.out + "], dealing " + damage_taken.out
					  + " damage.%N"
					temp_index:=model.get_location_index (proj_entity.location.x, proj_entity.location.y)
					model.board.replace_substring("_", temp_index, temp_index)

					proj_entity.set_proj_location ([row, col])
					proj_entity.set_removed
					stop_search:= True

					if model.enemy_handler.enemy_list.item.health <= 0 then
						temp_index:=model.get_location_index (model.enemy_handler.enemy_list.item.location.x, model.enemy_handler.enemy_list.item.location.y)
						model.board.replace_substring("_", temp_index, temp_index)
						Result:=Result + "      The " + model.enemy_handler.enemy_list.item.entity_type + " at location ["+ model.enemy_handler.enemy_list.item.location.x.out
						+ "," + model.enemy_handler.enemy_list.item.location.y.out + "] has been destroyed.%N"
						model.enemy_handler.enemy_list.item.drop_score
						model.set_score (model.score_keeper.value)
						model.enemy_handler.enemy_list.remove
					end
				else
					model.enemy_handler.enemy_list.forth
				end
			end
		end

end
