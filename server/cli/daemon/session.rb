module Session
  USER_FILE = '/var/lib/sykus3/user.json'

  class << self
    attr_reader :user, :session_id
  end

  def self.init
    data = JSON.parse File.read(USER_FILE), symbolize_names: true
    @user = data[:user]
    @session_id = data[:session_id]
  rescue Exception
  end

  def self.destroy
    FileUtils.rm_f USER_FILE
    @user = nil
    @session_id = nil
  end

  def self.is_student?
    @user[:position_group] == 'student'
  end

  def self.localuser?
    @user[:username] == 'localuser'
  end

end

