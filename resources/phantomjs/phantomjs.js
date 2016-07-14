var page = require('webpage').create();
var hasError = false;

page.onConsoleMessage = function(msg) {
    console.log(msg);
};

page.onError = function(msg, trace) {
    hasError = true;
    var msgStack = ['ERROR: ' + msg];
    if (trace && trace.length) {
        msgStack.push('TRACE:');
        trace.forEach(function(t) {
            msgStack.push(' -> ' + t.file + ': ' + t.line + (t.function ? ' (in function "' + t.function +'")' : ''));
        });
    }
    console.error(msgStack.join('\n'));
    phantom.exit(-1);
};

page.onResourceError = function(resourceError) {
    hasError = true;
    console.error('Unable to load resource (#' + resourceError.id + 'URL:' + resourceError.url + ')');
    console.error('Error code: ' + resourceError.errorCode + '. Description: ' + resourceError.errorString);
    phantom.exit(-1);
};

page.onClosing = function(closingPage) {
    phantom.exit(hasError ? -2 : 0);
};

page.open('::html::', function(status) {
    var success = status === 'success' && !hasError;
    if(!success) {
        phantom.exit(-1);
    }
});