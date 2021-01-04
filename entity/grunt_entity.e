note
	description: "Summary description for {GRUNT_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GRUNT_ENTITY
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
			symbol:= 'G'
			entity_type:= "Grunt"
			health:= 100
			health_total := 100
			regen:=1
			armour:=1
			vision:=5
			seen_by_starfighter:= False
			can_see_starfighter:= False
			can_preempt:= False
		end

feature --Attributes
	can_preempt: BOOLEAN

feature -- spawn command


	play_preempt(turn:CHARACTER)
		do
			reset_spawn_message
			if turn = 'P' then
				preempt_health(10)
				preempt_health_total(10)
				model.enemy_handler.append_action_message("    A " + entity_type + "(id:" + id.out + ") gains 10 total health.%N")
			elseif turn = 'S' then
				preempt_health(20)
				preempt_health_total(20)
				model.enemy_handler.append_action_message("    A " + entity_type + "(id:" + id.out + ") gains 20 total health.%N")
			end
			end_turn:=False
		end

	play_action
		do
			if end_turn = False then
				reset_spawn_message
				add_health(regen)
				if can_see_starfighter then
					move_enemy(4)
				else
					move_enemy(2)
				end
				if Current.health > 0 and location.y >= 1 then
					enemy_fire(15,4)
				end
			end
		end

	drop_score
		do
			model.score_keeper.add (create {ORBMENT}.make ('S'))
		end

	preempt_health(h: INTEGER)
		do
			health:= health + h
		end

	preempt_health_total(h: INTEGER)
		do
			health_total:=health_total + h
		end




end
