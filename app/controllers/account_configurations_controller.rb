class AccountConfigurationsController < ApplicationController

  def edit
    @github = scoper.github
    @gitlab = scoper.gitlab
    @notification_email = scoper.notification_email
  end

  def update
    gitlab = gitlab_auth_data
    if scoper.update_attributes(:gitlab => gitlab, :notification_email => params[:notification_email])
      flash[:notice] = "Settings updated successfully."
    else
      flash[:error] = "There was a problem updating the settings."
    end
    redirect_to settings_path
  end

  # github
  def authorize
    github = Github.new client_id: params[:client_id], client_secret: params[:client_secret]
    scoper.update_attributes(:github => github_auth_data)
    
    address = github.authorize_url redirect_uri: @host+'callback', scope: 'repo'
    redirect_to address
  end

  def callback
    authorization_code = params[:code]
    github = Github.new client_id: scoper.github[:client_id], 
              client_secret: scoper.github[:client_secret]
    
    access_token = github.get_token authorization_code
    data = (scoper.github).merge({:token => access_token.token})
    scoper.update_attributes(:github => data)

    flash[:notice] = "Github settings updated succesfully"
    redirect_to settings_path
  end

  private
    def github
      @github ||= Github.new client_id: @client_id, client_secret: @client_secret
    end

    def scoper
      AccountConfiguration.first || AccountConfiguration.create
    end

    def github_auth_data
      {
        :client_id => params[:client_id],
        :client_secret => params[:client_secret],
        :user => params[:user],
        :repo => params[:repo]
      }
    end

    def gitlab_auth_data
      {
        :endpoint => params[:endpoint],
        :private_token => params[:private_token],
        :project_id => params[:project_id]
      }
    end

    def host
      @host ||= request.host
    end
end