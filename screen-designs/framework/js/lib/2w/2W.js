function _2W(configObj) {
    this.loadConfig(configObj);
} 

_2W.Globals = function(){
    return {
        pageSizes : {
            A4 : {
                width : 210,
                height : 297
            },
            A5 : {
                width : 210,
                height : 148
            }
        }
    }
}
Globals = new _2W.Globals();

_2W.Util = function(){
    return {
        extend : function(subc, superc, overrides) {
            /*
             * This function was taken from YAHOO yui library
             * Copyright (c) 2007, Yahoo! Inc. All rights reserved.
             * Code licensed under the BSD License:
             * http://developer.yahoo.net/yui/license.txt
             * version: 2.3.0
             */
            if (!superc||!subc) {
                throw new Error("Util.extend failed, please check that " +
                "all dependencies are included.");
            }
            var F = function() {};
            F.prototype=superc.prototype;
            subc.prototype=new F();
            subc.prototype.constructor=subc;
            subc.superclass=superc.prototype;
            if (superc.prototype.constructor == Object.prototype.constructor)
                superc.prototype.constructor=superc;
            if (overrides)
            {
                for (var i in overrides)
                {
                    subc.prototype[i]=overrides[i];
                }
            }
        },
        isEven : function(value) {
            return (value%2==0);
        },
        isEmail : function(email) {
            var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
            if(re.test(email))
            {
                return true;
            }
            else
            {
                return false;
            }
        },
        mergeObject : function(original, overwrite) {
            for(attrName in overwrite)
            {
                original[attrName] = overwrite[attrName]
            }
            return original;
        },
        columnize : function(obj, columns) {
            if(Util.ifIE() && Util.ifIE() < 10)
            {
                if(typeof obj == "object" && obj.text().length >= columns)
                {
                    var text = obj.text();
                    obj.text("");
                    var columnLength = Math.ceil(text.length / columns);
                    var objectName = obj.prop('tagName');
                    var className = obj.attr("class");
                    
                    var lastPosition = 0;
                    for(i = 0; i < columns; i++)
                    {
                        var newText = document.createElement(objectName);
                        newText = $(newText);
                        newText.addClass("ui-column");
                        newText.addClass("ui-column" + columns);
                        var cutSpace = text.substr(lastPosition + columnLength, text.length).indexOf(" ");
                        newText.text(text.substr(lastPosition, columnLength + cutSpace));
                        lastPosition = lastPosition + columnLength + cutSpace
                        obj.append(newText);
                    }
                }
            }
            else
            {
                obj.addClass("cols" + columns)
            }
        },
        ifIE : function() {
            var myNav = navigator.userAgent.toLowerCase();
            return (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]) : false;
        },
        error : function(instance, debugString,object) {
            if(typeof console != "undefined")
            {
                var objectInfo = instance;
                if(object != undefined)
                {
                    objectInfo = object;
                }
                console.error(debugString, objectInfo);
            }
        },
        warn : function(instance, debugString, object) {
            if(typeof console != "undefined")
            {
                var objectInfo = instance;
                if(object != undefined)
                {
                    objectInfo = object;
                }
                console.warn(debugString, objectInfo);
            }
        },
        info : function(instance, debugString, object) {
            if(typeof console != "undefined")
            {
                var objectInfo = instance;
                if(object != undefined)
                {
                    objectInfo = object;
                }
                console.info(debugString, objectInfo);
            }
        }
    }
}

var Util = new _2W.Util();

_2W.prototype = {
    loadConfig: function(configObj) {
        $.extend(this, configObj);
    }
};