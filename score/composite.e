note
	description: "Summary description for {COMPOSITE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	COMPOSITE[G]

feature
	children: LINKED_LIST[G]

	add(c:G)
		do
			children.extend(c)
		end

end
