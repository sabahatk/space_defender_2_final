note
	description: "Summary description for {ENEMY_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENEMY_ENTITY

feature -- make

	--Initialize all attributes
	make
		local
			ga: GAME_ACCESS
		do
			model := ga.m
			model.next_enemy_id
			id:= model.enemy_id_counter
			create spawn_message.make_empty
			create entity_type.make_empty
			end_turn:= False
			stop_check:=False
			create location
		end

feature -- Attributes
	model: GAME
	symbol: CHARACTER
	health: INTEGER
	health_total: INTEGER
	regen: INTEGER
	armour: INTEGER
	vision: INTEGER
	id: INTEGER
	seen_by_starfighter: BOOLEAN
	can_see_starfighter: BOOLEAN
	end_turn, stop_check: BOOLEAN
	spawn_message, entity_type: STRING
	location: TUPLE[x: CHARACTER; y: INTEGER]

feature -- Setting attributes commands

	-- subtract the health of the enemy
	sub_health(h: INTEGER)
		do
			if health-h <= 0 then
				health:= 0
			else
				health:= health-h
			end
		ensure
			health >= 0
		end

	--add health of enemy
	add_health(h: INTEGER)
		require
			health > 0
		do
			if health + h >= health_total then
				health:= health_total
			else
				health := health + h
			end
		ensure
			health <= health_total
		end

	--set location of enemy
	set_location(loc: TUPLE[x:CHARACTER; y:INTEGER])
		do
			location := loc
		end

	--set whether in starfighter's vision range
	set_seen_by_starfighter
		local
			h_dist, v_dist: INTEGER
		do
			v_dist:=(location.x.code - model.star_entity.location.x.code).abs
			h_dist:=(location.y - model.star_entity.location.y).abs

			if (h_dist + v_dist) <= model.star_entity.vision then
				seen_by_starfighter := True
			else
				seen_by_starfighter:=False
			end
		ensure
			(((location.y - model.star_entity.location.y).abs + (location.x.code - model.star_entity.location.x.code).abs) <= model.star_entity.vision) implies seen_by_starfighter
		end

	-- set wheather the enemy can see starfighter
	set_can_see_fighter
		local
			h_dist, v_dist: INTEGER
		do
			v_dist:= (location.x.code - model.star_entity.location.x.code).abs
			h_dist:=(location.y - model.star_entity.location.y).abs

			if (h_dist + v_dist) <= vision then
				can_see_starfighter := True
			else
				can_see_starfighter:=False
			end
		ensure
			(((location.x.code - model.star_entity.location.x.code).abs + (location.y - model.star_entity.location.y).abs) <= vision) implies can_see_starfighter
		end

	--set spawn message
	set_spawn_message
		do
			spawn_message:= "    A " + entity_type + "(id:" + id.out + ") spawns at location [" + location.x.out + "," + location.y.out + "].%N"
		end

	--reset spawn message
	reset_spawn_message
		do
			spawn_message.make_empty
		end

	-- set whether to stop looking for collisions or not
	set_stop_check(b: BOOLEAN)
		do
			stop_check:= b
		end

