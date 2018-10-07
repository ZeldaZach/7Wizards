/*
Copyright (c) 2005 JSON.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The Software shall be used for Good, not Evil.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*
ported to Actionscript May 2005 by Trannie Carter <tranniec@designvox.com>, wwww.designvox.com
USAGE:
	try {
		var o:Object = JSON.parse(jsonStr);
		var s:String = JSON.stringify(obj);
	} catch(ex) {
		trace(ex.name + ":" + ex.message + ":" + ex.at + ":" + ex.text);
	}

*/
package com.wizards.services
{
	public class JSON {

	public static function stringify(arg:*):String {

        var c:*;
        var i:*;
        var l:*;
        var s:String = '';
        var v:*;

        switch (typeof arg) {
        case 'object':
            if (arg) {
                if (arg is Array) {
                    for (i = 0; i < arg.length; ++i) {
                        v = stringify(arg[i]);
                        if (s) {
                            s += ',';
                        }
                        s += v;
                    }
                    return '[' + s + ']';
                } else if (typeof arg.toString != 'undefined') {
                    for (i in arg) {
                        v = arg[i];
                        if (typeof v != 'undefined' && typeof v != 'function') {
                            v = stringify(v);
                            if (s) {
                                s += ',';
                            }
                            s += stringify(i) + ':' + v;
                        }
                    }
                    return '{' + s + '}';
                }
            }
            return 'null';
        case 'number':
            return isFinite(arg) ? String(arg) : 'null';
        case 'string':
            l = arg.length;
            s = '"';
            for (i = 0; i < l; i += 1) {
                c = arg.charAt(i);
                if (c >= ' ') {
                    if (c == '\\' || c == '"') {
                        s += '\\';
                    }
                    s += c;
                } else {
                    switch (c) {
                        case '\b':
                            s += '\\b';
                            break;
                        case '\f':
                            s += '\\f';
                            break;
                        case '\n':
                            s += '\\n';
                            break;
                        case '\r':
                            s += '\\r';
                            break;
                        case '\t':
                            s += '\\t';
                            break;
                        default:
                            c = c.charCodeAt();
                            s += '\\u00' + Math.floor(c / 16).toString(16) +
                                (c % 16).toString(16);
                    }
                }
            }
            return s + '"';
        case 'boolean':
            return String(arg);
        default:
            return 'null';
        }
    }

	public static function parse(text:String):Object {
        var at:int = 0;
        var ch:String = ' ';

        var error:Object = function(m:*):Object {
            throw {
                name: 'JSONError',
                message: m,
                at: at - 1,
                text: text
            };
        }

        var next:Function = function():String {
            ch = text.charAt(at);
            at += 1;
            return ch;
        }

        var white:Function = function():void {
            while (ch) {
                if (ch <= ' ') {
                    next();
                } else if (ch == '/') {
                    switch (next()) {
                        case '/':
                            while (next() && ch != '\n' && ch != '\r') {}
                            break;
                        case '*':
                            next();
                            for (;;) {
                                if (ch) {
                                    if (ch == '*') {
                                        if (next() == '/') {
                                            next();
                                            break;
                                        }
                                    } else {
                                        next();
                                    }
                                } else {
                                    error("Unterminated comment");
                                }
                            }
                            break;
                        default:
                             error("Syntax error");
                    }
                } else {
                    break;
                }
            }
        }

        var string:Function = function():* {
            var i:*;
            var s:String = '';
            var t:*;
            var u:*;
			var outer:Boolean = false;

            if (ch == '"') {
				while (next()) {
                    if (ch == '"') {
                         next();
                        return s;
                    } else if (ch == '\\') {
                        switch ( next()) {
                        case 'b':
                            s += '\b';
                            break;
                        case 'f':
                            s += '\f';
                            break;
                        case 'n':
                            s += '\n';
                            break;
                        case 'r':
                            s += '\r';
                            break;
                        case 't':
                            s += '\t';
                            break;
                        case 'u':
                            u = 0;
                            for (i = 0; i < 4; i += 1) {
                                t = parseInt( next(), 16);
                                if (!isFinite(t)) {
                                    outer = true;
									break;
                                }
                                u = u * 16 + t;
                            }
							if(outer) {
								outer = false;
								break;
							}
                            s += String.fromCharCode(u);
                            break;
                        default:
                            s += ch;
                        }
                    } else {
                        s += ch;
                    }
                }
            }
             error("Bad string");
        }

        var array:Function = function():* {
            var a:Array = [];

            if (ch == '[') {
                next();
                white();
                if (ch == ']') {
                    next();
                    return a;
                }
                while (ch) {
                    a.push(value());
                     white();
                    if (ch == ']') {
                         next();
                        return a;
                    } else if (ch != ',') {
                        break;
                    }
                     next();
                     white();
                }
            }
            error("Bad array");
        }

        var object:Function = function():* {
            var k:*;
            var o:* = {};

            if (ch == '{') {
                 next();
                 white();
                if (ch == '}') {
                     next();
                    return o;
                }
                while (ch) {
                    k =  string();
                     white();
                    if (ch != ':') {
                        break;
                    }
                     next();
                    o[k] =  value();
                     white();
                    if (ch == '}') {
                         next();
                        return o;
                    } else if (ch != ',') {
                        break;
                    }
                     next();
                     white();
                }
            }
             error("Bad object");
        }

        var number:Function = function():* {
            var n:* = '';
            var v:*;

            if (ch == '-') {
                n = '-';
                 next();
            }
            while (ch >= '0' && ch <= '9') {
                n += ch;
                 next();
            }
            if (ch == '.') {
                n += '.';
                while ( next() && ch >= '0' && ch <= '9') {
                    n += ch;
                }
            }
            v = +n;
            if (!isFinite(v)) {
                 error("Bad number");
            } else {
                return v;
            }
        }

        var word:Function = function():* {
            switch (ch) {
                case 't':
                    if ( next() == 'r' &&  next() == 'u' &&  next() == 'e') {
                         next();
                        return true;
                    }
                    break;
                case 'f':
                    if ( next() == 'a' &&  next() == 'l' &&  next() == 's' &&
                             next() == 'e') {
                         next();
                        return false;
                    }
                    break;
                case 'n':
                    if ( next() == 'u' &&  next() == 'l' &&  next() == 'l') {
                         next();
                        return null;
                    }
                    break;
            }
             error("Syntax error");
        }

        var value:Function = function():* {
             white();
            switch (ch) {
                case '{':
                    return  object();
                case '[':
                    return  array();
                case '"':
                    return  string();
                case '-':
                    return  number();
                default:
                    return ch >= '0' && ch <= '9' ?  number() :  word();
            }
        }

        return value();
    }
}
}