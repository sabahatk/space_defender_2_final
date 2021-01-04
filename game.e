note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	GAME

inherit
	ANY
		redefine
			out
		end

create {GAME_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			state:=0
			error_state:=0
			col:=0
			row:=0
			score:=0
			proj_id_counter:=0
			enemy_id_counter:=0
			create in_game_state.make_empty
			create game_mode.make_empty
			create current_state.make_empty
			create message.make_empty
			create debug_message.make_empty
			create board.make_empty
			create weapon.make_empty
			create armour.make_empty
			create engine.make_empty
			create power.make_empty
			create full_proj_info.make_empty
			create setup_config.make
			create star_entity.make
			create proj_handler.make
			create enemy_handler.make
			create score_keeper.make
			create enemy_proj_handler.make
			create spawn_point


			is_ship_alive:=True
			in_game_state:= "not started"
			game_mode:="normal"
			current_state:="ok"
			message:="  Welcome to Space Defender Version 2."
			weapon:="Standard"
			armour:="None"
			engine:="Standard"
			power:="Recall (50 energy): Teleport back to spawn."
		end

feature -- model attributes
	state, error_state, col, row, score, proj_id_counter, enemy_id_counter: INTEGER
	g_thresh, f_thresh, c_thresh, i_thresh, p_thresh: INTEGER
	max_row_letter: CHARACTER
	in_game_state, game_mode, current_state, message, debug_message, board, weapon, armour, engine, power, full_proj_info: STRING
	spawn_point: TUPLE[x:CHARACTER; y:INTEGER]
	setup_config: SETUP_HELPER
	star_entity: STARSHIP_ENTITY
	proj_handler: PROJ_HELPER
	is_ship_alive: BOOLEAN
	score_keeper: COMPOSITE_SCORE
	enemy_proj_handler: ENEMY_PROJ_HELPER
	enemy_handler: ENEMY_ENTITY_HELPER
	r_access: RANDOM_GENERATOR_ACCESS

feature -- state related operations

	state_update
			-- Perform update to the model state.
		do
			state := state + 1
		end

	error_update
			--Perform update to the error state
		do
			error_state:= error_state + 1
		end

	error_reset
			--Reset error state
		do
			error_state:=0
		end

	set_in_game_state(game_state: STRING)
			-- set in game state
		do
			in_game_state := game_state
		end

	change_game_mode(set_debug_mode: BOOLEAN)
			--set the game mode (debug or normal)
		do
			if set_debug_mode then
				game_mode:="debug"
			else
				game_mode:="normal"
			end
		end

	change_current_state(is_normal: BOOLEAN)
		do
			if is_normal then
				current_state:="ok"
			else
				current_state:="error"
			end
		end

feature -- set operations

	add_score(s: INTEGER)
		do
			score:=score + s
		end

	set_score(s: INTEGER)
		do
			score:=s
		end

	set_message(s:STRING)
		do
			message:= s
		end

	next_proj_id
		do
			proj_id_counter:=proj_id_counter-1
		end

	next_enemy_id
		do
			enemy_id_counter:=enemy_id_counter + 1
		end

	append_message(s: STRING)
		do
			message:= message + s
		end

	append_full_proj_info(s: STRING)
		do
			full_proj_info:=full_proj_info + s
		end

	setup_full_proj_info
		local
			l_c: INTEGER
			remove_proj_check, remove_e_proj_check, found: BOOLEAN
		do
			from
				l_c:=-1
			until
				l_c= proj_id_counter-1
			loop
				found:=False
				from
					proj_handler.proj_list.start
				until
					proj_handler.proj_list.exhausted
				loop
					if proj_handler.proj_list.item.id = l_c then
						found:=True
						if (proj_handler.proj_list.item.location.y <= col) and (proj_handler.proj_list.item.location.x >= 'A' and proj_handler.proj_list.item.location.x <= max_row_letter) then
							append_full_proj_info("    [" + proj_handler.proj_list.item.id.out + "," + proj_handler.proj_list.item.symbol.out
							+ "]->damage:" + proj_handler.proj_list.item.proj_damage.out + ", move:" + proj_handler.proj_list.item.proj_distance.out +
							", location:[" + proj_handler.proj_list.item.location.x.out + "," + proj_handler.proj_list.item.location.y.out + "]%N")
						else
							remove_proj_check:=True
						end
					end
					proj_handler.proj_list.forth
				end

				if found = False then
					from
						enemy_proj_handler.proj_list.start
					until
						enemy_proj_handler.proj_list.exhausted
					loop
						if enemy_proj_handler.proj_list.item.id = l_c then
							if (enemy_proj_handler.proj_list.item.location.y >= 1) and (enemy_proj_handler.proj_list.item.location.x >= 'A' and enemy_proj_handler.proj_list.item.location.x <= max_row_letter) then
								append_full_proj_info("    [" + enemy_proj_handler.proj_list.item.id.out + "," + enemy_proj_handler.proj_list.item.symbol.out
								+ "]->damage:" + enemy_proj_handler.proj_list.item.proj_damage.out + ", move:" + enemy_proj_handler.proj_list.item.proj_distance.out +
								", location:[" + enemy_proj_handler.proj_list.item.location.x.out + "," + enemy_proj_handler.proj_list.item.location.y.out + "]%N")
							else
								remove_e_proj_check:=True
							end
						end
						enemy_proj_handler.proj_list.forth
					end
				end

				l_c:=l_c - 1
			end

			if remove_proj_check then
				proj_handler.delete_out_of_board_proj
			end

			if remove_e_proj_check then
				enemy_proj_handler.delete_out_of_board_proj
			end
		end

	set_thresh(g: INTEGER; f: INTEGER; c: INTEGER; i: INTEGER; p :INTEGER)
		do
			g_thresh := g
			f_thresh := f
			c_thresh := c
			i_thresh := i
			p_thresh := p
		end

	set_is_ship_alive(b: BOOLEAN)
		do
			is_ship_alive:= b
		end

	set_symbols_back
		local
			temp_index: INTEGER
		do
			from
				proj_handler.proj_list.start
			until
				proj_handler.proj_list.exhausted
			loop
				if within_bounds(proj_handler.proj_list.item.location.x, proj_handler.proj_list.item.location.y) and proj_handler.proj_list.item.removed = False then
					temp_index:= get_location_index(proj_handler.proj_list.item.location.x, proj_handler.proj_list.item.location.y)
					if board.at(temp_index) = '_' then
						board.replace_substring (proj_handler.proj_list.item.symbol.out, temp_index, temp_index)
					end
				end
				proj_handler.proj_list.forth
			end

			from
				enemy_proj_handler.proj_list.start
			until
				enemy_proj_handler.proj_list.exhausted
			loop
				if within_bounds(enemy_proj_handler.proj_list.item.location.x,enemy_proj_handler.proj_list.item.location.y) and enemy_proj_handler.proj_list.item.removed = False then
					temp_index:= get_location_index(enemy_proj_handler.proj_list.item.location.x, enemy_proj_handler.proj_list.item.location.y)
					if board.at(temp_index) = '_' then
						board.replace_substring (enemy_proj_handler.proj_list.item.symbol.out, temp_index, temp_index)
					end
				end
				enemy_proj_handler.proj_list.forth
			end

			from
				enemy_handler.enemy_list.start
			until
				enemy_handler.enemy_list.exhausted
			loop
				if within_bounds(enemy_handler.enemy_list.item.location.x, enemy_handler.enemy_list.item.location.y) then
					temp_index:= get_location_index(enemy_handler.enemy_list.item.location.x, enemy_handler.enemy_list.item.location.y)
					if board.at(temp_index) = '_' then
						board.replace_substring (enemy_handler.enemy_list.item.symbol.out, temp_index, temp_index)
					end
				end
				enemy_handler.enemy_list.forth
			end
		end


	set_col(i: INTEGER)
		do
			col:=i
		end

	set_row(i: INTEGER)
		do
			row:=i
		end

	set_row_letter(c: CHARACTER)
		do
			max_row_letter := c
		end


	set_weapon(s: STRING)
	do
		weapon:= s
	end

	set_armour(s: STRING)
	do
		armour:= s
	end

	set_engine(s: STRING)
	do
		engine:= s
	end

	set_power(s:STRING)
	do
		power:=s
	end

	set_spawn_point(loc: TUPLE[CHARACTER, INTEGER])
		do
			spawn_point:= loc.deep_twin
		end

	set_setup_message
		do
			set_message (setup_config.setup_list.at (setup_config.cursor))

			if setup_config.cursor = 1 then
				set_in_game_state ("weapon setup")
				append_message ("  Weapon Selected:" + weapon)
			elseif setup_config.cursor = 2 then
				set_in_game_state ("armour setup")
				append_message ("  Armour Selected:" + armour)
			elseif setup_config.cursor = 3 then
				set_in_game_state ("engine setup")
				append_message ("  Engine Selected:" + engine)
			elseif setup_config.cursor = 4 then
				set_in_game_state ("power setup")
				append_message ("  Power Selected:" + power)
			elseif setup_config.cursor = 5 then
				set_in_game_state ("setup summary")
				append_message ("  Weapon Selected:" + weapon + "%N  Armour Selected:" + armour + "%N  Engine Selected:" + engine + "%N  Power Selected:" + power)
			end
		end

	set_death
		local
			i: INTEGER
		do
			if star_entity.health <=0 then
				i:= get_location_index (star_entity.location.x, star_entity.location.y)
				board.replace_substring ("X", i, i)
--				star_entity.append_action_message ("The Starfighter at location [" + star_entity.location.x.out
--				+ "," + star_entity.location.y.out +"] has been destroyed.%N")
				set_in_game_state ("not started")
				is_ship_alive:=False
			end
		end

	append_board(b: STRING)
		do
			board:=board + b
		end
	set_board(b: STRING)
		do
			board:= b.deep_twin
		end
feature -- get commands

	get_location_index(r: CHARACTER; c: INTEGER): INTEGER
		require
			(r>= 'A') and (r <= max_row_letter)
		local
			l_c: INTEGER
			stop_search: BOOLEAN
		do
			stop_search := False
			from
				l_c:=1
			until
				stop_search
			loop
				if (board.at (l_c) = r) and (board.at (l_c+2) /= ' ') then
					stop_search:=True
				else
					l_c:=l_c + 1
				end
			end

			Result:=l_c
			Result:= Result + c*3 - 1
		end

		within_bounds(r: CHARACTER; c: INTEGER):BOOLEAN
			do
			 	if (r >= 'A')
			 	and (r <= max_row_letter)
			 	and (c >= 1)
			 	and (c <= col) then
			 		Result:=True
			 	else
			 		Result:=False
			 	end
			end

		get_row_letter(i: INTEGER): CHARACTER
			require
				i>=1 and i<=10
			do
				if i = 1 then
					Result:= 'A'
				elseif i = 2 then
					Result:= 'B'
				elseif i = 3 then
					Result:= 'C'
				elseif i = 4 then
					Result:= 'D'
				elseif i = 5 then
					Result:= 'E'
				elseif i = 6 then
					Result:= 'F'
				elseif i = 7 then
					Result:= 'G'
				elseif i = 8 then
					Result:= 'H'
				elseif i = 9 then
					Result:= 'I'
				elseif i = 10 then
					Result:= 'J'
				end
			end

feature -- update commands

		update_debug_message
		do
			reset_full_proj_info
			setup_full_proj_info
			debug_message:= "  Enemy:%N" + enemy_handler.enemy_info_message +"  Projectile:%N" + full_proj_info + "  Friendly Projectile Action:%N" + proj_handler.proj_action_message
			+ "  Enemy Projectile Action:%N" + enemy_proj_handler.proj_action_message +"  Starfighter Action:%N" + star_entity.action_message + "  Enemy Action:%N" + enemy_handler.enemy_action_message
			+ "  Natural Enemy Spawn:%N" + enemy_handler.enemy_spawn_message
			if proj_handler.proj_list.count = 0 then
				proj_handler.reset_action_message
			end
		end

--		update_fire
--			local
--				l_c, temp_index: INTEGER
--				temp_loc, init_pos, end_pos: TUPLE[x: CHARACTER; y: INTEGER]
--				outside_board:BOOLEAN

--			do
--				create temp_loc
--				create init_pos
--				create end_pos
--				proj_handler.reset_action_message
--				from
--					l_c:=1
--				until
--					l_c= proj_handler.proj_list.count + 1
--				loop
--						outside_board:=False
--						temp_loc.x := proj_handler.proj_list.at (l_c).location.x
--						temp_loc.y := proj_handler.proj_list.at (l_c).location.y
--						init_pos := temp_loc.deep_twin

--						if (temp_loc.y <= col) and (temp_loc.x >= 'A') and (temp_loc.x <= max_row_letter) then
--						temp_index:= get_location_index (temp_loc.x, temp_loc.y)


--						if (temp_loc.y <= col) and (temp_loc.x >= 'A') and (temp_loc.x <= max_row_letter) then
--							board.replace_substring ("_", temp_index, temp_index)
--						end

--						if proj_handler.proj_list.at (l_c).proj_direction ~ "R" then
--							temp_loc.y:=temp_loc.y + proj_handler.proj_list.at (l_c).proj_distance
--							end_pos:= temp_loc
--							proj_handler.proj_list.at (l_c).set_proj_location ([temp_loc.x, temp_loc.y])

--							if temp_loc.y <= col then
--								temp_index:= get_location_index (temp_loc.x, temp_loc.y)
--							else
--								outside_board:=True
--							end

--							if weapon ~ "Rocket" then
--								proj_handler.proj_list.at (l_c).set_proj_distance (proj_handler.proj_list.at (l_c).proj_distance*2)
--							end

--						elseif proj_handler.proj_list.at (l_c).proj_direction ~ "UR" then
--							temp_loc.x := temp_loc.x - 1
--							temp_loc.y:=temp_loc.y + proj_handler.proj_list.at (l_c).proj_distance
--							end_pos:= temp_loc
--							proj_handler.proj_list.at (l_c).set_proj_location ([temp_loc.x, temp_loc.y])

--							if temp_loc.x >= 'A' then
--								temp_index:= get_location_index (temp_loc.x, temp_loc.y)
--							else
--								outside_board:= True
--							end

--						elseif proj_handler.proj_list.at (l_c).proj_direction ~ "DR" then
--							temp_loc.x := temp_loc.x + 1
--							temp_loc.y:=temp_loc.y + proj_handler.proj_list.at (l_c).proj_distance
--							end_pos:= temp_loc
--							proj_handler.proj_list.at (l_c).set_proj_location ([temp_loc.x, temp_loc.y])

--							if temp_loc.x <= max_row_letter then
--								temp_index:= get_location_index (temp_loc.x, temp_loc.y)
--							else
--								outside_board := True
--							end

--						end

--						if (temp_loc.y <= col) and (temp_loc.x >= 'A' and temp_loc.x <= max_row_letter) and outside_board = False then
--							board.replace_substring ("*", temp_index, temp_index)
--							proj_handler.append_action_message ("    A friendly projectile(id:" + proj_handler.proj_list.at (l_c).id.out
--							+ ") moves: [" + init_pos.x.out + "," + init_pos.y.out + "] -> [" + end_pos.x.out + "," + end_pos.y.out + "]%N")

--						else
--							proj_handler.append_action_message ("    A friendly projectile(id:" + proj_handler.proj_list.at (l_c).id.out
--							+ ") moves: [" + init_pos.x.out + "," + init_pos.y.out + "] -> out of board%N")
--						end
--					end

--					l_c:= l_c + 1
--				end
--				proj_handler.delete_out_of_board_proj
--			end

feature --reset

	reset_full_proj_info
		do
			full_proj_info.make_empty
		end

	reset
		local
			w,a,e,p,g_m: STRING
			-- Reset model state.
		do
			create w.make_empty
			create a.make_empty
			create e.make_empty
			create p.make_empty
			create g_m.make_empty

			w:= weapon.deep_twin
			a:= armour.deep_twin
			e:= engine.deep_twin
			p:=power.deep_twin
			g_m:=game_mode.deep_twin
--			weapon:="Standard"
--					armour:="None"
--					engine:="Standard"
--					power:="Recall (50 energy): Teleport back to spawn."
--			state:=0
--			error_state:=0
--			col:=0
--			row:=0
--			score:=0
--			proj_id_counter:=0
--			enemy_id_counter:=0

--			create in_game_state.make_empty
--			create current_state.make_empty
--			create full_proj_info.make_empty
--			create debug_message.make_empty
--			create message.make_empty
--			create board.make_empty
--			create setup_config.make
--			create star_entity.make
--			create proj_handler.make
--			create enemy_handler.make
--			create enemy_proj_handler.make
--			create spawn_point
--			is_ship_alive:=True

--			in_game_state:= "not started"
--			current_state:="ok"
--			message:="  Welcome to Space Defender Version 2."
			make
			weapon:=w
			armour:=a
			engine:=e
			power:=p
			game_mode:=g_m
		end

feature -- output
	out : STRING
		do
			create Result.make_from_string ("  ")

			if in_game_state.substring (1, 7) ~ "in game" then
				set_in_game_state ("in game(" + state.out + "." + error_state.out + ")")
			end

			Result.append ("state:" + in_game_state + ", " + game_mode + ", " + current_state + "%N")
			Result.append (message)

			if (in_game_state.substring (1, 7) ~ "in game") or (is_ship_alive = False) then
				if error_state = 0 and current_state ~ "ok" then
					Result.append("%N")
					if game_mode ~ "debug" then
						update_debug_message
						star_entity.clear_vision(board)
						Result.append (debug_message)
					end
					Result.append(board)

					if is_ship_alive = False then
						Result.append("%N  The game is over. Better luck next time!")
					end

				end
			end

		end

end




