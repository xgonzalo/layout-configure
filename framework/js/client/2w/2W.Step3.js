_2W.Application.Step3 = function(configObj) {
    this.document;
    this.documentCache = null;
    this.documentPageSize = null;
    
    this.documentConfig = {};
    this.documentConfig.cache = null;
    this.documentConfig.pageSize = null;
    this.documentConfig.format = null;
    
    this.previewPanel = null;
    this.optionsPanel = null;    
    
    _2W.Application.Step3.superclass.constructor.call(this, configObj);
} 

Util.extend(_2W.Application.Step3, _2W.Application.Step, {
    getDocument: function(){
        return this.document;
    },
    
    getDocumentCache: function(){
        return this.documentConfig.cache;
    },
    
    getDocumentFormat: function(){
        return this.documentConfig.format;
    },
    
    getDocumentPageSize: function(){
        if(this.documentPageSize == null)
        {
            var formatOption = this.optionsPanel.getOptionByName("format");
            var value = formatOption.loadValue();
            
            if(!value)
                value = "a4-portrait";
            
            var formatParts = value.split("-");
            var size = formatParts[0].toUpperCase();
            var orientation = formatParts[1];
            var pageSizeSet = Util.getPageSizeSet(size, orientation);
            
            this.setDocumentFormat(value);
            this.setDocumentPageSize(pageSizeSet);
        }
        
        return this.documentConfig.pageSize;
    },
    
    getOptionsPanel: function(){
        return this.optionsPanel;
    },
    
    init: function(){
        var instance = this;
        
        this.previewPanel = new _2W.UI.Element.PreviewPanel({
            dom: this.container.find(".boxTop"),
            parent: this,
            heightFixed: 600,
            refresh: false
        });
        this.previewPanel.render();
        
        this.optionsPanel = new _2W.UI.Element.OptionsPanel({
            dom: this.container.find(".boxBottom"),
            parent: this,
            heightFixed: 450,
            refresh: false
            //height: 40
        });
        
        this.optionsPanel.render();
    },
    
    next: function(){
        return this.optionsPanel.next();
    },
    
    prev: function(){
        return this.optionsPanel.prev();
    },
    
    renderDocument: function(){
        var currentPage = 0;
        
        if(this.document != null)
        {    
            currentPage = this.document.getActualPage();
            this.document.destroy();
        }
        
        this.document = new _2W.UI.Element.Document({
            scale: 100,
            pageSize: this.getDocumentPageSize(),
            format: this.getDocumentFormat(),
            margins: {
                top: 5,
                left: 5,
                bottom: 5,
                right: 5
            },
            header: {
                style : 0,  //0 = Outside -  1 = Inside -  2 = Center
                className : "header"
            },
            footer: {
                style: 0,  //0 = Outside -  1 = Inside -  2 = Center
                className: "footer"
            },
            marginalia: true,
            parent: this
        });
        
        this.document.moveTo(currentPage, true);
    },
    
    setDocumentCache: function(cache){
        this.documentConfig.cache = cache;
    },
    
    setDocumentFormat: function(format){
        this.documentConfig.format = format;
    },
    
    setDocumentPageSize: function(pageSizeSet){
        this.documentConfig.pageSize = pageSizeSet;
    },
    
    show: function(){
        _2W.Application.Step3.superclass.show.call(this);
        var instance = this;
        
        debugger;
        $.ajax({
            url: this.getParent().getContentsURL()
        })
        .done(function(data) {
            instance.setDocumentCache(data);
            instance.renderDocument();
            instance.optionsPanel.goToTab(0);
            instance.optionsPanel.updateSelectedOptions();
            instance.document.checkPagesOverflow();
        });        
    }
});

_2W.UI.Element.PreviewPanel = function(configObj) {
    _2W.UI.Element.OptionsPanel.superclass.constructor.call(this, configObj);
    
    this.init();
}
Util.extend(_2W.UI.Element.PreviewPanel, _2W.UI.Element.FluidBox, {
    init: function() {
        _2W.UI.Element.PreviewPanel.superclass.init.call(this);
        
    },
    render: function() {
    },
    
    reset: function() {
    }
});



