note
	description: "Summary description for {COMPOSITE_SCORE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	COMPOSITE_SCORE
		inherit
			SCORE_ITEM
			COMPOSITE[SCORE_ITEM]
			redefine
				add
			end

create
	make

feature -- make
	make
		do
			create children.make
		end

--feature -- Attributes
--	children: LINKED_LIST[SCORE_ITEM]

feature -- score add up

	value: INTEGER
		do
			across
				children is c
			loop
				Result:=Result+c.value
			end
		end

	add(score_drop: SCORE_ITEM)
		local
			b:BOOLEAN
		do
			b:=check_focus(Current.children, score_drop)
			if b = False then
				children.extend (score_drop)
			end
		end


	check_focus(child: LINKED_LIST[SCORE_ITEM]; s: SCORE_ITEM): BOOLEAN
		do
			across
				child is c
			loop
				if c.score_type = 'P' or c.score_type = 'D' then
					check attached {FOCUS} c as l_f then
						if l_f.is_full then
							Result:=check_focus(l_f.children,s)
						else
							l_f.children.extend(s)
							Result:=True
						end
					end
				end
			end
		end



end
