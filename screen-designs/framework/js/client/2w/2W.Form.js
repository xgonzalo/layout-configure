_2W.Form = function(configObj) {
    this.pages = new Array();
    
    _2W.Form.superclass.constructor.call(this, configObj);
} 

Util.extend(_2W.Form, _2W, {
    init : function(){
        this.initEvents();
    },
    initEvents : function() {
        var instance = this;
        formElement.find("#submit").click(function(e) {
            if(!instance.checkFields())
            {
                e.preventDefault();
            }
        })
        formElement.find(".numbers").keypress(function(e){
            console.log(e.which)
            if((e.which < 48 || e.which > 57) && e.which != 8 && e.which != 0)
            {
                return false;
            }
        })
    },
    checkFields : function() {
        var readyToSend = true;
        var errorText = "";
        formElement.find(".has-error").removeClass("has-error");
        formElement.find(".alert").remove();
        formElement.find("input[type='text']").each(function(){
            if($(this).val() == "" && $(this).parents(".mandatory").length > 0)
            {
                $(this).parents(".form-group").addClass("has-error");
                errorText += '<label>' + $(this).attr('placeholder') + ' is required</label><br />';
                readyToSend = false;
            }
        })
        
        if(!Util.isEmail(formElement.find("#mail").val()) && !formElement.find("#mail").parents(".form-group").hasClass("has-error"))
        {
            formElement.find("#mail").parents(".form-group").addClass("has-error");
            errorText += '<label>The email entered is not valid</label><br />'
            readyToSend = false;
        }
        
        if(!readyToSend)
        {
            formElement.prepend('<div class="alert alert-danger" role="alert">\
                                    <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>\
                                    <span class="errorList">\
                                        ' + errorText + '\
                                    </span>\
                                </div>');
        }
        
        return readyToSend;
    }
})

$(document).ready(function(){
    formElement = $(".form-horizontal");
    var form = new _2W.Form();
    form.init();
})