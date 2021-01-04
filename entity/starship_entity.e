note
	description: "Summary description for {STARSHIP_ENTITY}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STARSHIP_ENTITY

create make

feature --make
	make
		do
			create location
			create action_message.make_empty

			id:=0
			symbol:= 'S'
			health:=0
			health_total:=0
			energy:=0
			energy_total:=0
			regen_health:=0
			regen_energy:=0
			vision:=0
			move:=0
			move_cost:=0
			armour:=0
			proj_damage:=0
			proj_cost:=0
		end

feature --Attributes
	id: INTEGER
	symbol: CHARACTER
	action_message: STRING
	health, health_total: INTEGER
	energy, energy_total: INTEGER
	regen_health, regen_energy: INTEGER
	vision: INTEGER
	move: INTEGER
	move_cost:INTEGER
	armour: INTEGER
	location: TUPLE[x: CHARACTER; y:INTEGER]
	proj_damage: INTEGER
	proj_cost: INTEGER


feature -- add/subtract commands

	add_health(h: INTEGER)
		do
			if health <= health_total and health+h >=health_total then
				set_health(health_total)
			elseif health < health_total then
				health:= health+h
			end
		end

	subtract_health(h: INTEGER)
		do
			if health-h <=0 then
				set_health(0)
			else
				health:=health-h
			end
		ensure
			health>=0
		end

	add_energy(e: INTEGER)
		do
			if energy <= energy_total and energy + e >= energy_total then
				set_energy(energy_total)
			elseif energy < energy_total then
				energy := energy + e
			end
		end

	subtract_energy(e: INTEGER)
		do
			if energy - e <=0 then
				set_energy(0)
			else
				energy := energy - e
			end
		ensure
			energy >=0
		end

	add_regen_health(r: INTEGER)
		do
			regen_health:=regen_health + r
		end

	add_regen_energy(r: INTEGER)
		do
			regen_energy:= regen_energy + r
		end

	add_armour(a: INTEGER)
		do
			armour:= armour + a
		end

	add_vision(v: INTEGER)
		do
			vision:=vision + v
		end

	add_move(m: INTEGER)
		do
			move:=move + m
		end

	add_move_cost(m_c: INTEGER)
		do
			move_cost:=move_cost+m_c
		end

feature --set commands

	set_health(h: INTEGER)
		do
			health:=h
		end

	set_health_total(h: INTEGER)
		do
			health_total:= h
		end

	set_energy_total(e: INTEGER)
		do
			energy_total:= e
		end

	set_energy(e: INTEGER)
		do
			energy:= e
		end

	set_proj_damage(p_d: INTEGER)
		do
			proj_damage:= p_d
		end

	set_proj_cost(p_c: INTEGER)
		do
			proj_cost:= p_c
		end

	set_location_x(x: CHARACTER)
		do
			location.x := x
		end

	set_location_y(y: INTEGER)
		do
			location.y:=y
		end

	set_location(row: CHARACTER; col: INTEGER)
		do
			location.x:=row
			location.y:=col
		end

	set_location_tuple(curr_loc: TUPLE[row: CHARACTER; col: INTEGER])
		do
			location := curr_loc
		end

	set_action_message(a_m: STRING)
		do
			action_message:= a_m
		end

	append_action_message(a_m: STRING)
		do
			action_message:=action_message + a_m
		end

	clear_vision(board: STRING)
		local
			l_c:INTEGER
		do
			from
				l_c:=1
			until
				l_c = board.count + 1
			loop
				if board.at (l_c) = '?' then
					board.replace_substring ("_", l_c, l_c)
				end
				l_c:=l_c+1
			end
		end

	set_vision(g_m: STRING;board: STRING; col:INTEGER)
	 	local
	 		l_c, column_num, row_sub, col_low, col_high: INTEGER
	 		row_letter: CHARACTER
		do
			if g_m ~ "normal" then
				row_letter:='A'
				column_num:=1
				col_low:= location.y-vision
				col_high:=location.y+vision

				clear_vision(board)

				from
					l_c:=1
				until
					l_c = board.count + 1
				loop
					row_sub:=row_diff(row_letter,location.x)

					if (board.at (l_c) = '_') or (board.at (l_c) = 'S') or (board.at (l_c) = '*') or (board.at (l_c) = '?') or (board.at (l_c) = 'X') or
					(board.at (l_c) = 'G' and board.at (l_c + 2) = ' ')  or (board.at (l_c) = 'F' and board.at (l_c + 2) = ' ') or (board.at (l_c) = 'C' and board.at (l_c + 2) = ' ')
					or (board.at (l_c) = 'I' and board.at (l_c + 2) = ' ') or (board.at (l_c) = 'P') or (board.at (l_c) = '<') then
							if (column_num < (col_low+row_sub)) or (column_num > (col_high-row_sub)) then
								board.replace_substring ("?", l_c, l_c)
							end

							if column_num = col then
								column_num:=1
								row_letter:=row_letter+1
							else
								column_num:=column_num+1
							end


						end
					l_c:=l_c+1
				end
			end
		end