_2W.UI.Element.OptionsPanel = function(configObj) {
    this.tabs = [];
    this.layoutOptions = [];
    this.layoutOptionsIndex = {};
    
    this.currentTab = 0;
    
    _2W.UI.Element.OptionsPanel.superclass.constructor.call(this, configObj);
    
    this.init();
}
Util.extend(_2W.UI.Element.OptionsPanel, _2W.UI.Element.FluidBox, {
    
    destroyDOM: function() {
        if(this.dom)
        {
            this.dom.stop();
            this.dom.unbind();
            this.dom.children().empty();
        }
    },
    
    getOptionByName: function(name){
        var result = null;
        
        if(this.layoutOptionsIndex[name])
            result = this.layoutOptionsIndex[name];
        
        return result;
    },
    
    getOptions: function(){
        return this.layoutOptions;
    },
    
    init: function() {
        _2W.UI.Element.OptionsPanel.superclass.init.call(this);
        var layoutOptions = this.parent.config.layoutOptions;
        
        for(var i=0, it=layoutOptions.length; i < it; i++)
        {
            var configObj = layoutOptions[i];
            
            var tab = new _2W.UI.Element.OptionsPanel.Tab({
                name: configObj.name,
                index: this.tabs.length,
                elements: configObj.options.elements,
                scrollToElement: configObj.scrollTo,
                scrollToElementPage: configObj.scrollToPage,
                container: this.dom,
                parent: this
            });
            this.tabs.push(tab);
            
            var optionObj = null;
            var sections = configObj.sections;
            if(sections.length == 0)
                sections = ["default"];
            
            var section = null;
            for(var s=0, st=sections.length; s < st; s++)
            {
                section = sections[s];
                if(section == "default")
                    section = "";
                
                switch(configObj.type)
                {
                    case "combo":
                        optionObj = new _2W.UI.Element.OptionsPanel.ComboOption({
                            elements: configObj.options.elements,
                            name: configObj.name,
                            parent: this,
                            section: section,
                            type: configObj.type,
                            tab: tab,
                            values: configObj.options.values
                        });
                        
                        break;
                    
                    case "custom":
                        optionObj = new _2W.UI.Element.OptionsPanel[configObj.object]({
                            elements: configObj.options.elements,
                            name: configObj.name,
                            parent: this,
                            section: section,
                            type: configObj.type,
                            tab: tab,
                            values: configObj.options.values
                        });
                        
                        break;
                        
                    case "radio":
                    default:
                        optionObj = new _2W.UI.Element.OptionsPanel.RadioOption({
                            elements: configObj.options.elements,
                            name: configObj.name,
                            parent: this,
                            section: section,
                            type: configObj.type,
                            tab: tab,
                            values: configObj.options.values
                        });
                        
                        break;
                }
                
                this.layoutOptionsIndex[optionObj.name] = optionObj;
                this.layoutOptions.push(optionObj);
            }
        }
    },
    
    goToTab: function(index){
        this.tabs[index].show();
    },
    
    next: function(){
        var currentTab = this.tabs[this.currentTab];
        var nextTabIndex = this.currentTab + 1;
        
        if(this.tabs[nextTabIndex])
        {
            this.goToTab(nextTabIndex);
            return true;
        }
        else
        {
            return false;
        }
    },
    
    prev: function(){
        var currentTab = this.tabs[this.currentTab];
        var nextTabIndex = this.currentTab - 1;
        
        if(this.tabs[nextTabIndex])
        {
            this.goToTab(nextTabIndex);
            return true;
        }
        else
        {
            return false;
        }
    },
    
    refreshPreview: function(){
        for(var i=0, it=this.layoutOptions.length; i < it; i++)
        {
            this.layoutOptions[i].applyStyle();
        }
    },
    
    render: function() {
        for(var i=0, it=this.tabs.length; i < it; i++)
            this.tabs[i].render();
        
        for(var i=0, it=this.layoutOptions.length; i < it; i++)
            this.layoutOptions[i].render();
    },
    
    hideAllTabs: function() {
        for(var i=0, it=this.tabs.length; i < it; i++)
        {
            this.tabs[i].hide();
        }
    },
    
    setCurrentTab: function(index){
        this.currentTab = index;
    },
    
    updateSelectedOptions: function(){
        for(var i = 0, it = this.layoutOptions.length; i < it; i++)
        {
            this.layoutOptions[i].refresh();
        }
    }
});


