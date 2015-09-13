var page = require('webpage').create();
var system = require('system');

if (system.args.length === 1) {
  console.log('Usage: uptime.js <some URL>');
  phantom.exit(1);
} else {
  var t = Date.now();
  var address = system.args[1];

  page.onError = function (msg, trace) {
    //console.error(msg);
    trace.forEach(function(item) {
      //console.error('  ', item.file, ':', item.line);
    });
  };

  page.open(address, function (status) {
    if (status !== 'success') {
      console.log('FAIL to load the address');
    } else {
      t = Date.now() - t;
      console.log('Page title is ' + page.evaluate(function () {
        return document.title;
      }));
      console.log('Loading time ' + t + ' msec');
    }
    phantom.exit();
  });
}
