/***********************************
 * 
 * PERSONALIZATION LAYOUT OPTION
 * 
 **********************************/

_2W.UI.Element.OptionsPanel.Personalization = function(configObj) {
    this.domElements = [];
    
    _2W.UI.Element.OptionsPanel.Personalization.superclass.constructor.call(this, configObj);
    this.init();
}

Util.extend(_2W.UI.Element.OptionsPanel.Personalization, _2W.UI.Element.OptionsPanel.Option, {
    addScript: function(url){
        var s = document.createElement("script");
        s.type = "text/javascript";
        s.src = url;
        
        $("head").append(s);
    },
    
    applyStyle: function(){
        switch(this.id)
        {
            case "personalizationimage":
                this.replaceImage();
                break;
                
            case "personalizationlogo":
                this.replaceLogo();
                break;
                
        }
    },
    
    replaceImage: function(){
        if(this.value)
        {
            $(".personalizable").find("img").remove();
            
            var newImg = $('<img src="uploads/'+this.value+'" >');
            $(".personalizable").append(newImg);
            $(".personalizable").removeClass("image");
            newImg.show();
        }
    },
    
    replaceLogo: function(){
        if(this.value)
        {
            var container = $(".pageResize").find(".logo");
            container.find("img").remove();
            
            var newImg = $('<img src="uploads/'+this.value+'" >');
            container.append(newImg);
            newImg.show();
        }
    },
    
    render: function(){
        var instance = this;
        this.container = this.tab.getOptionsContainer();
        
        var form = $('<div class="formOptions" id="personalization'+this.section+'"> \
            <label class="pull-left">'+Util.translate("personalization.uploadOwn."+this.section)+':</label> \
            <span class="btn fileinput-button pull-left"> \
                <span>'+Util.translate("personalization.searchFile")+'...</span> \
                <input class="fileupload" type="file" name="uploadFile" /> \
            </span> \
            <label class="fileName"></label> \
            <img src="framework/css/images/logo.gif" style="display: none"/> \
        </div>');
        
        this.container.append(form);
        
        form.find(".fileUpload").fileupload({
                url : "handler/upload.php",
                dataType: 'json',
                autoUpload: true,
                acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
                maxFileSize: 999000,
                disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator.userAgent),
                previewMaxWidth: 200,
                previewMaxHeight: 75,
                previewCrop: true
        }).on('fileuploadprocessalways', function (e, data) {
            var index = data.index;
            var file = data.files[index];
            var parent = $(e.target).parents(".formOptions");
            var img = parent.find("img");
            var filenameElement = parent.find(".fileName");
            var button = parent.find(".submitForm");

            if(file.preview)
            {
                parent.find("canvas").remove();
                var preview = $(file.preview);
                preview.addClass("preview")
                img.after(preview);
                img.hide();
                
                filenameElement.text(file.name);
                
                button.click(function(){
                    data.submit();
                })
            }
        }).on('fileuploaddone', function (e, data) {
            if(data.result.filename)
            {
                instance.setValue(data.result.filename);
                instance.saveHash();
                instance.applyStyle();
            }
            else
                throw "Upload Image Failed.";
            
            
        }).on('fileuploadfail', function (e, data) {
            throw "Upload Image Failed.";
        })
    },
    
    reset: function(){
    },
    
    updateUI: function(){
    }
});


/***********************************
 * 
 * FORMAT LAYOUT OPTION
 * 
 **********************************/

_2W.UI.Element.OptionsPanel.Format = function(configObj) {
    _2W.UI.Element.OptionsPanel.Format.superclass.constructor.call(this, configObj);
    this.init();
}

Util.extend(_2W.UI.Element.OptionsPanel.Format, _2W.UI.Element.OptionsPanel.RadioOption, {
    applyStyle: function(forceValue, eventType){
        if(eventType)
        {
            var value = forceValue ? forceValue : this.value;
            
            var step3 = this.getParent().getParent();
            var formatParts = value.split("-");
            var size = formatParts[0].toUpperCase();
            var orientation = formatParts[1];
            var pageSizeSet = Util.getPageSizeSet(size, orientation);
            
            step3.setDocumentPageSize(pageSizeSet);
            step3.renderDocument();
            step3.optionsPanel.refreshPreview();
            step3.document.checkPagesOverflow();            
        }
    }
});



/***********************************
 * 
 * NUMBER OF COLUMNS LAYOUT OPTION
 * 
 **********************************/

_2W.UI.Element.OptionsPanel.NumberOfColumns = function(configObj) {
    _2W.UI.Element.OptionsPanel.NumberOfColumns.superclass.constructor.call(this, configObj);
    this.init();
}

Util.extend(_2W.UI.Element.OptionsPanel.NumberOfColumns, _2W.UI.Element.OptionsPanel.RadioOption, {
    applyStyle: function(forceValue, eventType){
        var value;
        var origValue;
        
        if(forceValue)
            origValue = forceValue;
        else
            origValue = this.value;
        
        if(origValue)
        {
            value = "number-of-columns-" + origValue;
            
            var instance = this;
            var step = this.getParent().getParent();
            var doc = step.getDocument();
            
            var docPages = doc.getChildren();
            for(var i=0, it=this.elements.length; i < it; i++)
            {
                for(var c=0, ct=docPages.length; c < ct; c++)
                {
                    var pageObj = docPages[c];
                    var targetElements = pageObj.getDom().find(this.elements[i]);
                    
                    if(this.section != "" && this.section != null)
                        targetElements = targetElements.find("." + this.section);
                    
                    if(targetElements.length > 0)
                        pageObj.setColumns(origValue);
                    
                    targetElements.each(function(){
                        for(j in instance.values)
                        {
                            var cssClass = "number-of-columns-" + instance.values[j];
                            $(this).removeClass(cssClass);
                        }
                        
                        $(this).addClass(value);
                    });
                    
                }
            }
        }
    }
});
