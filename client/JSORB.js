/*

JSORB.js

This requires the standard JSON
library, which can be found here:

http://www.json.org/json2.js

And a copy of the JQuery library
which can be found here:

http://jqueryjs.googlecode.com/files/jquery-1.2.6.js

*/

var JSORB        = function () {}

JSORB.Client = function (base_url, ajax_options) {
    this.base_url     = base_url;
    // NOTE:
    // Supported options can be found
    // here:
    //     http://docs.jquery.com/Ajax/jQuery.ajax
    // we force a few options for sanity
    // such as dataType == json and
    // we provide an error and success
    // handler, otherwise it is all up
    // to you.
    // - SL
    this.ajax_options = ajax_options || {};
}

JSORB.Client.prototype.new_request = function (p) {
    return new JSORB.Client.Request(p);
}

JSORB.Client.prototype.call = function (request, callback, error_handler) {
    if (error_handler == undefined) {
        error_handler = function (e) { alert(JSON.stringify(e)) };
    }
    if (typeof request == 'object' && request.constructor != JSORB.Client.Request) {
        request = this.new_request(request);
    }

    // clone our global options
    var options = {};
    for (var k in this.ajax_options) {
        option[k] = this.ajax_options[k];
    }

    options.url      = request.as_url(this.base_url);
    options.dataType = 'json';

    options.error    = function (request, status, error) {
        var resp;
        if (error) {
            // this is for exceptions that happen
            // during processing of the AJAX request
            // so we can turn this into an actual
            // JSORB response with an error for
            // the sake of consistency
            resp = new JSORB.Client.Response({
                'error' : new JSORB.Client.Error({
                    'error'   : error,
                    'message' : error.description,
                })
            });
        }
        else {
            resp = new JSORB.Client.Response(request.responseText);
        }
        error_handler(resp.error)
    };

    options.success  = function (data, status) {
        var resp = new JSORB.Client.Response(data);
        if (resp.is_error()) {
            error_handler(resp.error);
        }
        else {
            callback(resp.result);
        }
    };

    jQuery.ajax(options);
}

// Request

JSORB.Client.Request = function (p) {
    if (typeof p == 'string') {
        p = JSON.parse(p);
    }
    // FIXME:
    // This should probably check
    // for bad input here, and
    // throw an exception - SL
    this.id     = p['id'] || null;
    this.method = p['method'];
    this.params = p['params'] && typeof p['params'] == 'string'
                    ? JSON.parse(p['params'])
                    : p['params'];
}

JSORB.Client.Request.prototype.is_notification = function () { return this.id == null }

JSORB.Client.Request.prototype.as_url = function (base_url) {
    var params = [
        ('jsonrpc=2.0'),
        ('id='     + escape(this.id)),
        ('method=' + escape(this.method))
    ];
    if (this.params) {
        params[params.length] = ('params='  + escape(JSON.stringify(this.params)));
    }
    return (base_url == undefined ? '' : base_url) + '?' + params.join('&');
}

JSORB.Client.Request.prototype.as_json = function () {
    return JSON.stringify({
        jsonrpc : '2.0',
        id      : this.id,
        method  : this.method,
        params  : this.params
    });
}

// Response

JSORB.Client.Response = function (p) {
    if (typeof p == 'string') {
        p = JSON.parse(p);
    }
    // FIXME:
    // This should probably check
    // for bad input here, and
    // throw an exception - SL
    this.id     = p['id']     || null;
    this.result = p['result'] || null;
    this.error  = p['error'] ? new JSORB.Client.Error(p['error']) : null;
}

JSORB.Client.Response.prototype.is_error = function () { return this.error != null }

JSORB.Client.Response.prototype.as_json = function () {
    return JSON.stringify({
        id     : this.id,
        result : this.result,
        error  : this.error
    });
}

// Simple error object 

JSORB.Client.Error = function (options) {
    this.code    = options['code']    || 1;
    this.message = options['message'] || "An error has occured";
    this.data    = options['data']    || {};        
}


/*

BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

AUTHOR

Stevan Little <stevan.little@iinteractive.com>

COPYRIGHT AND LICENSE

Copyright 2008 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

*/

