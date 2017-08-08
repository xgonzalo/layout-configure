_2W.UI = function(configObj) {
    this.elements = [];
    this.dom = null;
    this.container = null;
    
    _2W.UI.superclass.constructor.call(this, configObj);
    this.init();
} 

Util.extend(_2W.UI, _2W, {
    init : function() {
        throw new Error("Init method wasn't implemented!");
    },
    
    registerElement : function(element) {
        this.elements.push(element);
    },
    
    render : function() {
        for(var i = 0, it = this.elements.length; i < it; i++)
        {
            this.elements[i].render();
        }
    }
});

_2W.UI.Element = function(configObj) {
    this.dom = null;
    this.container = null;
    this.children = [];
    this.debug = false;
    
    _2W.UI.Element.superclass.constructor.call(this, configObj);
    
    if(this.container == null && this.dom != null)
    {
        this.container = this.dom.parent();
    }
}

Util.extend(_2W.UI.Element, _2W, {
    
    getContainer : function() {
        return this.container;
    },
    
    destroyDOM : function() {
        if(this.dom)
        {
            this.dom.stop();
            this.dom.unbind();
            this.dom.remove();
        }
    },
    
    destroy : function() {
        this.destroyDOM();
        for(var c = 0, ct = this.children.length; c < ct; c++)
        {
            this.children[c].destroy();
        }
        
        for (var key in this)
        {
            delete this[key];
        }
    },
    
    render : function() {
        throw new Error("Render method wasn't implemented!");
    }
});

_2W.UI.Element.FluidBox = function(configObj) {
    this.height = 30;
    _2W.UI.Element.FluidBox.superclass.constructor.call(this, configObj);
    
    this.init();
}
Util.extend(_2W.UI.Element.FluidBox, _2W.UI.Element, {
    init : function()
    {
        this.addWindowEventHandler();
        this.fixHeight();
    },
    addWindowEventHandler : function() {
        var instance = this;
        $(window).resize(function(){
            instance.fixHeight();
        })
    },
    fixHeight : function(){
        var ht = ((document.body.clientHeight * this.height) / 100) - 80;
        this.dom.css("height", ht);
    }
})

_2W.UI.Element.Document = function(configObj) {
    this.scale = 100;
    this.pageSize = Globals.pageSizes.A4;
    this.pageWidth;
    this.actualPage = 0;
    this.portrait = true;
    this.carrousel;
    this.amountOfPages = 2;
    this.margins = {  // margins in mm
        top : 0,
        left: 0,
        bottom: 0,
        right: 0
    };
    this.header = {
        style : 0,
        className : "header"
    };
    
    this.footer = {
        style : 0,
        className : "footer"
    };
    this.marginalia = false;
    
    _2W.UI.Element.Document.superclass.constructor.call(this, configObj);
}

Util.extend(_2W.UI.Element.Document, _2W.UI.Element, {
    newPage : function(obj){
        var page = new _2W.UI.Element.Document.Page(Util.mergeObject(this, obj));
        page.parent = this;
        page.init();
        this.children.push(page)
    },
    sliderize : function() {
        var instance = this;
        this.carrousel = this.container.parent();
        this.pageWidth = this.children[0].dom.width() + 20;
        
        var next = $('<div class="next">2/3</div>');
        var prev = $('<div class="prev disabled">0</div>')
        
        this.carrousel.parent().after(prev);
        this.carrousel.parent().after(next);
        
        next.click(function(){
            instance.actualPage++;
            instance.moveTo(instance.actualPage, function(){
                if(instance.actualPage > instance.children.length - 3)
                {
                    next.addClass("disabled");
                }
                if(instance.actualPage > 0)
                {
                    prev.removeClass("disabled");
                }
                
                next.text((instance.actualPage + 2) + "/" + (instance.actualPage + 3))
                prev.text((instance.actualPage) + "/" + (instance.actualPage + 1))
            });
        })
        
        prev.click(function(){
            instance.actualPage--;
            instance.moveTo(instance.actualPage, function(){
                if(instance.actualPage < instance.children.length - 1)
                {
                    next.removeClass("disabled");
                }
                if(instance.actualPage == 0)
                {
                    prev.addClass("disabled");
                }
                
                next.text((instance.actualPage + 2) + "/" + (instance.actualPage + 3))
                prev.text((instance.actualPage) + "/" + (instance.actualPage + 1)) 
            });
        })
        this.carrousel.css("width", this.pageWidth * this.amountOfPages);
        this.centerPages();
    },
    resize : function(){
        this.pageWidth = this.children[0].dom.width() + 20;
        this.carrousel.css("width", this.pageWidth * this.amountOfPages);
        this.moveTo(this.actualPage);
        this.centerPages();
    },
    moveTo : function(page, callback) {
        if(page < this.children.length - 1 && page >= 0)
        {
            this.container.animate({
                "left" : page * (this.pageWidth+1) * -1
            }, 300, callback)
        }
    },
    centerPages : function() {
        this.container.parent().css({
            'margin-left' : '50%',
            'left' : this.container.parent().width() / -2
        })
    }
})

