_2W.Popup = function(configObj) {
    _2W.Popup.superclass.constructor.call(this, configObj);
} 

Util.extend(_2W.Popup, _2W, {
    init : function(){
        this.initEvents();
    },
    close : function(){
        overlay.remove();
        popupElement.remove();
    },
    initEvents : function() {
        var instance = this;
        overlay.click(function(){
            instance.close();
        })
        
        popupElement.find(".closeButton").click(function(){
            instance.close();
        })
    }
});

$(document).ready(function(){
    popupElement = $(".popup");
    overlay = $(".overlay");
    var popup = new _2W.Popup();
    popup.init();
})