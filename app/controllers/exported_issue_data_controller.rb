class ExportedIssueDataController < ApplicationController
  
  # lists previously exported data 
  def index
    @exported_data = ExportedIssueData.paginate :page => params[:page], :per_page => 30
  end

end