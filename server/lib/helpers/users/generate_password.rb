module Sykus; module Users

  # Generates default passwords for users.
  module GeneratePassword
    # Character alphabet used to generate the alpha-part of passwords.
    # Omits some characters that look alike: ilj
    ALPHABET = 'abcdefghkmnopqrstuvxyz'.split('')

    # Output format: abc3xyz
    # @param [User] user User instance.
    # @return [String] Password.
    def self.run(user)
      password = ''
      7.times do
        password << ALPHABET[SecureRandom.random_number(ALPHABET.size)] 
      end
      password[3] = SecureRandom.random_number(10).to_s

      password
    end
  end

end; end