feature -- Action commands

	--spawns enemy given the row
	spawn(s_row: CHARACTER): BOOLEAN
		require
			s_row >= 'A' and s_row <= model.max_row_letter
		local
			spawn_index: INTEGER
		do
			Result:=True
			reset_spawn_message
			spawn_index := model.get_location_index (s_row, model.col)
			set_location ([s_row, model.col])
			if model.enemy_handler.is_enemy_in_location (s_row, model.col) = False then
				if model.game_mode ~ "debug" then
					model.board.replace_substring (symbol.out, spawn_index, spawn_index)
				else
					if model.board.at (spawn_index) = '_' then
						model.board.replace_substring (symbol.out, spawn_index, spawn_index)
					end
				end
				set_can_see_fighter
				set_seen_by_starfighter
				set_spawn_message
			else
				Result:=False
			end
		end

	-- The enemy will drop an orbment or focus
	drop_score deferred ensure health = 0 end

	--play the preemptive action of enemy
	play_preempt(turn: CHARACTER) deferred end

	--play the non-preemptive action of the enemy
	play_action deferred end

	-- move enemy
	move_enemy(distance: INTEGER)
		require
			Current.health > 0
		local
			loc_index, l_c: INTEGER
			init_pos, final_pos: TUPLE[x: CHARACTER; y:INTEGER]
			outside_board, stop_search: BOOLEAN
			collision_result: TUPLE[s: STRING; b: BOOLEAN]
			temp_message: STRING
		do
			outside_board:= False
			stop_search:=False
			Current.set_stop_check (False)
			create temp_message.make_empty
			create collision_result

			init_pos:= location.deep_twin

			if model.within_bounds(location.x, location.y) then
				loc_index := model.get_location_index (init_pos.x, init_pos.y)
				if (model.board.at (loc_index) = symbol) then
					model.board.replace_substring ("_", loc_index, loc_index)
				end
			end

			Current.set_location([location.x, location.y - distance])

			final_pos:=location.deep_twin
			from
				l_c:=init_pos.y
			until
				(l_c= final_pos.y - 1) or Current.stop_check
			loop

				temp_message:= temp_message + check_collision(final_pos.x, l_c, Current, "H")

				l_c:=l_c - 1
			end

			if model.within_bounds (location.x, location.y) and Current.health > 0 then
				loc_index:= model.get_location_index (location.x, location.y)
				if model.game_mode ~ "debug" then
					model.board.replace_substring(symbol.out, loc_index, loc_index)
				else
					if model.board.at (loc_index) = '_' then
						model.board.replace_substring(symbol.out, loc_index, loc_index)
					end
				end
			else
				outside_board:=True
			end

			final_pos:= location.deep_twin
			if final_pos ~ init_pos then
				model.enemy_handler.append_action_message ("    A " + entity_type +"(id:" + id.out +") stays at: ["
				+ init_pos.x.out + "," + init_pos.y.out + "]%N")
				model.enemy_handler.append_action_message(temp_message)
			elseif outside_board= False or health = 0 then
				model.enemy_handler.append_action_message ("    A " + entity_type +"(id:" + id.out +") moves: ["
				+ init_pos.x.out + "," + init_pos.y.out + "] -> [" + final_pos.x.out + "," + final_pos.y.out + "]%N")
				model.enemy_handler.append_action_message(temp_message)
			else
				--model.enemy_handler.set_enemy_info_message ("")
				model.enemy_handler.append_action_message ("    A " + entity_type + "(id:" + id.out +") moves: ["
				+ init_pos.x.out + "," + init_pos.y.out + "] -> out of board%N")
			end

			model.set_message (model.star_entity.set_normal_info_message (model.weapon, model.power, model.score))
			model.enemy_proj_handler.setup_proj_info_message