_2W.UI.Element.Document.Page = function(configObj) {
    this.mmCalculator;
    this.columns = 1;
    this.width;
    this.height;
    
    _2W.UI.Element.Document.Page.superclass.constructor.call(this, configObj);
}

Util.extend(_2W.UI.Element.Document.Page, _2W.UI.Element, {
    init : function()
    {
        if(this.portrait)
        {
            this.width = this.pageSize.width;
            this.height = this.pageSize.height;
        }
        else
        {
            this.width = this.pageSize.height;
            this.height = this.pageSize.width;
        }
        
        this.mmCalculator = $('<div style="width:' + this.width + 'mm;height:' + this.height + 'mm; display:none;"></div>');
        $("body").append(this.mmCalculator);
        
        this.updateScale();
        this.addWindowEventHandler();
        
        if(this.columns > 1)
        {
            this.columnizeParagraphs();
        }
    },
    addWindowEventHandler : function(){
        var instance = this;
        $(window).resize(function(){
            instance.updateScale(true);
        })
    },
    mmToPx : function(mmValue) {
        if(Util.ifIE() < 10)
        {
            //IN IE mm are not supported, calculate with number suggested by Google in 72dpi
            return mmValue / 0.264583
        }
        else
        {
            // Other Browsers
            return this.mmCalculator.width() / this.width * mmValue
        }
    },
    columnizeParagraphs : function() {
        var instance = this;
        this.dom.find("p.cols").each(function(){
            Util.columnize($(this), instance.columns);
        })
    },
    updateScale : function(onResize){
        if(onResize == undefined)
        {
            onResize == false;
        }
        var instance = this;
        var scale = this.container.height() / this.mmCalculator.height();
        
        var contentResized = this.dom.find(".pageResize");
        
        contentResized.css({
            'padding-left' : this.margins.left,
            'padding-top' : this.margins.top,
            'padding-right' : this.margins.right,
            'padding-bottom' : this.margins.bottom
        });
        
        this.dom.css("height", this.mmCalculator.height() * scale)
        contentResized.css("height", this.mmCalculator.height());
                
        this.dom.css("width", this.mmCalculator.width() * scale)
        contentResized.css("width", this.mmCalculator.width());
        
        this.dom.find(".pageResize").css({
            "transform" : "scale(" + scale + ")",
            "-webkit-transform" : "scale(" + scale + ")",
            "-moz-transform" : "scale(" + scale + ")",
            "-ms-transform" : "scale(" + scale + ")",
            "-o-transform" : "scale(" + scale + ")",
            "transform-origin" : "top left",
            "-ms-filter:" : "progid:DXImageTransform.Microsoft.Matrix(M11=" + scale + ", M12=0, M21=0, M22=" + scale + ", SizingMethod='auto expand')"  //ACCORDING IE8 DOCUMENTATION MUST BE IN ONLY 1 LINE
        })
        
        var parentWidth = (this.dom.width() + this.margins.left * scale + this.margins.right * scale + 10) * this.dom.parent().find(".page").length;
        this.container.css('width', parentWidth);
        if(onResize)
        {
            this.parent.resize();
        }
    }
})