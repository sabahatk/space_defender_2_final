note
	description: "Summary description for {ENEMY_ENTITY_HELPER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENEMY_ENTITY_HELPER
create make

feature --make
	make
		do
			create enemy_list.make(0)
			create enemy_info_message.make_empty
			create enemy_action_message.make_empty
			create enemy_spawn_message.make_empty
			cursor:=0
		end

feature --Attributes
	enemy_list: ARRAYED_LIST[ENEMY_ENTITY]
	cursor: INTEGER
	enemy_info_message, enemy_action_message, enemy_spawn_message: STRING

feature --enemy list related commands

	add_enemy(e: ENEMY_ENTITY)
		do
			enemy_list.extend (e)
		end

	remove_enemy(e: ENEMY_ENTITY)
		do
			enemy_list.prune(e)
		end

	remove_all_dead_enemies(b: STRING)
		local
			temp_index: INTEGER
		do
			from
				enemy_list.start
			until
				enemy_list.exhausted
			loop
				if enemy_list.item.health <= 0 then
					temp_index:= enemy_list.item.model.get_location_index(enemy_list.item.location.x, enemy_list.item.location.y)
					if b.at(temp_index) = enemy_list.item.symbol then
						b.replace_substring("_", temp_index, temp_index)
					end
					enemy_list.item.drop_score
					enemy_list.remove
				else
					enemy_list.forth
				end
			end

		end

	remove_all_outside_enemies(max_row: CHARACTER; max_col: INTEGER)
		local
			r:CHARACTER
			c: INTEGER
		do
			from
				enemy_list.start
			until
				enemy_list.exhausted
			loop
				r:= enemy_list.item.location.x
				c:=enemy_list.item.location.y

				if ((r >= 'A')
			 	and (r <= max_row)
			 	and (c >= 1)
			 	and (c <= max_col)) = False then
					enemy_list.remove
				else
					enemy_list.forth
				end
			end

		end

	set_enemy_info_message(s: STRING)
		do
			enemy_info_message:=s
		end

	append_enemy_info_message(s: STRING)
		do
			enemy_info_message:= enemy_info_message + s
		end

	reset_spawn_message
		do
			enemy_spawn_message.make_empty
		end

	set_spawn_message(s: STRING)
		do
			enemy_spawn_message:=s
		end

	append_spawn_message(s: STRING)
		do
			enemy_spawn_message:=enemy_spawn_message + s
		end

	reset_action_message
		do
			enemy_action_message.make_empty
		end

	set_action_message(s: STRING)
		do
			enemy_action_message:=s
		end

	append_action_message(s: STRING)
		do
			enemy_action_message:= enemy_action_message + s
		end

	setup_spawn(g: INTEGER; f: INTEGER; c: INTEGER; i: INTEGER; p: INTEGER; r_letter: CHARACTER; s_num:INTEGER; max_col: INTEGER)
		local
			spawn_row: CHARACTER
			spawn_successful: BOOLEAN
			enemy: ENEMY_ENTITY
			temp_message: STRING
		do
			reset_spawn_message
			create temp_message.make_empty
			if s_num >= 1 and s_num < g then
				if is_enemy_in_location (r_letter, max_col) = False then
					enemy:= create {GRUNT_ENTITY}.make
					spawn_row:= r_letter
					spawn_successful:=enemy.spawn (spawn_row)
					if spawn_successful then
						add_enemy(enemy)
						temp_message:=temp_message + enemy_list.at (enemy_list.count).check_collision (spawn_row, max_col, enemy_list.at (enemy_list.count), "H")
					end
				end
			elseif s_num >= g and s_num < f then
				if is_enemy_in_location (r_letter, max_col) = False then
					enemy:= create {FIGHTER_ENTITY}.make
					spawn_row:= r_letter
					spawn_successful:= enemy.spawn (spawn_row)
					if spawn_successful then
						add_enemy(enemy)
						temp_message:=temp_message + enemy_list.at (enemy_list.count).check_collision (spawn_row, max_col, enemy_list.at (enemy_list.count), "H")
					end
				end
			elseif s_num >= f and s_num < c then
				if is_enemy_in_location (r_letter, max_col) = False then
					enemy:= create {CARRIER_ENTITY}.make
					spawn_row:= r_letter
					spawn_successful:= enemy.spawn (spawn_row)
					if spawn_successful then
						add_enemy(enemy)
						temp_message:=temp_message + enemy_list.at (enemy_list.count).check_collision (spawn_row, max_col, enemy_list.at (enemy_list.count), "H")
					end
				end
			elseif s_num >= c and s_num < i then
				if is_enemy_in_location (r_letter, max_col) = False then
					enemy:= create {INTERCEPTOR_ENTITY}.make
					spawn_row:= r_letter
					spawn_successful:= enemy.spawn (spawn_row)
					if spawn_successful then
						add_enemy(enemy)
						temp_message:=temp_message + enemy_list.at (enemy_list.count).check_collision (spawn_row, max_col, enemy_list.at (enemy_list.count), "H")
					end
				end
			elseif s_num >= i and s_num < p then
				if is_enemy_in_location (r_letter, max_col) = False then
					enemy:= create {PYLON_ENTITY}.make
					spawn_row:= r_letter
					spawn_successful:= enemy.spawn (spawn_row)
					if spawn_successful then
						add_enemy(enemy)
						temp_message:=temp_message + enemy_list.at (enemy_list.count).check_collision (spawn_row, max_col, enemy_list.at (enemy_list.count), "H")
					end
				end
			elseif s_num >= p and s_num < 101 then
			--	Spawn nothing
			end

			setup_spawn_message(temp_message)
		end

	setup_enemy_info_message
		local
			l_c, remove_counter: INTEGER
		do
			set_enemy_info_message("")
			if enemy_list.count > 0 then
				from
					l_c:=1
				until
					l_c = enemy_list.count + 1
				loop
					if enemy_list[l_c].location.y >= 1 then
						if enemy_list[l_c].health > 0 then
							append_enemy_info_message ("    [" + enemy_list[l_c].id.out
							+"," + enemy_list[l_c].symbol.out + "]->health:" + enemy_list[l_c].health.out
							+"/" + enemy_list[l_c].health_total.out + ", Regen:" + enemy_list[l_c].regen.out
							+", Armour:" + enemy_list[l_c].armour.out + ", Vision:" + enemy_list[l_c].vision.out
							+ ", seen_by_Starfighter:" + enemy_list[l_c].seen_by_starfighter.out.substring (1, 1) + ", can_see_Starfighter:"
							+ enemy_list[l_c].can_see_starfighter.out.substring(1,1) + ", location:[" + enemy_list[l_c].location.x.out
							+ "," + enemy_list[l_c].location.y.out + "]%N")
						end
					else
						remove_counter:=remove_counter+1
					end

					l_c:=l_c + 1
				end
			end

			if remove_counter > 0 then
				remove_outside_entities
			end
		end

	play_all_enemies(turn: CHARACTER)
		local
			l_c: INTEGER
			turn_of_death:INTEGER
		do
			reset_action_message
			turn_of_death:=0
			if enemy_list.count >= 1 then
				from
					l_c:=1
				until
					l_c=enemy_list.count + 1
				loop
					if enemy_list.at (l_c).model.star_entity.health > 0 then
						enemy_list.at(l_c).play_preempt(turn)
					end
					l_c:=l_c + 1
				end

				from
					l_c:=1
				until
					l_c=enemy_list.count + 1
				loop
					if enemy_list.at (l_c).model.star_entity.health > 0 then
						enemy_list.at(l_c).play_action
					end
					l_c:=l_c + 1
				end
				remove_outside_entities
			end
		end

	remove_outside_entities
		do
			if enemy_list.count >= 1 then
				from
					enemy_list.start
				until
					enemy_list.exhausted
				loop
					if enemy_list.item.location.y < 1 then
						enemy_list.remove
					else
						enemy_list.forth
					end
				end
			end

		end

	is_enemy_in_location(x: CHARACTER; y: INTEGER): BOOLEAN
		do
			Result:=False
			from
				enemy_list.start
			until
				enemy_list.exhausted
			loop
				if enemy_list.item.location.x = x and enemy_list.item.location.y = y then
					Result:=True
				end
				enemy_list.forth
			end
		end

	setup_spawn_message(append_message: STRING)
		local
			l_c: INTEGER
		do
			enemy_spawn_message:=""
			from
				l_c:=1
			until
				l_c = enemy_list.count + 1
			loop
				append_spawn_message(enemy_list[l_c].spawn_message)
				l_c:=l_c+1
			end
			append_spawn_message(append_message)
		end

		update_enemy_vision
			do
				from
					enemy_list.start
				until
					enemy_list.exhausted
				loop
					if enemy_list.item.model.star_entity.health > 0 then
						enemy_list.item.set_can_see_fighter
						enemy_list.item.set_seen_by_starfighter
					end
					enemy_list.forth
				end
			end




end