--			if outside_board = True then
--				model.enemy_handler.remove_all_outside_enemies(model.max_row_letter, model.col)
--			end

		end

	-- fire projectile
	enemy_fire(damage: INTEGER; distance: INTEGER)
		require
			Current.health > 0
		local
			loc_index: INTEGER
			temp_proj:ENEMY_PROJ_ENTITY
			temp_message: STRING
		do
			if location.y - 1 >= 1 then
				loc_index:= model.get_location_index (location.x, location.y - 1)
			end
				if model.star_entity.health > 0 and Current.health > 0 then
					create temp_message.make_empty
					create temp_proj.make
					temp_proj.set_proj_location ([location.x, location.y - 1])
					temp_proj.set_proj_damage (damage)
					temp_proj.set_proj_distance (distance)
					model.enemy_proj_handler.add_proj (temp_proj)


					temp_message:= temp_message + model.enemy_proj_handler.check_collision (location.x, location.y-1, model.enemy_proj_handler.proj_list[model.enemy_proj_handler.proj_list.count])

					if location.y - 1 >= 1 and model.enemy_proj_handler.proj_list[model.enemy_proj_handler.proj_list.count].removed = False and model.within_bounds (model.enemy_proj_handler.proj_list[model.enemy_proj_handler.proj_list.count].location.x, model.enemy_proj_handler.proj_list[model.enemy_proj_handler.proj_list.count].location.y)then
						if model.game_mode ~ "debug" then
							model.board.replace_substring(temp_proj.symbol.out, loc_index, loc_index)
						elseif model.board.at (loc_index) = '_' and model.board.at (loc_index) /= '?' then
							model.board.replace_substring(temp_proj.symbol.out, loc_index, loc_index)
						end
					end

					if Current.location.y >= 1 then
						if model.within_bounds (model.enemy_proj_handler.proj_list[model.enemy_proj_handler.proj_list.count].location.x, model.enemy_proj_handler.proj_list[model.enemy_proj_handler.proj_list.count].location.y) then
							model.enemy_handler.append_action_message ("      A enemy projectile(id:"+ model.enemy_proj_handler.proj_list[model.enemy_proj_handler.proj_list.count].id.out
							+ ") spawns at location [" + model.enemy_proj_handler.proj_list[model.enemy_proj_handler.proj_list.count].location.x.out + ","
							+ model.enemy_proj_handler.proj_list[model.enemy_proj_handler.proj_list.count].location.y.out+"].%N")
							model.enemy_handler.append_action_message(temp_message)
						else
							model.enemy_handler.append_action_message ("      A enemy projectile(id:"+ model.enemy_proj_handler.proj_list[model.enemy_proj_handler.proj_list.count].id.out
							+ ") spawns at location out of board.%N")
							model.enemy_handler.append_action_message(temp_message)
						end
					end
				end


				model.set_message (model.star_entity.set_normal_info_message (model.weapon, model.power, model.score))
				model.enemy_proj_handler.setup_proj_info_message
		end

	-- check for collisions
	check_collision(row: CHARACTER; col: INTEGER; enemy: ENEMY_ENTITY; movement: STRING): STRING
    	local
    		temp_loc: TUPLE[x: CHARACTER; y: INTEGER]
    		stop_search: BOOLEAN
    		temp_index, l_c, damage_taken: INTEGER
    	do
    		create temp_loc
    		create Result.make_empty

    		temp_loc.x := row
    		temp_loc.y := col
    		stop_search := False

    		--Check if enemy collided with starship
    		if model.star_entity.location.x = row  and model.star_entity.location.y = col then
				model.star_entity.subtract_health (enemy.health)
				Result:= Result +"      The " + entity_type + " collides with Starfighter(id:" + model.star_entity.id.out + ") at location ["
				+ model.star_entity.location.x.out + "," + model.star_entity.location.y.out + "], trading "
				+ (enemy.health).out + " damage.%N"

				enemy.sub_health(health)
				temp_index:=model.get_location_index (enemy.location.x, enemy.location.y)
				model.board.replace_substring ("_", temp_index, temp_index)
				stop_search:= True
				enemy.set_location ([row,col])
				if enemy.health <=0 then
					Result:=Result + "      The " + enemy.entity_type + " at location ["+ enemy.location.x.out
					+ "," + enemy.location.y.out + "] has been destroyed.%N"
					enemy.drop_score
					model.set_score (model.score_keeper.value)
				end


				if model.star_entity.health <= 0 then
					model.star_entity.set_location (row, col)
					model.set_message (model.star_entity.set_normal_info_message (model.weapon, model.power, model.score))
					Result:=Result + "      The Starfighter at location [" + model.star_entity.location.x.out
				+ "," + model.star_entity.location.y.out +"] has been destroyed.%N"
					model.set_death
				end
    		end

    		--Search through all the friendly proj for location
			from
				model.proj_handler.proj_list.start
			until
				(model.proj_handler.proj_list.exhausted) or stop_search
			loop
				if model.proj_handler.proj_list.item.location ~ temp_loc then

					if (model.proj_handler.proj_list.item.proj_damage - enemy.armour) > 0 then
						enemy.sub_health (model.proj_handler.proj_list.item.proj_damage - enemy.armour)
						damage_taken:=model.proj_handler.proj_list.item.proj_damage - enemy.armour
					else
						damage_taken:=0
					end

					Result:= Result +"      The " + entity_type + " collides with friendly projectile(id:" + model.proj_handler.proj_list.item.id.out +
					") at location [" + row.out + "," + col.out + "], taking " + damage_taken.out
					+ " damage.%N"

					temp_index:=model.get_location_index (model.proj_handler.proj_list.item.location.x, model.proj_handler.proj_list.item.location.y)
					model.board.replace_substring ("_", temp_index, temp_index)
					stop_search:= True

					if enemy.health <= 0 then
						Result:=Result + "      The " + enemy.entity_type + " at location ["+ enemy.location.x.out
						+ "," + enemy.location.y.out + "] has been destroyed.%N"
						enemy.drop_score
						model.set_score (model.score_keeper.value)
					end
					model.proj_handler.proj_list.remove
				else
					model.proj_handler.proj_list.forth
				end
			end

			--Search through all the enemy proj for location
			from
				model.enemy_proj_handler.proj_list.start
			until
				(model.enemy_proj_handler.proj_list.exhausted) or stop_search
			loop
				if model.enemy_proj_handler.proj_list.item.location ~ temp_loc then

					enemy.add_health (model.enemy_proj_handler.proj_list.item.proj_damage)

					Result:= Result +"      The " + enemy.entity_type + " collides with enemy projectile(id:" + model.enemy_proj_handler.proj_list.item.id.out
					 + ") at location [" + row.out + "," + col.out + "], healing " + model.enemy_proj_handler.proj_list.item.proj_damage.out + " damage.%N"
					temp_index:=model.get_location_index (model.enemy_proj_handler.proj_list.item.location.x, model.enemy_proj_handler.proj_list.item.location.y)
					model.board.replace_substring ("_", temp_index, temp_index)
					model.enemy_proj_handler.proj_list.remove
					stop_search:= True
				else
					model.enemy_proj_handler.proj_list.forth
				end
			end

			--Search through all the enemies for location
			from
				l_c:=1
			until
				(l_c = model.enemy_handler.enemy_list.count + 1) or stop_search
			loop
				if (model.enemy_handler.enemy_list.at(l_c).location.x = row and model.enemy_handler.enemy_list.at(l_c).location.y = col) and (model.enemy_handler.enemy_list.at(l_c).id /= enemy.id) then
					if movement ~ "H" then
						enemy.set_location (row, col + 1)
					elseif movement ~ "VA" then
						enemy.set_location (row-1, col)
					elseif movement ~ "VB" then
						enemy.set_location (row+1, col)
					end

					stop_search:=True
					enemy.set_stop_check(True)
				end
				l_c:=l_c+1
			end

    	end






end
