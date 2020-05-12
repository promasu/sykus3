define([
  'dojo/_base/lang',
  'dojo/router',
  './module',

  './session/Login',
  './session/LoginWithUsername',
  './session/ChangePassword',
  './session/Logout',

  './dashboard/Main',
  './dashboard/Remote',

  './teacher/RoomCtl',
  './teacher/StudentPwd',

  './files/View',
  
  './admin/config/Main',

  './admin/users/UserList',
  './admin/users/UserCreate',
  './admin/users/UserUpdate',
  './admin/users/UserClasses',
  './admin/users/UserGroupList',
  './admin/users/UserGroupCreate',
  './admin/users/UserGroupUpdate',
  './admin/users/UserImport',
  './admin/users/InitialPasswords',

  './admin/hosts/HostList',
  './admin/hosts/HostGroups',
  './admin/hosts/Packages',

  './admin/webfilter/Categories',
  './admin/webfilter/EntryList',
  './admin/webfilter/EntryCreate',

  './admin/printers/PrinterList',
  './admin/printers/PrinterCreate',
  './admin/printers/PrinterUpdate',

  './admin/logs/SessionLogs',
  './admin/logs/ServiceLogs',

  './cli/Start',
  './cli/HostNotReady',
  './cli/Auth'
], 
function (
  lang, router, module, 

  mLogin, mLoginWithUsername, mChangePassword, mLogout, 
  mDashboardMain, mDashboardRemote,
  mTeacherRoomCtl, mTeacherStudentPwd,
  mFilesView, mCalendarMonthView,
  mConfigMain,
  mUserList, mUserCreate, mUserUpdate, mUserClasses, 
  mUserGroupList, mUserGroupCreate, mUserGroupUpdate, mUserImport,
  mInitialPasswords,
  mHostList, mHostGroups, mPackages, 
  mWebfilterCategories, mWebfilterEntryList, mWebfilterEntryCreate,
  mPrinterList, mPrinterCreate,
  mPrinterUpdate, mSessionLogs, mServiceLogs,
  mCliStart, mCliHostNotReady, mCliAuth
) {
  /**
  * Route definitions for all modules.
  * @class routes
  * @module root
  * @static
  * */

  function register(path, moduleClass) {
    router.register(path, lang.partial(module.load, moduleClass, null));
    router.register(path + '!*args', function (params) {
      module.load(moduleClass, params.params.args);
    });
  }

  register('session/Login', mLogin);
  register('session/LoginWithUsername', mLoginWithUsername);
  register('session/ChangePassword', mChangePassword);
  register('session/Logout', mLogout);

  register('dashboard', mDashboardMain);
  register('dashboard/Remote', mDashboardRemote);

  register('teacher/RoomCtl', mTeacherRoomCtl);
  register('teacher/StudentPwd', mTeacherStudentPwd);
  register('teacher/UserGroupList', mUserGroupList);
  register('teacher/UserGroupCreate', mUserGroupCreate);
  register('teacher/UserGroupUpdate', mUserGroupUpdate);

  register('files/View', mFilesView);
  
  register('admin/config/Main', mConfigMain);

  register('admin/users/UserList', mUserList);
  register('admin/users/UserCreate', mUserCreate);
  register('admin/users/UserUpdate', mUserUpdate);
  register('admin/users/UserClasses', mUserClasses);
  register('admin/users/UserGroupList', mUserGroupList);
  register('admin/users/UserGroupCreate', mUserGroupCreate);
  register('admin/users/UserGroupUpdate', mUserGroupUpdate);
  register('admin/users/UserImport', mUserImport);
  register('admin/users/InitialPasswords', mInitialPasswords);

  register('admin/hosts/HostList', mHostList);
  register('admin/hosts/HostGroups', mHostGroups);
  register('admin/hosts/Packages', mPackages);

  register('admin/webfilter/Categories', mWebfilterCategories);
  register('admin/webfilter/EntryList', mWebfilterEntryList);
  register('admin/webfilter/EntryCreate', mWebfilterEntryCreate);

  register('admin/printers/PrinterList', mPrinterList);
  register('admin/printers/PrinterCreate', mPrinterCreate);
  register('admin/printers/PrinterUpdate', mPrinterUpdate);

  register('admin/logs/SessionLogs', mSessionLogs);
  register('admin/logs/ServiceLogs', mServiceLogs);

  register('cli/Start', mCliStart);
  register('cli/HostNotReady', mCliHostNotReady);
  register('cli/Auth', mCliAuth);
});

