require 'spec_helper'


module Sykus

  describe Users::CheckSystemUser do
    context 'with johndoe' do
      it 'does nothing' do
        Users::CheckSystemUser.enforce! 'johndoe'
      end
    end

    context 'with system users' do
      %w{root bin sys sykusadmin localuser}.each do |name|
        it "raises with #{name}" do
          expect {
            Users::CheckSystemUser.enforce! name
          }.to raise_error Exceptions::Input
        end
      end
    end
  end

end

