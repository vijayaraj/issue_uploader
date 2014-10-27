require "import_export_methods.rb"

class IssuesController < ApplicationController
	skip_before_filter :verify_authenticity_token

	include ImportExportMethods

	def index
		@issues = Issue.paginate :page => params[:page], :per_page => 15
	end

	def import
		if params[:CSV].present? and (params[:github] or params[:gitlab])
			Thread.new { 
				import_issues(params[:CSV], params) 
			}
			flash[:notice] = "Import has succesfully started. You will be notified via mail when the import is done."
		else
			unless params[:CSV]
				flash[:error] = "Pleae choose a CSV file to import."
			else
				flash[:error] = "Please select one of the checkboxes to import."
			end
		end

		
		redirect_to issues_path
	end

	def export
		if Issue.all.count > 0
			Thread.new { export_issues }
			flash[:notice] = "Export has succesfully started. You will be notified via mail when the export is done."
		else
			flash[:error] = "Sorry, there are no issues to export."
		end

		redirect_to issues_path
	end

end
