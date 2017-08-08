function _2W(configObj) {
    this.loadConfig(configObj);
} 

_2W.Globals = function(){
    return {
        pageSizes: {
            A4: {
                width: 210,
                height: 297
            },
            A5: {
                width: 148,
                height: 210
            }
        },
        language: "de",
        steps: {
            INTRO: 1,
            DOCTYPE: 2,
            LAYOUTOPTIONS: 3,
            CONTACTFORM: 4,
            THANKYOU: 5,
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
        translate : function(token) {
            var language = Globals.language;
            var result = trasnlate.tokens[language][token];
            if(result != undefined)
            {
                return result;
            }
            return token;
        },
        getBrowserUserAgent: function(){
            return navigator.userAgent;
        },
        isMobile: function(){
            var result = false;
            
            if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(this.getBrowserUserAgent()))
                result = true;
            
            return result;
        },
        getPageSizeSet: function(size, orientation){
            size = size.toUpperCase();
            
            var result = {
                width: Globals.pageSizes[size].width,
                height: Globals.pageSizes[size].height,
            }
            
            if(orientation == "landscape")
            {
                var width = result.width;
                result.width = result.height;
                result.height = width;
            }
            
            return result;
        },
        isEven : function(value) {
            return (value%2==0);
        },
        mergeObject : function(original, overwrite) {
            for(attrName in overwrite)
            {
                original[attrName] = overwrite[attrName]
            }
            return original;
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