_2W.Application.Step4 = function(configObj) {
    this.form = null;
    _2W.Application.Step4.superclass.constructor.call(this, configObj);
} 

Util.extend(_2W.Application.Step4, _2W.Application.Step, {
    
    getDownloadPDFURI: function(){
        var app = this.getApplication();
        var step3 = app.getStep(Globals.steps.LAYOUTOPTIONS);
        var options = step3.getOptionsPanel().getOptions();
        var handlerURL = 'http://' + window.location.hostname + window.location.pathname + app.config.application.pdfHandler + "?";
        var values = [];
        
        var opt, optValue, optID;
        for(var i=0, it = options.length; i < it; i++)
        {
            opt = options[i];
            optValue = opt.getValue();
            optID = opt.getID();
            
            if(opt.getValue() == null)
            {
                continue;
            }
            else
            {
                if(optID == "format")
                {
                    var formatParts = optValue.split("-");
                    var pageSizeSet = Util.getPageSizeSet(formatParts[0], formatParts[1]);
                    
                    values.push("page-width=" + pageSizeSet.width);
                    values.push("page-height=" + pageSizeSet.height);
                }
                else
                {
                    values.push(optID + "=" + optValue);
                }
            }
        }
        
        values.push("client=" + app.config.application.client);
        
        return handlerURL + values.join("&");
    },
    
    init: function(){
        this.render();
    },
    
    render: function(){
        var instance = this;
        var leftPart = $('\
                        <div class="pull-left">\
                            <p class="leftPart">' + Util.translate('wizzard.step4.leftInstructions') + '</p>\
                        </div>');
        
        var rightPartContainer = $('<div class="pull-left"></div>');
        
        var rightPart = $('\
                        <div class="rightPart">\
                            <h1>' + Util.translate('wizzard.step4.title') + '</h1>\
                            <p class="contactInfo">' + Util.translate('wizzard.step4.introText') + '</p>\
                            <p class="contactInfo">' + Util.translate('wizzard.step4.downloadPDF') +
                            '<img class="downloadPDF" src="framework/css/images/pdf-icon-40.png" width="40" height="40"/></p> \
                        </div>');
        
        this.dom = $('<div class="formContainer form-inline"></div>');
        rightPart.append(this.dom);
        rightPartContainer.append(rightPart);
        
        rightPart.find(".downloadPDF").click(function(){
            window.open(instance.getDownloadPDFURI(),'_blank')
        });
        
        this.container.append(leftPart);
        this.container.append(rightPartContainer);
        
        this.form = new _2W.UI.Element.Form.ContactForm({
            parent: this
        });
        this.form.init();
        
        rightPart.find(".termsAndConditionsButton").click(function(){
            instance.getApplication().showModal(Util.translate("wizzard.step4.termsTitle"), Util.translate("wizzard.step4.terms"));
        });
    },
    
    post: function(){
        var result = false;
        
        var formValues = this.form.getValues();
        var url = window.location.href;
        var urlPost = this.parent.config.application.contactForm.url;
        
        if(formValues)
        {
            var postData = {};
            postData["values"] = formValues;
            postData["url"] = url;
            postData["language"] = Globals.language;
            postData["pdfUrl"] = this.getDownloadPDFURI();
            
            $.post(urlPost, postData, function(result){});
            
            result = true;
        }
        
        return result;
    },
    
    show: function(){
         _2W.Application.Step4.superclass.show.call(this);
    }
});


_2W.UI.Element.Form = function(configObj) {
    this.fields;
    _2W.UI.Element.Form.superclass.constructor.call(this, configObj);
}

Util.extend(_2W.UI.Element.Form, _2W.UI.Element, {
    render: function() {
        var instance = this;
        for(var i=0, it=this.children.length; i < it; i++)
        {
            var child = this.children[i].child;
            this.parent.dom.append(child.field);
        }
    }
});


_2W.UI.Element.Form.ContactForm = function(configObj) {
    
    _2W.UI.Element.Form.ContactForm.superclass.constructor.call(this, configObj);
}

