require 'spec_helper'


module Sykus

  describe ServiceBase do
    class TestService < ServiceBase; end

    class TestService2 < ServiceBase
      def action(id, obj)
        { id: id * 2, password: 'foo' }
      end
    end

    class MyStubEntity < StubEntity
      def a; 12; end
      def b; 24; end
      def c; 3; end
      def d; 5; end
    end

    let (:permission_test) { Config::Permissions::PermissionList.first }
    let (:entity) { MyStubEntity.new }
    let (:identity) { IdentityTestGod.new }
    subject { TestService.new identity }

    context 'initialization' do
      it 'requires a Identity' do
        TestService.new IdentityAnonymous.new
      end

      it 'raises if argument is not a valid Identity' do
        expect {
          TestService.new {}
        }.to raise_error
      end
    end

    context '#run' do
      it 'logs calls to #run and passes call on to #action' do
        s2 = TestService2.new identity
        res = s2.run 42, { name: 'test', password: 'bla', session: 42 }

        res[:id].should == 84

        Logs::ServiceLog.all.count.should == 1
        log = Logs::ServiceLog.first
        log.service.should == 'TestService2'
        log.input.should == '[42,{"name":"test"}]'
        log.output.should == '{"id":84}'
        log.username.should == 'Testing Identity' 
      end
    end

    context '#enforce_permission!' do
      it 'raises if permission is not present' do
        expect {
          ts = TestService.new IdentityAnonymous.new
          ts.enforce_permission! permission_test
        }.to raise_error Exceptions::Permission
      end

      it 'does nothing if permission is present' do
        subject.enforce_permission! permission_test
      end
    end

    context '#action' do
      it 'is an abstract method' do
        expect {
          ts = TestService.new IdentityAnonymous.new
          ts.action
        }.to raise_error
      end
    end

    context '#validate_entity!' do
      it 'validates an entity instance positively' do
        entity.valid = true
        subject.validate_entity! entity
      end

      it 'validates an entity instance and raises' do
        entity.valid = false
        expect {
          subject.validate_entity! entity
        }.to raise_error Exceptions::Input
      end
    end

    context '#select_args' do
      it 'selects proper arguments' do
        args = { a: 12, b: 24, c: 3, d: 5 }
        res = subject.select_args(args, [ :a, :d ])
        res.should == { a: 12, d: 5 }
      end
    end

    context '#select_entity_props' do
      it 'selects proper properties' do
        res = subject.select_entity_props(entity, [ :a, :d ])
        res.should == { a: 12, d: 5 }
      end
    end
  end

end

