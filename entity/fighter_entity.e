note
	description: "Summary description for {FIGHTER_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FIGHTER_ENTITY
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
			symbol:= 'F'
			entity_type:= "Fighter"
			health:= 150
			health_total := 150
			regen:=5
			armour:=10
			vision:=10
			seen_by_starfighter:= False
			can_see_starfighter:= False
			can_preempt:= False
		end

feature -- Attributes
	can_preempt: BOOLEAN



feature -- commands

	play_preempt(turn: CHARACTER)
		do
			reset_spawn_message
			if turn = 'F' then
				add_armour(1)
				model.enemy_handler.append_action_message("    A " + entity_type + "(id:" + id.out + ") gains 1 armour.%N")
				end_turn:=False
			elseif turn = 'P' then
				add_health(regen)
				move_enemy(6)
				if Current.health > 0 and location.y >= 1 then
					enemy_fire(100,10)
				end
				end_turn:=True
			else
				end_turn:=False
			end
		end

	play_action
		do
			reset_spawn_message
			if end_turn = False then
				add_health(regen)
				if can_see_starfighter then
					move_enemy(1)
					if Current.health > 0 and location.y >=1 then
						enemy_fire(50,6)
					end
				else
					move_enemy(3)
					if Current.health>0 and location.y >= 1  then
						enemy_fire(20,3)
					end
				end
			end
		end

	drop_score
		do
			model.score_keeper.add (create {ORBMENT}.make ('G'))
		end

	add_armour(a: INTEGER)
		do
			armour:=armour+a
		end

end