Util.extend(_2W.UI.Element.Form.ContactForm, _2W.UI.Element.Form, {
    getValues: function(){
        var result = {};
        
        for(var i = 0, it = this.children.length; i < it; i++)
        {
            var field = this.children[i].child;
            
            if(field.check())
                result[field.getKey()] = field.getValue();
            else
                return false;
        }
        
        return result;
    },
    
    init: function() {
        var contactFormFields = this.parent.config.application.contactForm.fields;
        for(var i=0, it=contactFormFields.length; i < it; i++)
        {
            var fieldData = contactFormFields[i];
            var field = new _2W.UI.Element.Field({
                child: fieldData
            })
            
            this.children.push(field);
        }
        this.render();
    }
});


_2W.UI.Element.Field = function(configObj) {
    this.child;
    
    _2W.UI.Element.Field.superclass.constructor.call(this, configObj);
    this.init();
}

Util.extend(_2W.UI.Element.Field, _2W.UI.Element, {
    init: function(){
        switch(this.child.type) {
            case "text":
                this.child = new _2W.UI.Element.Field.TextField({
                    text: this.child.name,
                    key: this.child.key,
                    maxChars: this.child.maxChars,
                    mandatory: this.child.mandatory 
                });
            break
            case "combo":
                this.child = new _2W.UI.Element.Field.ComboField({
                    text: this.child.name,
                    key: this.child.key,
                    values: this.child.values,
                    mandatory: this.child.mandatory
                });
            break
            case "radio":
                this.child = new _2W.UI.Element.Field.RadioField({
                    text: this.child.name,
                    key: this.child.key,
                    values: this.child.values,
                    mandatory: this.child.mandatory
                });
            break
            case "email":
                this.child = new _2W.UI.Element.Field.EmailField({
                    text: this.child.name,
                    key: this.child.key,
                    maxChars : this.child.maxChars,
                    mandatory: this.child.mandatory
                });
            break
            case "checkbox":
                this.child = new _2W.UI.Element.Field.CheckField({
                    text: this.child.name,
                    key: this.child.key,
                    values: this.child.values,
                    mandatory: this.child.mandatory
                });
            break
        }
    }
});


_2W.UI.Element.Field.TextField = function(configObj) {
    this.text = "";
    this.key;
    this.field;
    this.maxChars = "";
    this.mandatory = false;
    
    _2W.UI.Element.Field.TextField.superclass.constructor.call(this, configObj);
    this.render();
}

Util.extend(_2W.UI.Element.Field.TextField, _2W.UI.Element, {
    render: function() {
        this.dom = $('<input maxlength="' + this.maxChars + '" class="form-control" type="text" id="' + this.text + '" />');
        
        this.field = $('\
            <p class="field">\
                <label class="control-label" for="' + this.text + '">' + Util.translate(this.text) + ': </label>\
            </p>\
        ');
        
        this.field.append(this.dom);
    },
    getKey: function(){
        return this.key;
    },
    getValue: function() {
        return this.dom.val();
    },
    check: function() {
        var error = false;
        
        if(this.mandatory && this.getValue() == "")
        {
            this.dom.parent().addClass("has-error");
            error = true;
        }
        else
        {
            this.dom.parent().removeClass("has-error");
        }
        
        return !error;
    }
});


_2W.UI.Element.Field.ComboField = function(configObj) {
    this.text = "";
    this.values = new Array();
    this.key;
    this.field;
    this.mandatory = false;
    
    _2W.UI.Element.Field.ComboField.superclass.constructor.call(this, configObj);
    this.render();
}

Util.extend(_2W.UI.Element.Field.ComboField, _2W.UI.Element, {
    render: function() {
        this.field = $('\
            <p class="field">\
                <label class="control-label" for="' + Util.translate(this.text) + '">' + Util.translate(this.text) + ': </label>\
            </p>\
        ');
        this.dom = $('<select class="form-control"><option value="">-</option></select>');
        this.field.append(this.dom);
        
        for(var i=0, it=this.values.length; i < it; i++)
        {
            var value = this.values[i];
            this.dom.append('<option value="' + value.value + '">' + Util.translate(value.text) + '</option>');
        }
    },
    getKey: function(){
        return this.key;
    },
    getValue: function() {
        return this.dom.val();
    },
    check: function() {
        var error = false;
        
        if(this.mandatory && this.getValue() == "")
        {
            this.dom.parent().addClass("has-error");
            error = true;
        }
        else
        {
            this.dom.parent().removeClass("has-error");
        }
        
        return !error;
    }
});

