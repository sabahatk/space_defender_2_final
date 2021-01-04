note
	description: "Summary description for {PYLON_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PYLON_ENTITY
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
			symbol:= 'P'
			entity_type:= "Pylon"
			health:= 300
			health_total := 300
			regen:=0
			armour:=0
			vision:=5
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
			end_turn:=False
		end

	play_action
		do
			reset_spawn_message
			if end_turn = False then
				add_health(regen)
				if can_see_starfighter then
					move_enemy(1)
					if Current.health > 0 and location.y >= 1 then
						enemy_fire(70,2)
					end
				else
					move_enemy(2)
					if Current.health > 0 and location.y >= 1 then
						heal_enemies_in_range
					end
				end
			end
		end

	heal_enemies_in_range
		local
			v_dist, h_dist: INTEGER
		do
			from
				model.enemy_handler.enemy_list.start
			until
				model.enemy_handler.enemy_list.exhausted
			loop
				v_dist:=(Current.location.x.code - model.enemy_handler.enemy_list.item.location.x.code).abs
				h_dist:=(Current.location.y - model.enemy_handler.enemy_list.item.location.y).abs

				if (h_dist + v_dist) <= Current.vision and model.enemy_handler.enemy_list.item.location.y >= 1 then
					model.enemy_handler.enemy_list.item.add_health(10)
					model.enemy_handler.append_action_message ("      The " + Current.entity_type + " heals " + model.enemy_handler.enemy_list.item.entity_type
					+ "(id:" + model.enemy_handler.enemy_list.item.id.out + ") at location [" + model.enemy_handler.enemy_list.item.location.x.out
					+ "," + model.enemy_handler.enemy_list.item.location.y.out + "] for 10 damage.%N")
				end
				model.enemy_handler.enemy_list.forth
			end
		end

	drop_score
		local
			f: FOCUS
		do
			create f.make_type ('P')
			f.children.extend (create {ORBMENT}.make('B'))
			model.score_keeper.add (f)
		end

end
