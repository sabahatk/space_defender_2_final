note
	description: "Summary description for {ORBMENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ORBMENT
	inherit
		SCORE_ITEM

create make

feature -- make command

	make(type: CHARACTER)
		require
			type = 'B' or type = 'S' or type = 'G'
		do
			score_type:= type
		end

feature -- value query		

	value: INTEGER
		do
			if score_type = 'B' then
				Result:= 1
			elseif score_type = 'S' then
				Result := 2
			elseif score_type = 'G' then
				Result := 3
			end
		end

end
