note
	description: "Summary description for {SETUP_HELPER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SETUP_HELPER
create
	make

feature --Attributes
	setup_list: ARRAY[STRING]
	cursor: INTEGER

feature -- make
	make
		do
			create setup_list.make_empty
			setup_list.force("  1:Standard (A single projectile is fired in front)%N    Health:10, Energy:10, Regen:0/1, Armour:0, Vision:1, Move:1, Move Cost:1,%N    Projectile Damage:70, Projectile Cost:5 (energy)%N  2:Spread (Three projectiles are fired in front, two going diagonal)%N    Health:0, Energy:60, Regen:0/2, Armour:1, Vision:0, Move:0, Move Cost:2,%N    Projectile Damage:50, Projectile Cost:10 (energy)%N  3:Snipe (Fast and high damage projectile, but only travels via teleporting)%N    Health:0, Energy:100, Regen:0/5, Armour:0, Vision:10, Move:3, Move Cost:0,%N    Projectile Damage:1000, Projectile Cost:20 (energy)%N  4:Rocket (Two projectiles appear behind to the sides of the Starfighter and accelerates)%N    Health:10, Energy:0, Regen:10/0, Armour:2, Vision:2, Move:0, Move Cost:3,%N    Projectile Damage:100, Projectile Cost:10 (health)%N  5:Splitter (A single mine projectile is placed in front of the Starfighter)%N    Health:0, Energy:100, Regen:0/10, Armour:0, Vision:0, Move:0, Move Cost:5,%N    Projectile Damage:150, Projectile Cost:70 (energy)%N", setup_list.count+1)
			setup_list.force("  1:None%N    Health:50, Energy:0, Regen:1/0, Armour:0, Vision:0, Move:1, Move Cost:0%N  2:Light%N    Health:75, Energy:0, Regen:2/0, Armour:3, Vision:0, Move:0, Move Cost:1%N  3:Medium%N    Health:100, Energy:0, Regen:3/0, Armour:5, Vision:0, Move:0, Move Cost:3%N  4:Heavy%N    Health:200, Energy:0, Regen:4/0, Armour:10, Vision:0, Move:-1, Move Cost:5%N", setup_list.count+1)
			setup_list.force("  1:Standard%N    Health:10, Energy:60, Regen:0/2, Armour:1, Vision:12, Move:8, Move Cost:2%N  2:Light%N    Health:0, Energy:30, Regen:0/1, Armour:0, Vision:15, Move:10, Move Cost:1%N  3:Armoured%N    Health:50, Energy:100, Regen:0/3, Armour:3, Vision:6, Move:4, Move Cost:5%N", setup_list.count+1)
			setup_list.force("  1:Recall (50 energy): Teleport back to spawn.%N  2:Repair (50 energy): Gain 50 health, can go over max health. Health regen will not be in effect if over cap.%N  3:Overcharge (up to 50 health): Gain 2*health spent energy, can go over max energy. Energy regen will not be in effect if over cap.%N  4:Deploy Drones (100 energy): Clear all projectiles.%N  5:Orbital Strike (100 energy): Deal 100 damage to all enemies, affected by armour.%N", setup_list.count+1)
			setup_list.force("", setup_list.count+1)
			cursor:=1
		end

	increment_cursor
		do
			cursor:=cursor+1
		end

	decrement_cursor
		do
			cursor:=cursor-1
		end

invariant
	cursor>=1 and cursor <=5
end
