require "import_export_methods.rb"

class IssuesController < ApplicationController
	include ImportExportMethods
	
	skip_before_filter :verify_authenticity_token
	before_filter :check_for_valid_input, :validate_csv, :check_for_import_progress, :only => :import
	before_filter :check_for_export_progress, :only => :export
  before_filter :load_account_configuration

  # Lists all issues that were imported before.
	def index
		@issues = Issue.paginate :page => params[:page], :per_page => 20
		@exported_data_count = ExportedIssueData.all.count
		@last_downloaded = @exported_data_count > 0 ? ExportedIssueData.last.created_at : "-"		
	end

  # Imports issues. 
  # Runs in a background thread. 
  # Sends an email when import is done.
	def import
		Thread.new { 
			import_issues(params[:CSV], params, host) 
		}
		flash[:notice] = %(Import has succesfully started. You will be notified via email to 
      #{@account_configuration.notification_email} when the import is done.)
		redirect_to issues_path
	end

  # Exports issues. 
  # Runs in a background thread. 
  # Sends an email with exported file as attachment, when export is done.
	def export
		if Issue.all.count > 0
			Thread.new { export_issues }
			flash[:notice] = %(Export has succesfully started. The exported issues will be sent as attachment 
        via email to #{@account_configuration.notification_email} when the export is done.)
		else
			flash[:error] = "Sorry, there are no issues to export."
		end

		redirect_to issues_path
	end

  # Downloads exported data in the browser.
	def download
    send_data download_exported_data, :filename => 'issues.csv'
  end

  private
  	def host
  		@host ||= request.base_url
  	end

    # Backend validations for import
  	def check_for_valid_input
  		unless (params[:github] or params[:gitlab])
  			flash[:error] = "Please select one of the checkboxes to import."
  			redirect_to issues_path
  		end
  		unless params[:CSV]
				flash[:error] = "Please choose a CSV file to import."
				redirect_to issues_path
			end
  	end

    # Checks if the given file is a valid CSV file and if it is in the right format.
  	def validate_csv
  		headers = CSV.foreach(params[:CSV].path).first
  		unless headers.include?('Issue: Issue Number')
				flash[:error] = "The format of the CSV file you tried importing is invalid."
				redirect_to issues_path
			end
  	end

    # Not more than one import or export can run in the same time. 
    # Avoids data duplication and faster execution.
  	def check_for_import_progress
  		if AccountConfiguration.first.import_progress
				flash[:error] = "An import is under progress. Please wait.."
				redirect_to issues_path
			end
  	end

  	def check_for_export_progress
  		if AccountConfiguration.first.export_progress
				flash[:error] = "An export is under progress. Please wait.."
				redirect_to issues_path
			end
  	end

    def load_account_configuration
      @account_configuration = AccountConfiguration.first
    end
end
