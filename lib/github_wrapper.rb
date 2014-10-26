class GithubWrapper

  def create_issue(issue)
    github_issue.create(issue_params(issue))
  end

  def list_issues
    github_issue.list(auth_data)
  end

  def get_issue(github_id)
    github_issue.get(auth_data.merge(:number => github_id))
  end

  private
    def github_issue
      Github.new.issues(auth_data)
    end

    def auth_data
      {
        :oauth_token => scoper.github_token,
        :user => scoper.github_user_name,
        :repo => scoper.github_repository,
      }
    end

    def issue_params(issue)
      {
        :title => issue[:title],
        :body => issue[:description],
        :labels => issue[:labels],
        :milestone => issue[:milestone]
      }
    end

    def scoper
      AccountConfiguration.first
    end


end