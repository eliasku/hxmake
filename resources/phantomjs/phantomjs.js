var page = require('webpage').create();
var hasError = false;

page.onConsoleMessage = function(msg) {
    checkExitSignal(msg);
    console.log(msg);
};

function checkExitSignal(sig) {
    var cmd = "<hxmake::exit>";
    var index = sig.indexOf(cmd);
    if(index >= 0) {
        var exitCode = parseInt(sig.substr(index + cmd.length));
        phantom.exit(exitCode);
    }
}

page.onError = function(msg, trace) {
    console.log('onError');
    hasError = true;
    var msgStack = ['ERROR: ' + msg];
    if (trace && trace.length) {
        msgStack.push('TRACE:');
        trace.forEach(function(t) {
            msgStack.push(' -> ' + t.file + ': ' + t.line + (t.function ? ' (in function "' + t.function +'")' : ''));
        });
    }
    console.error(msgStack.join('\n'));
};

page.onResourceError = function(resourceError) {
    hasError = true;
    console.log('onResourceError');
    console.error('Unable to load resource (#' + resourceError.id + 'URL:' + resourceError.url + ')');
    console.error('Error code: ' + resourceError.errorCode + '. Description: ' + resourceError.errorString);
};

page.open('http://localhost:2000/phantomjs.html', function(status) {
    var success = status === 'success' && !hasError;
    console.log('status: ' + status);
    console.log('errors: ' + hasError);

    if(!success) {
        phantom.exit(-1);
    }
});


page.onResourceRequested = function (request) {
    system.stderr.writeLine('= onResourceRequested()');
    system.stderr.writeLine('  request: ' + JSON.stringify(request, undefined, 4));
};

page.onResourceReceived = function(response) {
    system.stderr.writeLine('= onResourceReceived()' );
    system.stderr.writeLine('  id: ' + response.id + ', stage: "' + response.stage + '", response: ' + JSON.stringify(response));
};

page.onLoadStarted = function() {
    system.stderr.writeLine('= onLoadStarted()');
    var currentUrl = page.evaluate(function() {
        return window.location.href;
    });
    system.stderr.writeLine('  leaving url: ' + currentUrl);
};

page.onLoadFinished = function(status) {
    system.stderr.writeLine('= onLoadFinished()');
    system.stderr.writeLine('  status: ' + status);
};

page.onNavigationRequested = function(url, type, willNavigate, main) {
    system.stderr.writeLine('= onNavigationRequested');
    system.stderr.writeLine('  destination_url: ' + url);
    system.stderr.writeLine('  type (cause): ' + type);
    system.stderr.writeLine('  will navigate: ' + willNavigate);
    system.stderr.writeLine('  from page\'s main frame: ' + main);
};
