
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

JSORB.Client = function (base_url) {
    this.base_url = base_url;
}

JSORB.Client.prototype.new_request = function (p) {
    return new JSORB.Client.Request(p); 
}

JSORB.Client.prototype.call = function (request, callback, error_handler) {
    if (error_handler == undefined) {
        error_handler = function (e) { alert(e) };
    }
    if (typeof request == 'object' && request.constructor != JSORB.Client.Request) {
        request = this.new_request(request);
    }
    JQuery.get(
        request.as_url(this.base_url),
        function (data) {
            var resp = new JSORB.Client.Response(data);
            if (resp.is_error()) {
                error_handler(resp.error);
            }
            else {
                callback(resp.result);                
            }
        }
    );    
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
        ('id='     + escape(this.id)),
        ('method=' + escape(this.method)),    
    ];
    if (this.params) {
        params[params.length] = ('params='  + escape(JSON.stringify(this.params)));        
    }
    return (base_url == undefined ? '' : base_url) + '?' + params.join('&');
}

JSORB.Client.Request.prototype.as_json = function () {
    return JSON.stringify({
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
    this.id     = p['id'];    
    this.result = p['result'] || null;
    this.error  = p['error']  || null;
}

JSORB.Client.Response.prototype.is_error = function () { return this.error != null }

JSORB.Client.Response.prototype.as_json = function () {
    return JSON.stringify({
        id     : this.id,
        result : this.result,
        error  : this.error
    });
}




