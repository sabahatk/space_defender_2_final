note
	description: "Summary description for {FOCUS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FOCUS
	inherit
		COMPOSITE_SCORE
			redefine
				value
			end

create make_type

feature --make command

	make_type(type: CHARACTER)
		require
			type = 'P' or type = 'D'
		do
			score_type:=type
			if score_type = 'P' then
				capacity:= 3
				multiplier:= 2
			elseif score_type = 'D' then
				capacity:=4
				multiplier:=3
			end
			create children.make
		end

feature -- Attributes
	capacity, multiplier, capacity_counter, cursor: INTEGER

feature -- value query

	value:INTEGER
		do
			from
				children.start
			until
				children.exhausted
			loop
				Result:=Result + children.item.value
				children.forth
			end
			if Current.is_full then
				Result := Result * multiplier
			end
		end

feature -- boolean queries

	is_full: BOOLEAN
		do
			if capacity = children.count then
				Result:=True
			else
				Result:=False
			end
		ensure
			Result implies capacity = children.count
		end

invariant
	children.count <= capacity
end
