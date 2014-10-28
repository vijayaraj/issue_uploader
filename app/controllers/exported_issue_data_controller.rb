class ExportedIssueDataController < ApplicationController
  
  def index
    @exported_data = ExportedIssueData.paginate :page => params[:page], :per_page => 30
  end

end