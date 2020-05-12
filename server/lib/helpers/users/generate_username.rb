module Sykus; module Users

  # Generates usernames.
  module GenerateUsername
    # Generates a username, taking already used usernames into consideration.
    # @param [FullUserName] name Full user name.
    # @return [String] Username.
    def self.run(name, ref_id = nil)
      raise unless name.is_a? FullUserName
      name.validate!

      basename = normalize(name.last_name)[0..7] + 
        normalize(name.first_name)[0..3]

      # keep old username (if present), but only
      # if new full name yields a new basename
      ref_user = User.get(ref_id)
      if ref_user && ref_user.username.gsub(/\d*/, '') == basename
        return ref_user.username
      end

      username = basename
      num = 1
      while User.first(:username => username) do
        username = basename + num.to_s
        num += 1
      end

      username
    end

    private 
    def self.normalize(str)
      NormalizeString.run(str).gsub(/[^a-z]/, '')
    end
  end

end; end

