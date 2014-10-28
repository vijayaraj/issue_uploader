class PopulateAccountConfigurations < ActiveRecord::Migration

  def change
    github_data = {
      :client_id => "592cb37dff25131d7719",
      :client_secret => "b080c30acf44341026fdac0dbd4906b24925f5ea",
      :token => "8c4b0db9dbaf085f4618ec305f16cdb55cd7c213",
      :user => "vijayarajm",
      :repo => "test_repo"
    }
    gitlab_data = {
      :endpoint => "https://gitlab.com/api/v3",
      :private_token => "Po5HpzV2zfjcKYUUg1UK",
      :project_id => "108628"
    }
    AccountConfiguration.create(:github => github_data, :gitlab => gitlab_data, 
      :notification_email => "", :import_progress => false, :export_progress => false)
  end

end
