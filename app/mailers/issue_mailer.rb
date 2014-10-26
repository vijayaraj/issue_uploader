class IssueMailer < ActionMailer::Base
  default from: "notification@issueuploader.com"

  def notify_user_on_import
    mail :to => "vraj.mdu@gmail.com", :subject => "Issue uploader - Your import is complete!"
  end
  
  def send_exported_data
    attachments['issues.csv'] = File.read('issues.csv')
    mail :to => "vraj.mdu@gmail.com", :subject => "Issue uploader - Your export is complete!"    
  end


end
