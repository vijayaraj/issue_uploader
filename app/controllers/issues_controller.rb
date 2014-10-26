require "import_export_methods.rb"

class IssuesController < ApplicationController
	skip_before_filter :verify_authenticity_token

	include ImportExportMethods

	def index
		@issues = Issue.paginate :page => params[:page], :per_page => 15
	end

	def import
		if params[:CSV].present?
			Thread.new { 
				import_issues(params[:CSV], params) 
			}
		end

		flash[:notice] = "Import has succesfully started. You will be notified via mail when the import is done."
		redirect_to issues_path
	end

	def export
		if Issue.all.count > 0
			Thread.new { export_issues }
		end

		flash[:notice] = "Export has succesfully started. You will be notified via mail when the export is done."
		redirect_to issues_path
	end

end
