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
    this.parent = null;
    
    _2W.UI.Element.superclass.constructor.call(this, configObj);
    
    if(this.container == null && this.dom != null)
    {
        this.container = this.dom.parent();
    }
}

Util.extend(_2W.UI.Element, _2W, {
    getDom: function() {
        return this.dom;
    },
    
    getContainer : function() {
        return this.container;
    },
    
    getParent: function() {
        return this.parent;
    },
    
    destroyDOM: function() {
        if(this.dom)
        {
            this.dom.stop();
            this.dom.unbind();
            this.dom.remove();
        }
    },
    
    destroy: function(skipBaseDom) {
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
    
    render: function() {
        throw new Error("Render method not implemented!");
    }
});

_2W.UI.Element.FluidBox = function(configObj) {
    this.height = 0;
    this.heightFixed = 0;
    this.refresh = true;
    _2W.UI.Element.FluidBox.superclass.constructor.call(this, configObj);
    
    //this.init();
}
Util.extend(_2W.UI.Element.FluidBox, _2W.UI.Element, {
    init : function() {
        this.addWindowEventHandler();
        this.fixHeight();
    },
    addWindowEventHandler: function() {
        var instance = this;
        if(this.refresh)
        {
            $(window).resize(function(){
                instance.fixHeight();
            })
        }
    },
    fixHeight: function() {
        //The header height is the current height of the element 
        if(this.height > 0)
        {
            var headerHeight = 80;
            var ht = ((document.body.clientHeight * this.height) / 100) - 80;
            this.dom.css("height", ht);
        }
        
        if(this.heightFixed > 0)
        {
            this.dom.css("height", this.heightFixed);
        }
    }
});