_2W.UI.Element.OptionsPanel.Tab = function(configObj) {
    this.name = null;
    this.elements = [];
    this.icon = null;
    this.scrollToElement = false;
    this.scrollToElementPage = false;
    
    this.navContainer = null;
    
    this.contentContainer = null;
    this.optionsContainer = null;
    
    _2W.UI.Element.OptionsPanel.Tab.superclass.constructor.call(this, configObj);
    this.init();
}

Util.extend(_2W.UI.Element.OptionsPanel.Tab, _2W.UI.Element, {
    getOptionsContainer: function(){
        return this.optionsContainer;
    },
    
    hide: function(){
        this.dom.removeClass("active");
        this.contentContainer.removeClass("active");
    },
    
    init: function() {
    },
    
    render: function(){
        var instance = this;
        var tabContentContainer = this.container.find(".tab-content");
        this.navContainer = this.container.find(".nav");
        
        this.dom = $("<li class='tab-"+this.name+"'><a>"+Util.translate(this.name)+"</a></li>");
        this.navContainer.append(this.dom);
        
        this.contentContainer = $("<div class='tab-pane "+this.name+"-tabContent'></div>");
        tabContentContainer.append(this.contentContainer);
        
        this.optionsContainer = $('<div class="pull-left optGroup"><label>'+Util.translate(this.name)+'</label></div>');
        this.contentContainer.append(this.optionsContainer);
        
        this.dom.click(function(){
            instance.show();
        });        
    },
    
    scrollSlider: function(){
        var pageIndex = null;
        var step3 = this.getParent().getParent();
        var document = step3.getDocument();
        
        if(this.scrollToElementPage)
        {
            pageIndex = this.scrollToElementPage;
        }
        else if(this.scrollToElement && this.elements[0])
        {
            var elementPage = document.findElementPage(this.elements[0]);
            
            if(elementPage)
                pageIndex = elementPage.getIndex();
        }
        
        if(pageIndex != null)
            document.moveTo(pageIndex);
    },
    
    show: function(){
        this.parent.hideAllTabs();
        this.parent.setCurrentTab(this.index);
        this.dom.addClass("active");
        this.contentContainer.addClass("active");
        this.scrollSlider();
    }
});


_2W.UI.Element.OptionsPanel.Option = function(configObj) {
    this.elements = null;
    this.id = null;
    this.name = null;
    this.section = null;
    this.suggested = null;
    this.value = null;
    
    _2W.UI.Element.OptionsPanel.Option.superclass.constructor.call(this, configObj);
    this.init();
}

Util.extend(_2W.UI.Element.OptionsPanel.Option, _2W.UI.Element, {
    applyStyle: function(forceValue, eventType){
        var value;
        
        if(forceValue)
            value = forceValue;
        else
            value = this.value;
        
        if(value)
        {
            var instance = this;
            var step = this.getParent().getParent();
            var doc = step.getDocument();
            
            var docPages = doc.getChildren();
            for(var i=0, it=this.elements.length; i < it; i++)
            {
                for(var c=0, ct=docPages.length; c < ct; c++)
                {
                    var targetElements = docPages[c].getDom().find(this.elements[i]);
                    
                    if(this.section != "" && this.section != null)
                        targetElements = targetElements.find("." + this.section);
                    
                    targetElements.each(function(){
                        for(j in instance.values)
                        {
                            var cssClass = instance.values[j];
                            $(this).removeClass(cssClass);
                        }
                        
                        $(this).addClass(value);
                    });
                }
            }
        }
    },
    
    init: function(){
        this.id = this.name + this.section;
    },
    
    loadValue: function(){
        var step3 = this.getParent().getParent();
        var app = step3.getApplication();
        var step2 = app.getStep(Globals.steps.DOCTYPE);
        var suggestedOptions = step2.getDocTypeConfig().layoutOptions;
        
        var value = app.getHashValue(this.id);
        if(!value)
        {
            if(suggestedOptions[this.name])
            {
                if(this.section)
                    value = suggestedOptions[this.name][this.section];
                else
                    value = suggestedOptions[this.name];
            }
        }
        
        return value;
    },
    
    render: function(){
        throw "Layout Option render() method not implemented.";
    },
    
    getID: function(){
        return this.id;
    },
    
    getValue: function(){
        return this.value;
    },
    
    saveHash: function(){
        var step3 = this.getParent().getParent();
        var app = step3.getApplication();
        app.updateHashValue(this.id, this.value);
    },
    
    setValue: function(value){
        this.value = value;
    },
    
    refresh: function(){
        var value = this.loadValue();
        
        if(value)
        {
            this.setValue(value);
            this.updateUI();
            this.applyStyle();
        }
    },
    
    updateUI: function(){
        throw "Layout Option updateUI() method not implemented.";
    }
    
});

