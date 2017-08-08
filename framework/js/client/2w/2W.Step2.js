_2W.Application.Step2 = function(configObj) {
    this.children = [];
    this.docTypeConfig = null;
    this.documentContainer = null;
    
    _2W.Application.Step2.superclass.constructor.call(this, configObj);
    
} 

Util.extend(_2W.Application.Step2, _2W.Application.Step, {
    getDocType: function(){
        return this.docType;
    },
    
    getDocTypeConfig: function(){
        return this.docTypeConfig;
    },
    
    init: function(){
        for(var i=0, it=this.config.docTypes.length; i < it; i++)
        {
            var optionConfig = this.config.docTypes[i];

            if(this.docType == optionConfig.name)
            {
                this.setDocType(optionConfig);
            }

            optionConfig.parent = this;
            var optObj = new _2W.UI.Element.DocTypeOption(optionConfig);
            
            if(this.docType == optionConfig.name)
                optObj.selected = true;
            
            this.children.push(optObj);
        }
        
        this.render();
    },
    
    loadDoctypeResources: function(){
        var instance = this;

        $(".styleObjBase").attr("disabled", "disabled");
        
        if($("#" + this.docTypeConfig.id).length == 0)
            $("head").append("<link class='styleObjBase' id='"+this.docTypeConfig.id+"' href='"+this.docTypeConfig.style+"' type='text/css' rel='stylesheet' />");
        else
            $("#" + this.docTypeConfig.id).removeAttr("disabled");
        
        this.getParent().setContentsURL(this.docTypeConfig.content);
    },
    
    render: function(){
        var instance = this;
        
        var leftPart = $('<div class="pull-left"></div>');
        var rightPart = $('<div class="pull-left"></div>');
        this.dom = $('<div class="rightPart"></div>');
        rightPart.append(this.dom);
        
        var leftPartText = $('<p class="leftPart">' + Util.translate("wizzard.step2.leftInstructions") + '</p>');
        leftPart.append(leftPartText);
        
        var title = $('<h1>' + Util.translate("wizzard.doctype.title") + '</h1>');
        this.dom.append(title);
        
        this.container.append(leftPart);
        this.container.append(rightPart);
        
        for(var i=0, it=this.children.length; i < it; i++)
        {
            this.children[i].render();
        }
    },
    
    reset: function(){
        for(var i=0, it=this.children.length; i < it; i++)
        {
            this.children[i].unselect();
        }
    },
    
    show: function(){
        _2W.Application.Step3.superclass.show.call(this);
        
        if(!this.docType)
            this.getParent().lockNext();
    },
    
    setDocType: function(docTypeConfig){
        this.docType = docTypeConfig.name;
        this.docTypeConfig = docTypeConfig;
        this.loadDoctypeResources();
        this.getParent().updateHashValue("docType", this.docType);
        this.getParent().unlockNext();
    }
});

_2W.UI.Element.DocTypeOption = function(configObj) {
    _2W.UI.Element.DocTypeOption.superclass.constructor.call(this, configObj);
    
    this.docTypeConfig = configObj;
    this.selected = false;
    this.init();
}

Util.extend(_2W.UI.Element.DocTypeOption, _2W.UI.Element, {
    init: function(){
    },
    
    render: function() {
        var instance = this;
        this.container = this.getParent().getDom();
        
        this.dom = $('\
            <div class="pull-left manualOptionContainer">\
                <div class="manualOption">\
                    <span>' + Util.translate(this.name) + '</span>\
                    <img src="' + this.icon + '" />\
                </div>\
                <p>' + Util.translate(this.description) + '</p>\
                <p class="optionChoose">\
                    <input type="radio" name="documentType" />\
                    <label>' + Util.translate(this.name) + '</label>\
                </p>\
            </div>\
        ');
        
        this.container.append(this.dom);
        
        this.dom.find(".manualOption, .optionChoose label").click(function(){
            instance.setValue();
        })
        
        this.dom.find(".optionChoose input:radio").change(function(){
            instance.setValue();
        })
        
        if(this.selected == true){
            this.select(false);
        }
    },
    
    setValue: function(){
        this.select(true);
        this.getParent().setDocType(this.docTypeConfig);
    },
    
    select: function(reset){
        if(reset)
            this.getParent().reset();
        
        this.selected = true;
        this.dom.addClass("active");
        this.dom.find("input:radio").prop("checked", true);
    },
    
    unselect: function(){
        this.selected = false;
        this.dom.removeClass("active");
        this.dom.find("input:radio").prop("checked", false);
    }
});