_2W.UI.Element.Field.RadioField = function(configObj) {
    this.text = "";
    this.values = new Array();
    this.key;
    this.field;
    this.mandatory = false;
    
    _2W.UI.Element.Field.RadioField.superclass.constructor.call(this, configObj);
    this.render();
}



Util.extend(_2W.UI.Element.Field.RadioField, _2W.UI.Element, {
    render: function() {
        this.field = $('<p class="field"></p>');
        this.dom = this.field;
        
        for(var i=0, it=this.values.length; i < it; i++)
        {
            var value = this.values[i];
            this.dom.append('<div class="radioRow"><input value="' + value.value + '" type="radio" id="' +  this.key + "-" + value.value + '" name="' + this.key +'" /><label class="control-label radioField " for="' +  this.key + "-" + value.value + '">' + Util.translate(value.text) + '</label></div>');
        }
    },
    getKey: function(){
        return this.key;
    },
    getValue: function() {
        var radioSelected = $(this.dom).find(":checked");
        var value = null;
        
        if(radioSelected)
            value = radioSelected.val();
        
        return value;
    },
    check: function() {
        var error = false;
        
        if(this.mandatory && this.getValue() == "")
        {
            this.dom.parent().addClass("has-error");
            error = true;
        }
        else
        {
            this.dom.parent().removeClass("has-error");
        }
        
        return !error;
    }
});



_2W.UI.Element.Field.EmailField = function(configObj) {
    this.text = "";
    this.key;
    this.field;
    this.maxChars = "";
    this.mandatory = false;
    
    _2W.UI.Element.Field.EmailField.superclass.constructor.call(this, configObj);
    this.render();
}

Util.extend(_2W.UI.Element.Field.EmailField, _2W.UI.Element, {
    render: function() {
        this.dom = $('<input maxlength="' + this.maxChars + '" class="form-control" type="email" id="' + this.text + '" />');
        
        this.field = $('\
            <p class="field">\
                <label class="control-label" for="' + Util.translate(this.text) + '">' + Util.translate(this.text) + ': </label>\
            </p>\
        ');
        
        this.field.append(this.dom);
    },
    getKey: function(){
        return this.key;
    },
    getValue: function() {
        return this.dom.val();
    },
    check: function() {
        var error = false;
        
        var regex = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
        var validEmail = regex.test(this.getValue());
        
        if(!validEmail)
        {
            error = true;
        }
        
        if(!this.mandatory && this.getValue() == "")
        {
            error = false;
        }
        
        if(error)
        {
            this.dom.parent().addClass("has-error")
        }
        else
        {
            this.dom.parent().removeClass("has-error");
        }
        
        return !error;
    }
});


_2W.UI.Element.Field.CheckField = function(configObj) {
    this.text = "";
    this.key;
    this.field;
    this.values = new Array();
    this.mandatory = false;
    
    _2W.UI.Element.Field.CheckField.superclass.constructor.call(this, configObj);
    this.render();
}

Util.extend(_2W.UI.Element.Field.CheckField, _2W.UI.Element, {
    render: function() {
        this.dom = $('<input class="form-control" type="checkbox" id="' + this.key + '" />');
        
        this.field = $('\
            <p class="field checkRow">\
                <label class="control-label checkField" for="' + this.key + '">' + Util.translate(this.text) + ' </label>\
            </p>\
        ');
        
        this.field.prepend(this.dom);
    },
    getKey: function(){
        return this.key;
    },
    getValue: function() {
        for(var i=0, it=this.values.length; i < it; i++)
        {
            var value = this.values[i];
            if(value.status == this.dom.is(':checked'))
            {
                return value.value;
            }
        }
    },
    check : function() {
        var error = false;
        if(this.mandatory)
        {
            if(this.dom.is(':checked'))
            {
                this.dom.parent().removeClass("has-error");
            }
            else
            {
                this.dom.parent().addClass("has-error");
                error = true;
            }
        }
        
        return !error;
    }
});