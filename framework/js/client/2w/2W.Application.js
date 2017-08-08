_2W.Application = function(configObj) {
    this.config = config;
    
    this.control = {}
    this.control.prevBt = null;
    this.control.nextBt = null;
    this.control.finishBt = null;
    
    this.steps = [];
    this.currentStep = 0;
    this.contentsURL = null;
    
    this.values = {};
    _2W.Application.superclass.constructor.call(this, configObj);
} 

Util.extend(_2W.Application, _2W, {
    closeModal: function(){
        var modalContainer = $(".modalContainer");
        modalContainer.addClass("hidden");
    },
    getContentsURL: function(){
        return this.contentsURL;
    },
    
    getDocument: function() {
        return this.document;
    },
    
    getConfigParameter: function(param) {
        if(this.config[param] != "undefined")
            return this.config[param];
        else
            return null;
    },
    
    getHashValue: function(value){
        return this.values[value];
    },
    
    getStep: function(number){
        return this.steps[number];
    },
    
    goToStep: function(n) {
        for(var i=1, it=this.steps.length; i < it; i++)
        {
            this.steps[i].hide();
        }
        
        if(n == 1)
            this.control.prevBt.hide();
        else
            this.control.prevBt.show();
        
        if(n == Globals.steps.CONTACTFORM)
        {
            this.control.nextBt.hide();
            this.control.finishBt.show();
        }
        else if(n == Globals.steps.THANKYOU)
        {
            this.control.prevBt.hide();
            this.control.nextBt.hide();
            this.control.finishBt.hide();
        }
        else
        {
            if(this.control.nextBt)
            {
                this.control.nextBt.show();
                this.control.finishBt.hide();
            }
        }
        
        this.currentStep = n;
        this.steps[this.currentStep].show();
    },
    
    lockNext: function(){
        this.control.nextBt.hide();
        this.control.finishBt.hide();
    },
    
    unlockNext: function(){
        //if(this.control.nextBt)
        //{
            if(this.currentStep == (this.steps.length - 1))
            {
                //this.control.nextBt.hide();
                //this.control.finishBt.show();
            }
            else
            {
                if(this.control.nextBt)
                    this.control.nextBt.show();
            }
        //}
        
        /*
        if(this.currentStep == Globals.steps.CONTACTFORM)
        {
            this.control.nextBt.hide();
            this.control.finishBt.show();
        }
        else if(this.currentStep == Globals.steps.THANKYOU)
        {
            this.control.nextBt.hide();
            this.control.finishBt.hide();
        }
        else
        {
            if(this.control.nextBt)
                this.control.nextBt.show();
        }
        */
        
    },
    
    next: function() {
        var currentStep = this.steps[this.currentStep];
        
        if(!currentStep.next())
        {
            var nextStep = this.currentStep + 1;
            
            if(currentStep && currentStep.validate())
            {
                this.goToStep(nextStep);
            }
        }
    },
    
    prev: function() {
        var currentStep = this.steps[this.currentStep];
        
        if(!currentStep.prev())
        {
            var nextStep = this.currentStep - 1;
            if(currentStep)
            {
                this.goToStep(nextStep);
            }
        }
    },
    
    init: function() {
        var hashes = window.location.hash;
        if(hashes != "")
        {
            hashes = hashes.substring(1).split("&");

            var currentHash;
            for(var h = 0, ht = hashes.length; h < ht; h++)
            {
                currentHash = hashes[h].split("=");
                this.values[currentHash[0]] = currentHash[1];
            }
        }
        
        var language = this.values["language"];
        if(language && (language == "en" || language == "de"))
            Globals.language = language;
        
        this.steps[Globals.steps.INTRO] = new _2W.Application.Step1({ container: $("#step1"), parent: this });
        
        this.steps[Globals.steps.DOCTYPE] = new _2W.Application.Step2({ 
            container: $("#step2"), 
            documentContainer: $("#contents"),
            parent: this, 
            docType: this.values["docType"] 
        });
        
        this.steps[Globals.steps.LAYOUTOPTIONS] = new _2W.Application.Step3({ container: $("#step3"), parent: this });
        
        this.steps[Globals.steps.CONTACTFORM] = new _2W.Application.Step4({ container: $("#step4"), parent: this });
        
        this.steps[Globals.steps.THANKYOU] = new _2W.Application.Step5({ container: $("#step5"), parent: this });
        
        this.render();
        this.goToStep(1);
    },
    
    render: function(){
        var instance = this;
        
        this.control.prevBt = $("#prevBt");
        this.control.prevBt.click(function(){
            instance.prev();
        });
        
        this.control.nextBt = $("#nextBt");
        this.control.nextBt.click(function(){
            instance.next();
        });
        
        this.control.finishBt = $("#finishBt");
        this.control.finishBt.click(function(){
            var step4 = instance.getStep(Globals.steps.CONTACTFORM);
            
            if(step4.post())
                instance.next();
        });
        this.control.finishBt.hide();
        
        this.control.nextBt.find(".nextText").text(Util.translate("wizard.control.button.next"));
        this.control.prevBt.find(".prevText").text(Util.translate("wizard.control.button.previous"));
        this.control.finishBt.find(".finishText").text(Util.translate("wizard.control.button.finish"));
        
        this.control.homeBt = $("#logo");
        var location = window.location.href;
        this.control.homeBt.attr("href", location.substring(0, location.indexOf('#')));
        
        this.control.languageSwitcher = {};
        this.control.languageSwitcher.de = $("#languageSwitcher").find(".deutch");
        this.control.languageSwitcher.de.click(function(){
            instance.updateHashValue("language", "de");
            window.location.reload();
        });
        
        this.control.languageSwitcher.en = $("#languageSwitcher").find(".english");
        this.control.languageSwitcher.en.click(function(){
            instance.updateHashValue("language", "en");
            window.location.reload();
        });
        
        $(".modalContainer").find(".modalOverlay").click(function(){
            instance.closeModal();
        });
        
        $(".modalContainer").find(".closeButton").click(function(){
            instance.closeModal();
        });
        
        this.control.impressumModal = $(".impressum").find("label").click(function(){
            instance.showModal(Util.translate("impressumTitle"), Util.translate("impressumContent"));
        });
    },
    
    setContentsURL: function(url){
        this.contentsURL = url;
    },
    
    showModal: function(title, text){
        var modalContainer = $(".modalContainer");
        var modalWindow = modalContainer.find(".modalWindow");
        var modalContent = modalWindow.find(".modalContent");
        
        modalContent.empty();
        
        if(title)
        {
            var titleEl = $("<h2>"+title+"</h2>");
            modalContent.append(titleEl);
        }
        
        if(text)
            modalContent.append(text);
        
        modalContainer.removeClass("hidden");
    },
    
    updateHashValue: function(key, value){
        this.values[key] = value;
        
        this.updateURL();
    },
    
    updateURL: function(){
        var hash;
        var hashValues = [];
        
        var j = 0;
        for(i in this.values)
        {
            hashValues[j] = i + "=" + this.values[i];
            j++;
        }

        window.location.hash = hashValues.join("&");        
    }
})

_2W.Application.Step = function(configObj) {
    this.config = config;
    this.dom = null;
    this.parent = configObj.parent;
    
    _2W.Application.Step.superclass.constructor.call(this, configObj);
    
    this.init();
} 

Util.extend(_2W.Application.Step, _2W, {
    getApplication: function(){
        return this.getParent();
    },
    
    getDom: function(){
        return this.dom;
    },
    
    getParent: function(){
        return this.parent;
    },
    
    hide: function(){
        this.container.hide();
    },
    
    init: function(){},
    
    next: function(){
        return false;
    },
    
    show: function(){
        this.container.show();
    },
    
    prev: function(){
        return false;
    },
    
    validate: function(){
        return true;
    }
});

$(document).ready(function(){
    var app = new _2W.Application();
    app.init();
})