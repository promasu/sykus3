require 'spec_helper'

require 'services/files/get_file'

module Sykus

  describe Files::GetFile do
    include FakeFS::SpecHelpers

    let (:identity) { IdentityTestGod.new } 
    let (:get_file) { Files::GetFile.new identity }

    let (:mtime) { Time.now.to_i }

    let! (:user) { Factory Users::User, id: 1 }
    let! (:owner) {
      Factory Users::User, full_name: Users::FullUserName.new('John', 'Doe')
    }

    let! (:ug) { 
      Factory Users::UserGroup, id: 1, 
      owner: owner, users: [ user ], name: 'Test Group'
    }
    let! (:ug2) { Factory Users::UserGroup }

    before (:each) { Timecop.freeze }
    after (:each) { Timecop.return }

    before :each do
      identity.user_id = 1

      FileUtils.mkdir_p '/home/users/u1/dir1'
      FileUtils.mkdir_p '/home/groups/.g1/dir1'
      FileUtils.mkdir_p '/home/groups/.g2/dir1'
      FileUtils.mkdir_p '/home/share/admin/dir2'
      FileUtils.mkdir_p '/home/share/teacher/dir3'
      FileUtils.mkdir_p '/home/share/progdata/dir4'

      FileUtils.touch '/home/users/u1/.filehidden'
      FileUtils.touch '/home/users/u1/dir1/file3'
      FileUtils.ln_s 'file3', '/home/users/u1/dir1/link'
      File.open('/home/users/u1/file2', 'w+') do |f|
        f.write 'abc'
      end
      FileUtils.touch '/home/users/u1/File1'
      FileUtils.touch '/home/users/u1/starter.desktop'
      FileUtils.touch '/home/groups/.g1/File2'
    end

    context 'get directory' do
      it 'returns valid directory data (home)' do
        res = get_file.get_dir '/home'
        res.should == [
          { name: 'dir1', dir: true, size: 0, mtime: mtime },
          { name: 'File1', dir: false, size: 0, mtime: mtime },
          { name: 'file2', dir: false, size: 3, mtime: mtime },
        ]
      end

      it 'returns valid directory data (home subdir)' do
        res = get_file.get_dir 'home/dir1'
        res.should == [ { name: 'file3', dir: false, size: 0, mtime: mtime } ]
      end

      it 'returns valid directory data (weird path)' do
        res = get_file.get_dir 'home/../../../home/dir1/../dir2/../dir1'
        res.should == [ { name: 'file3', dir: false, size: 0, mtime: mtime } ]
      end

      it 'returns valid directory data (teacher share)' do
        res = get_file.get_dir 'teacher'
        res.should == [ { name: 'dir3', dir: true, size: 0, mtime: mtime } ]
      end

      it 'returns valid directory data (admin share)' do
        res = get_file.get_dir 'admin'
        res.should == [ { name: 'dir2', dir: true, size: 0, mtime: mtime } ]
      end

      it 'returns valid directory data (progdata)' do
        res = get_file.get_dir 'progdata'
        res.should == [ { name: 'dir4', dir: true, size: 0, mtime: mtime } ]
      end

      it 'returns valid directory data (groups)' do
        res = get_file.get_dir 'groups'
        res.should == [ { 
          name: 'Test Group - John Doe (1)', 
          dir: true, 
          size: 0,
          mtime: 0 
        } ]
      end


      it 'raises if not a directory' do
        expect {
          get_file.get_dir 'home/dir1/file3'
        }.to raise_error Exceptions::Input
      end

      it 'raises on invalid basedir' do
        expect {
          get_file.get_dir 'test/dir'
        }.to raise_error Exceptions::Input
      end

      it 'raises on invalid group' do
        expect {
          get_file.get_dir 'groups/Invalid Group'
        }.to raise_error Exceptions::NotFound
      end

      it 'raises on invalid directory (home)' do
        expect {
          get_file.get_dir 'home/test2'
        }.to raise_error Exceptions::NotFound
      end
    end

    context 'files' do
      it 'gets correct file path' do
        res = get_file.get_file 'home/dir1/file3'

        res.should == '/home/users/u1/dir1/file3'
      end

      it 'gets correct group file' do
        res = get_file.get_file 'groups/Test Group - John Doe (1)/File2'

        res.should == '/home/groups/.g1/File2'
      end

      it 'raises if not a regular file' do
        expect {
          get_file.get_file 'home/dir1'
        }.to raise_error Exceptions::Input
      end

      it 'raises on invalid basedir' do
        expect {
          get_file.get_file 'test/file'
        }.to raise_error Exceptions::Input
      end
    end

    context 'permission violations' do
      it 'raises on permission violation (teacher share)' do
        check_service_permission(:share_teacher_access, Files::GetFile,
                                 :get_dir, 'teacher/dir/')
      end

      it 'raises on permission violation (admin share)' do
        check_service_permission(:share_admin_access, Files::GetFile,
                                 :get_dir, 'admin/dir/')
      end
    end
  end

end

