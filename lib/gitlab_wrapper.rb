class GitlabWrapper

  # Wrapper to gitlab gem.
  # Uses create and get GitHub API.
  # Authorization using end_point and private_token.

  def create_issue(issue)
    gitlab.create_issue(scoper.gitlab_project_id, issue[:title], issue_params(issue))
  end

  def get_issue(gitlab_id)
    gitlab.issue(scoper.gitlab_project_id, gitlab_id)
  end

  def edit_issue(gitlab_id, issue)
    gitlab.edit_issue(scoper.gitlab_project_id, gitlab_id, issue_params(issue))
  end

  private
    def gitlab
      @gitlab ||= Gitlab.client(auth_data)
    end

    def auth_data
      {
        :endpoint => scoper.gitlab_endpoint,
        :private_token => scoper.gitlab_private_token
      }
    end

    def issue_params(issue)
      {
        :description => issue[:description],
        :labels => issue[:labels].join(','),
        :milestone => issue[:milestone]
      }
    end

    def scoper
      AccountConfiguration.first
    end


end