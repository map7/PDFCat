# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	include ShortcutsHelper

	# Generate shortcuts for next or previous page
	def shortcut_next_or_prev(main_pages)

		# Calculate current, next and prev page numbers for use in shortcut keys
		if params[:page]
			@page = params[:page].to_i
		else
			@page = 1;
		end

		if main_pages.current.next
			@nextpage = @page +1
		else
			@nextpage = @page
		end

		if main_pages.current.previous
			@prevpage = @page -1
		else
			@prevpage = @page
		end
				
		# Return these lines back to the view
		"#{shortcut 'p', BASE_URL + '/' + controller.controller_name + '?page=' + @prevpage.to_s }
		#{shortcut 'n', BASE_URL + '/' + controller.controller_name + '?page=' + @nextpage.to_s }"
				
	end
end
