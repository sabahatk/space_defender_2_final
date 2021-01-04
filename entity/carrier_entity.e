note
	description: "Summary description for {CARRIER_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CARRIER_ENTITY
	inherit
		ENEMY_ENTITY
			redefine
				make
			end
create make

feature --make
	make
	--Set all attributes
		do
			Precursor
			symbol:= 'C'
			entity_type:= "Carrier"
			health:= 200
			health_total := 200
			regen:=10
			armour:=15
			vision:=15
			seen_by_starfighter:= False
			can_see_starfighter:= False
			end_turn:=False
		end

feature -- set attributes commands

	add_regen(regen_amount: INTEGER)
		--increase enemy regen amount
		require
			regen_amount > 0
		do
			regen:=regen+regen_amount
		ensure
			regen = old regen + regen_amount
		end

feature --spawn related commands

	--spawn two interceptors: one above, one below
	spawn_preempt_interceptors
		do
			spawn_interceptor(location.x-1, location.y)
			spawn_interceptor (location.x + 1, location.y)
		end

	--spawn interceptor given location
	spawn_interceptor(row: CHARACTER; column: INTEGER)
		local
			enemy: INTERCEPTOR_ENTITY
			spawn_index: INTEGER
		do
			reset_spawn_message
			if is_spawn_loc_clear(row,column) then
				create enemy.make
				if (row >= 'A')
				and (row <= model.max_row_letter)
				and (column >= 1)
				and (column <= model.col) then
					spawn_index := model.get_location_index (row, column)
					enemy.set_location ([row, column])
					model.board.replace_substring (enemy.symbol.out, spawn_index, spawn_index)
					enemy.set_can_see_fighter
					enemy.set_seen_by_starfighter
					enemy.set_spawned_by_carrier (True)
					model.enemy_handler.add_enemy (enemy)
					model.enemy_handler.append_action_message ("      A " + enemy.entity_type + "(id:"
					+ enemy.id.out + ") spawns at location [" + enemy.location.x.out + "," + enemy.location.y.out + "].%N")
				else
					model.enemy_handler.append_action_message ("      A " + enemy.entity_type + "(id:"
					+ enemy.id.out + ") spawns at location out of board.%N")
				end
			end
		end

		--check if location for spawning is clear
		is_spawn_loc_clear(r:CHARACTER; c: INTEGER):BOOLEAN
			do
				Result:=True
				from
					model.enemy_handler.enemy_list.start
				until
					model.enemy_handler.enemy_list.exhausted
				loop
					if model.enemy_handler.enemy_list.item.location.x = r
					and model.enemy_handler.enemy_list.item.location.y = c then
						Result:=False
					end
					model.enemy_handler.enemy_list.forth
				end
			end

feature --action commands

	--play carrier's premptive action
	play_preempt(turn: CHARACTER)
		do
			reset_spawn_message
			if turn = 'P' then
				add_health(regen)
				move_enemy(2)
				if Current.health > 0 and location.y >=1 then
					spawn_preempt_interceptors
				end
				end_turn:=True
			elseif turn = 'S' then
				if Current.health > 0 and location.y >=1 then
					add_regen(10)
					model.enemy_handler.append_action_message("    A " + entity_type + "(id:" + id.out + ") gains 10 regen.%N")
					end_turn:=False
				else
					end_turn:=True
				end

			else
				end_turn:=False
			end
		end

    --play carrier's non-preemptive action
	play_action
		do
			reset_spawn_message
			if end_turn = False then
				add_health(regen)
				if can_see_starfighter then
					move_enemy(1)
					if Current.health > 0 and location.y >= 1 then
						spawn_interceptor(location.x, location.y -1)
					end
				else
					if Current.health > 0 and location.y >=1  then
						move_enemy(2)
					end
				end
			end
		end

	--drop a diamond focus with a gold orb in the first slot
	drop_score
	local
		f: FOCUS
	do
		create f.make_type ('D')
		f.children.extend (create {ORBMENT}.make('G'))
		model.score_keeper.add (f)
	end
end
