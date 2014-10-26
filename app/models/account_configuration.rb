class AccountConfiguration < ActiveRecord::Base
  serialize :github, Hash
  serialize :gitlab, Hash

  def github_token
    github[:token]
  end

  def github_user_name
    github[:user]
  end

  def github_repository
    github[:repo]
  end

  def gitlab_endpoint
    gitlab[:endpoint]
  end

  def gitlab_private_token
    gitlab[:private_token]
  end

  def gitlab_project_id
    gitlab[:project_id]
  end

end