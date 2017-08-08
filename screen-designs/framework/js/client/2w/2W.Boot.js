_2W.Boot = function(configObj) {
    this.pages = new Array();
    
    _2W.Boot.superclass.constructor.call(this, configObj);
} 

Util.extend(_2W.Boot, _2W, {
    init : function() {
        var instance = this;
        var document = new _2W.UI.Element.Document({
            scale : 100,
            portrait : true,
            pageSize : Globals.pageSizes.A4,
            margins : {
                top : 10,
                left: 20,
                bottom: 20,
                right: 20
            },
            header : {
                style : 0,  //0 = Outside -  1 = Inside -  2 = Center
                className : "header"
            },
            footer : {
                style : 0,  //0 = Outside -  1 = Inside -  2 = Center
                className : "footer"
            },
            marginalia : true
        })
        
        fluid.find(".page").each(function(){
            var page = $(this);
            document.newPage({
                container : page.parent(),
                dom : page,
                columns : 3
            });
        })
        document.sliderize();
    }
})

$(document).ready(function(){
    fluid = $('.row-fluid');
    var boot = new _2W.Boot();
    boot.init();
})