_2W.UI.Element.OptionsPanel.RadioOption = function(configObj) {
    this.domElements = [];
    this.hoverValue = null;
    _2W.UI.Element.OptionsPanel.RadioOption.superclass.constructor.call(this, configObj);
    this.init();
}

Util.extend(_2W.UI.Element.OptionsPanel.RadioOption, _2W.UI.Element.OptionsPanel.Option, {
    render: function(){
        var instance = this;
        var step = instance.getParent().getParent(); 
        this.container = this.tab.getOptionsContainer();
        
        for(var i = 0, it = this.values.length; i < it; i++)
        {
            var outer = $('<div></div>');
            this.container.append(outer);
            
            var label = $('<label class="radioContainer pull-left"><span>'+Util.translate(this.values[i])+'</span></label>');
            outer.append(label);
            
            var radio = $('<input type="radio" value="'+this.values[i]+'">');
            label.prepend(radio);
            
            radio.bind("click touchstart", function(){
                if($(this).val() != instance.getValue())
                {
                    instance.setValue($(this).val());
                    instance.updateUI();
                    instance.saveHash();
                    instance.applyStyle(null, "click");
                    
                    step.getDocument().checkPagesOverflow();
                }
            });
            
            if(!Util.isMobile())
            {
                label.mouseover(function(){
                    instance.hoverValue = $(this).find("input").val();
                    
                    if(instance.hoverValue != instance.getValue())
                    {
                        instance.applyStyle(instance.hoverValue, "hover");
                        step.getDocument().checkPagesOverflow();
                    }
                });
                
                label.mouseout(function(){
                    if(instance.hoverValue != instance.getValue())
                    {
                        instance.applyStyle(instance.getValue(), "hover");
                        step.getDocument().checkPagesOverflow();
                    }
                });
            }
            
            this.domElements[this.values[i]] = radio;
        }
    },
    
    reset: function(){
        for(key in this.domElements)
        {
            this.domElements[key].prop("checked", false);
        }
    },
    
    updateUI: function(){
        this.reset();
        this.domElements[this.value].prop("checked", true);
    }
});



_2W.UI.Element.OptionsPanel.ComboOption = function(configObj) {
    this.domElements = [];
    _2W.UI.Element.OptionsPanel.ComboOption.superclass.constructor.call(this, configObj);
    this.init();
}

Util.extend(_2W.UI.Element.OptionsPanel.ComboOption, _2W.UI.Element.OptionsPanel.Option, {
    render: function(){
        var instance = this;
        this.container = this.tab.getOptionsContainer();
        
        var outer = $('<div class="pull-left comboOptionContainer"></div>');
        this.container.append(outer);
        
        var label = $('<label class="comboOption">'+Util.translate(this.section)+'</label>');
        outer.append(label);
        
        var select = $('<select></select>');
        outer.append(select);
        
        for(var i = 0, it = this.values.length; i < it; i++)
        {
            var option = $(' <option value="'+this.values[i]+'">'+Util.translate(this.values[i])+'</option>');
            select.append(option);
           
            this.domElements[this.values[i]] = option;
        }
        
        select.change(function(event){
            var optionSelected = $(this).find("option:selected");
            
            instance.setValue(optionSelected.val());
            instance.saveHash();
            instance.applyStyle(false, "click");
        });
        
    },
    
    reset: function(){
        for(key in this.domElements)
        {
            this.domElements[key].removeAttr("selected");
        }
    },
    
    updateUI: function(){
        this.reset();
        this.domElements[this.value].attr("selected", "selected");
    }
});


_2W.UI.Element.Document = function(configObj) {
    _2W.UI.Element.Document.superclass.constructor.call(this, configObj);
    
    this.controls = {};
    this.pageConfigMock = configObj;
    this.scale = 100;
    this.pageSize;
    this.format;
    this.f = true;
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
    this.container = $("#contents");
    
    this.carrousel = this.container.parent();
    this.pageWidth = 0;
    this.actualPage = 0;
    this.amountOfPages = 2;
    
    this.fakePages = [];
    
    this.init();
}

