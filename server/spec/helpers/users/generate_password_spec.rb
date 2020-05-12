require 'spec_helper'

module Sykus

  describe Users::GeneratePassword do
    let (:user) { Factory Users::User }

    context 'random passwords' do
      it 'generates a valid password' do
        pass = Users::GeneratePassword.run(user)
        pass.should be_a String
        pass.should =~ /^[a-z]{3}[0-9][a-z]{3}$/
      end

      it 'should generate random passwords' do
        pass1 = Users::GeneratePassword.run(user)
        pass2 = Users::GeneratePassword.run(user)

        pass1.should_not == pass2
      end
    end
  end

end

