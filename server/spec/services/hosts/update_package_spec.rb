require 'spec_helper'

require 'services/hosts/update_package'

module Sykus

  describe Hosts::UpdatePackage do
    let (:identity) { IdentityTestGod.new } 
    let (:update_package) { Hosts::UpdatePackage.new identity } 

    let (:selected) { true }
    let (:package) { Factory Hosts::Package, selected: selected }
    let (:id) { package.id }

    context 'unselect' do
      let (:selected) { true }
      it 'works' do
        update_package.run(id, {
          selected: false,
        })

        ref = Hosts::Package.get id
        ref.selected.should be_false

        check_entity_evt(EntitySet.new(Hosts::Package), id, false)
      end
    end

    context 'select' do
      let (:selected) { false }
      it 'works' do
        update_package.run(id, {
          selected: true,
        })

        ref = Hosts::Package.get id
        ref.selected.should be_true

        check_entity_evt(EntitySet.new(Hosts::Package), id, false)
      end
    end

    it 'works with empty data' do
      ref = Hosts::Package.get(id).to_json
      update_package.run id, {}
      Hosts::Package.get(id).to_json.should == ref
    end

    context 'errors' do
      it '#run raises on permission violations' do
        check_service_permission(:packages_write, 
                                 Hosts::UpdatePackage, :run, 4200, {})
      end

      it '#run raises on invalid id' do
        expect {
          update_package.run(4200, {})
        }.to raise_error Exceptions::NotFound
      end
    end
  end

end