Util.extend(_2W.UI.Element.Document, _2W.UI.Element, {
    
    checkPagesOverflow: function(){
        var pagesArray = [];
        var p = 0;
        
        for(var i=0, it=this.children.length; i < it; i++)
        {
            if(this.children[i].isFake)
            {
                this.children[i].destroy();
            }
            else
            {
                pagesArray[p] = this.children[i];
                p++;
            }
        }
        
        this.children = pagesArray;
        for(var i=0; i < this.children.length; i++)
        {
            this.children[i].checkOverflow();
        }
        
    },
    
    destroy: function(){
        for(var i=0, it=this.children.length; i < it; i++)
        {
            this.children[i].destroy();
            this.children[i] = null;
        }
        
        this.carrousel.css({"padding-top": "0px"});
        this.carrousel.parent().find(".prev").remove();
        this.carrousel.parent().find(".next").remove();
    },
    
    findElementPage: function(element){
        var result = null;
        var page = null;
        var elements = [];
        for(var i = 0, it = this.children.length; i < it; i++)
        {
            page = this.children[i];
            elements = page.dom.find(element);
            
            if(elements.length > 0)
            {
                result = page;
                
                break;
            }
        }
        
        return result;
    },
    
    getActualPage: function(){
        return this.actualPage;
    },
    
    getChildren: function(){
        return this.children;
    },
    
    init: function(){
        var instance = this;
        var index = 0;
        
        this.container.empty();
        this.container.append(this.getParent().getDocumentCache());
        
        this.container.find(".page").each(function(){
            var page = $(this);

            var pageObj = instance.newPage({
                container: page.parent(),
                dom: page,
                index: index
            });
            
            index++;
        });
        
        this.initSlider();
    },
    
    initSlider: function() {
        this.pageWidth = this.children[0].dom.width() + 20;
        var realPageWidth = this.children[0].dom.outerWidth();
        var realPageHeight = this.children[0].dom.outerHeight();
        
        var instance = this;
        
        this.controls.next = $('<div class="next"></div>');
        this.controls.prev = $('<div class="prev"></div>');
        
        this.carrousel.parent().append(this.controls.prev);
        this.carrousel.parent().append(this.controls.next);
        
        this.controls.next.click(function(){
            instance.moveTo((instance.actualPage + 1));
        })
        
        this.controls.prev.click(function(){
            instance.moveTo((instance.actualPage - 1));
        })
        
        this.carrousel.css("width", this.pageWidth * this.amountOfPages);
        
        if(this.isPortrait())
            this.carrousel.parent().height(realPageHeight);
        else
            this.carrousel.parent().height(realPageHeight * 2);
        
        this.centerPages();
    },
    
    isPortrait: function(){
        return this.pageSize.width < this.pageSize.height;
    },
    
    centerPages: function() {
        var paddingTop = 0;
        
        if(!this.isPortrait())
            paddingTop = (this.carrousel.height() / 2) - (this.carrousel.find(".page").eq(0).height() / 2);
        
        this.carrousel.css({
            'margin-left' : '50%',
            'left' : this.carrousel.width() / -2,
            'padding-top': paddingTop 
        });
    },
    
    moveTo: function(page, skipAnimation) {
        this.actualPage = page;
        
        if(page < this.children.length - 1 && page >= 0 && page != "undefined")
        {
            if(skipAnimation)
            {
                this.container.css("left", page * (this.pageWidth+1) * -1);
                
            }
            else
            {
                this.container.animate({
                    "left" : page * (this.pageWidth+1) * -1
                }, 300);
            }
            
            this.updateSliderControls();
        }
    },
    
    newPage: function(obj){
        var configObj = Util.mergeObject(this.pageConfigMock, obj);
        configObj.format = this.format;
        
        var page = new _2W.UI.Element.Document.Page(Util.mergeObject(this.pageConfigMock, obj));
        page.init();
        
        this.children.push(page);
        
        return page;
    },
    
    updateSliderControls: function(){
        var init = 0;
        var offset = this.children.length - 2;
        
        if(this.actualPage == init)
        {
            this.controls.prev.addClass("disabled");
            this.controls.next.removeClass("disabled");
        }
        else if(this.actualPage >= offset)
        {
            this.controls.prev.removeClass("disabled");
            this.controls.next.addClass("disabled");
        }
        else
        {
            this.controls.prev.removeClass("disabled");
            this.controls.next.removeClass("disabled");
        }
        
        this.controls.next.text((this.actualPage + 2) + "/" + (this.actualPage + 3));
        this.controls.prev.text((this.actualPage) + "/" + (this.actualPage + 1));
    },
    
    updateSliderWidth: function(){
        this.container.css("width", (this.children.length * this.pageWidth) + 10);
    }
});


