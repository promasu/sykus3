define([
  '../config',
  'dojo/i18n!./nls/dateDiff'
], 
function (
  config, iDateDiff
) {

  function format(diff, nlsMultiple, nlsOne) {
    diff = Math.round(diff);

    if (diff < 2) {
      return iDateDiff.prefix + ' ' + nlsOne;
    }

    return iDateDiff.prefix + ' ' + nlsMultiple.replace(/%d/, diff);
  }

  return function (timestamp) {
    var diff = config.get('servertime') - timestamp;

    if (diff < 60) {
      return format(diff, iDateDiff.seconds, iDateDiff.oneSecond);
    }
    diff /= 60;

    if (diff < 60) {
      return format(diff, iDateDiff.minutes, iDateDiff.oneMinute);
    }
    diff /= 60;

    if (diff < 24) {
      return format(diff, iDateDiff.hours, iDateDiff.oneHour);
    }
    diff /= 24;

    if (diff < 30) {
      return format(diff, iDateDiff.days, iDateDiff.oneDay);
    }
    diff /= 30;

    if (diff < 12) {
      return format(diff, iDateDiff.months, iDateDiff.oneMonth);
    }
    diff /= 12;

    if (diff < 10) {
      return format(diff, iDateDiff.years, iDateDiff.oneYear);
    }

    return iDateDiff.never;
  };

});

