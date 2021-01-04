note
	description: "Summary description for {PARENT_PROJ_HELPER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	PARENT_PROJ_HELPER

feature -- make
	model: GAME

	make
		local
			ga: GAME_ACCESS
		do
			model:=ga.m
		end

feature --Commands

	add_proj (proj: PROJ_ENTITY) deferred end

	remove_proj (proj: PROJ_ENTITY) deferred end

	delete_out_of_board_proj deferred end

end