_2W.UI.Element.Document.Page = function(configObj) {
    this.mmCalculator;
    this.format;
    this.index = null;
    this.width;
    this.height;
    this.columns = 1;
    this.isFake = false;
    this.contentHeight;
    
    _2W.UI.Element.Document.Page.superclass.constructor.call(this, configObj);
}

Util.extend(_2W.UI.Element.Document.Page, _2W.UI.Element, {
    destroy: function(){
        this.dom.remove();
    },
    
    getIndex: function(){
        return this.index;
    },
    
    checkOverflow: function(){
        this.resetOverFlow();
        
        var result = null;
        var container = this.dom.find(".pageResize").find(".documentContent").first();
        
        if(container.height() < this.contentHeight)
        {
            result = this.getOverflowMarkup(container, container.height());
            
            if(result.length > 0)
            {
                var mockObj = this.getMockupObj();
                mockObj.index = this.index + 1;
                mockObj.isFake = true;
                
                mockObj.dom = this.dom.clone();
                this.dom.after(mockObj.dom);
                
                var contentDom = mockObj.dom.find(".bodyContent").children(".documentContent");
                
                mockObj.dom.find(".bodyContent").children(".mainTitle").remove();
                
                contentDom.empty();
                
                if(!result[0].hasClass("overflow-element-hidden"))
                {
                    result[0].find(".overflow-element-hidden").siblings().each(function(){
                        if(!$(this).hasClass("overflow-element-hidden"))
                        {
                            $(this).remove();
                        }
                    });
                }
                
                contentDom.append(result);
                
                var hiddenElements = contentDom.find(".overflow-element-hidden");
                hiddenElements.removeClass("overflow-element-hidden");
                
                var doc = this.getParent().getDocument();
                doc.fakePages.push(mockObj);
                
                var pagesArray = [];
                pagesArray[mockObj.index] = mockObj;
                
                var ni = 0;
                for(var i = 0, it = doc.children.length; i < it; i++)
                {
                    var obj = doc.children[i];
                    
                    if(pagesArray[ni])
                        ni++;
                    
                    obj.index = ni;
                    pagesArray[ni] = obj;
                    
                    ni++;
                }
                
                doc.children = pagesArray;
                doc.updateSliderWidth();
            }
        }
        
        return result;
    },
    
    getMockupObj: function(){
        var mockObj = $.extend({}, this);
        
        mockObj.dom = null;
        mockObj.index = null;
        
        return mockObj;
    },
    
    getOverflowMarkup: function(container, availableHeight, isRecursive){
        var result = [];
        var currentHeight = 0;
        var containerHeight = container.height();
        var childElements = container.children();
        var lastColumnInit = 0;
        var lastColumnOffset = container.get(0).getBoundingClientRect().width;
        
        var overFlowFlag = false;
        var ignoreElements = ["COLGROUP"];
        
        if(this.columns > 1 && !isRecursive)
            lastColumnInit = (lastColumnOffset / this.columns) * (this.columns - 1);
        
        /*
        if(this.index == 6)
        {
            console.log(container);
            console.log("Columns: " + this.columns);
            console.log("Available Height: " + availableHeight);
            console.log("lastColumnInit: " + lastColumnInit);
            console.log("lastColumnOffset: " + lastColumnOffset);
        }
        */
        
        for(var i = 0, it = childElements.length; i < it; i++)
        {
            var child = $(childElements[i]);
            var childPos = child.position();
            
            /*
            if(this.index == 3 && !isRecursive)
            {
                console.log(child);
                console.log(childPos);
                console.log("Overflow Flag: " + overFlowFlag);
                console.log("Current Height: " + currentHeight);
                console.log(child.outerHeight(true));
                console.log("================");
            }
            
            if(this.index == 4 && isRecursive)
            {
                console.log("Current Height: " + currentHeight);
                console.log(child);
                console.log(childPos);
                console.log(child.outerHeight(true));
            }
            */
            
            if(ignoreElements.indexOf(child.prop("tagName")) > -1)
            {
                continue;
            }
            if(overFlowFlag)
            {
                child.addClass("overflow-element-hidden");
                
                if(!isRecursive)
                    result.push(child.clone());
            }
            else 
            {

                if(childPos.left >= lastColumnInit || lastColumnInit == 0)
                {
                    var childHeight = child.outerHeight(true);
                    
                    if((currentHeight + childHeight) > availableHeight)
                    {
                        overFlowFlag = true;
                        
                        if(!child.hasClass("image-front") && !child.hasClass("image"))
                        {
                            if(child.prop("tagName") == "TABLE" || child.prop("tagName") == "TBODY" || child.hasClass("blockContent"))
                            {
                                this.getOverflowMarkup(child, (availableHeight - currentHeight), true);
                            }
                            else
                            {
                                child.addClass("overflow-element-hidden");
                            }
                            
                            if(!isRecursive)
                                result.push(child.clone());
                        }
                    }
                    else
                    {
                        currentHeight = currentHeight + childHeight;
                    }
                }
            }
        }
        
        return result;
    },
    
    init: function()
    {
        this.width = this.pageSize.width;
        this.height = this.pageSize.height;
        this.portrait = this.width < this.height;
        
        $("#mmCalculator").remove();
        this.mmCalculator = $('<div id="mmCalculator" style="width:' + this.width + 'mm;height:' + this.height + 'mm; display:none;"></div>');
        $("body").append(this.mmCalculator);
        
        this.updateScale();
        //this.addWindowEventHandler();
    },
    
    addWindowEventHandler: function(){
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
    
    resetOverFlow: function(){
        var container = this.dom.find(".pageResize").find(".documentContent").first();
        
        container.find(".overflow-element-hidden").removeClass("overflow-element-hidden");
    },
    
    setColumns: function(num){
        this.columns = num;
    },
    
    updateScale: function(onResize){
        var instance = this;
        
        if(onResize == undefined)
            onResize == false;
        
        if(this.portrait)
            var scale = this.container.parents(".carrouselContainer").height() / this.mmCalculator.height();
        else
            var scale = this.container.parents(".carrouselContainer").width() / this.mmCalculator.width() / 2;
        
        var contentResized = this.dom.find(".pageResize");
        var headerContent = contentResized.children(".header");
        var bodyContent = contentResized.children(".bodyContent");
        var footerContent = contentResized.children(".footer");
        
        contentResized.addClass(this.format);
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
        
        contentResized.css({
            "transform" : "scale(" + scale + ")",
            "-webkit-transform" : "scale(" + scale + ")",
            "-moz-transform" : "scale(" + scale + ")",
            "-ms-transform" : "scale(" + scale + ")",
            "-o-transform" : "scale(" + scale + ")",
            "transform-origin" : "top left",
            "-ms-filter:" : "progid:DXImageTransform.Microsoft.Matrix(M11=" + scale + ", M12=0, M21=0, M22=" + scale + ", SizingMethod='auto expand')"  //ACCORDING IE8 DOCUMENTATION MUST BE IN ONLY 1 LINE
        })
        
        var parentWidth = (this.dom.width() + this.margins.left * scale + this.margins.right * scale + 20) * this.dom.parent().find(".page").length;
        this.container.css('width', parentWidth);
        
        var docContentEl = bodyContent.children(".documentContent");
        var contentTitleEl = bodyContent.children(".mainTitle");
        var contentTitleElHeight = contentTitleEl ? contentTitleEl.outerHeight(true) : 0;
        var docContentHeightLimit = contentResized.height() - (headerContent.outerHeight(true) + footerContent.height() + contentTitleElHeight);
        
        this.contentHeight = docContentEl.height();
        docContentEl.height(docContentHeightLimit);
    },
    
    centerPages : function(ml, mr) {
        var pages = this.container.find("> *");
        var totalPages = pages.length;
        if(pages.index(this.dom[0]) == 0)
        {
            var totalWidth = (totalPages * this.dom.width()) + ((totalPages-1)*(26 + ml + mr));
            if(totalWidth < this.container.parent().width())
            {
                this.container.css({
                    'margin-left' : totalWidth / -2,
                    'left' : '50%'
                })
            }
            else
            {
                this.container.css('width', totalWidth);
            }
        }
    }
});