feature -- find query

	find_starship(board: STRING; col: INTEGER): TUPLE[row: CHARACTER; column: INTEGER]
	 	local
	 		l_c, column_num: INTEGER
	 		row_letter: CHARACTER
	 	do
			create Result
			row_letter:='A'
			column_num:=1

			from
				l_c:=1
			until
				board.at (l_c) = 'S'
			loop
				if (board.at (l_c) = '_') or (board.at (l_c) = 'S') or (board.at (l_c) = '*') or (board.at (l_c) = '?')
				or ((board.at (l_c) = 'G')and row_letter /= 'G') or (board.at (l_c) = 'F' and row_letter /= 'F')
				 or (board.at (l_c) = 'I' and row_letter /= 'I' )
				or (board.at (l_c) = 'P') then
					if column_num = col then
						column_num:=1
						row_letter:=row_letter+1
					else
						column_num:=column_num+1
					end
				end
				l_c:=l_c+1
			end
			Result.row := row_letter
			Result.column := column_num
	 	end

 	row_diff(char1: CHARACTER; char2: CHARACTER): INTEGER
 		local
 			l_c: INTEGER
 			row_letter_small, row_letter_large: CHARACTER
 		do

 			if char1<=char2 then
 				row_letter_small:=char1
 				row_letter_large:=char2
 			elseif char2< char1 then
 				row_letter_small:=char2
 				row_letter_large:=char1
 			end


 			from
 				l_c:=1
 			until
 				row_letter_small = row_letter_large
 			loop
 				l_c:=l_c+1
 				Result:=Result+1
 				row_letter_small:=row_letter_small+1
 			end
 		end

 	row_diff_with_negative(char1: CHARACTER; char2:CHARACTER): INTEGER
 		local
 			l_c: INTEGER
 			row_letter_small, row_letter_large: CHARACTER
 		do

			if char1<=char2 then
 				row_letter_small:=char1
 				row_letter_large:=char2
 			elseif char2< char1 then
 				row_letter_small:=char2
 				row_letter_large:=char1
 			end

			from
 				l_c:=1
 			until
 				row_letter_small = row_letter_large
 			loop
 				l_c:=l_c+1
 				Result:=Result+1
 				row_letter_small:=row_letter_small+1
 			end

			if char1 < char2 then
				Result:=Result*-1
			end

 		end


	set_normal_info_message(weapon:STRING; power: STRING; score: INTEGER): STRING
		do
			if weapon ~ "Rocket" then
				Result:="  Starfighter:%N    [" + id.out + "," + symbol.out + "]->health:" + health.out + "/" + health_total.out
				+ ", energy:" + energy.out + "/" + energy_total.out + ", Regen:" + regen_health.out + "/"
				+ regen_energy.out+ ", Armour:" + armour.out+", Vision:" + vision.out + ", Move:"
				+ move.out + ", Move Cost:"+ move_cost.out + ", location:[" + location.x.out + ","
				+ location.y.out + "]%N      Projectile Pattern:" + weapon + ", Projectile Damage:" + proj_damage.out
				+", Projectile Cost:" + proj_cost.out + " (health)%N      Power:" + power +"%N      score:" + score.out
			else
				Result:="  Starfighter:%N    [" + id.out + "," + symbol.out + "]->health:" + health.out + "/" + health_total.out
				+ ", energy:" + energy.out + "/" + energy_total.out + ", Regen:" + regen_health.out + "/"
				+ regen_energy.out+ ", Armour:" + armour.out+", Vision:" + vision.out + ", Move:"
				+ move.out + ", Move Cost:"+ move_cost.out + ", location:[" + location.x.out + ","
				+ location.y.out + "]%N      Projectile Pattern:" + weapon + ", Projectile Damage:" + proj_damage.out
				+", Projectile Cost:" + proj_cost.out + " (energy)%N      Power:" + power +"%N      score:" + score.out
			end
		end

end
