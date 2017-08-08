$(function(){
    $(".fileUpload").fileupload({
            url : "http://dev.ec-systems.de/test/upload.php",
            dataType: 'json',
            autoUpload: true,
            acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
            maxFileSize: 999000,
            disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator.userAgent),
            previewMaxWidth: 200,
            previewMaxHeight: 100,
            previewCrop: true,
    }).on('fileuploadprocessalways', function (e, data) {
        var index = data.index;
        var file = data.files[index];
        var parent = $(e.target).parents(".formOptions");
        var img = parent.find("img");
        var filenameElement = parent.find(".fileName");

        if(file.preview)
        {
            var preview = $(file.preview);
            preview.addClass("preview")
            img.after(preview);
            img.hide();
            
            filenameElement.text(file.name);
        }
    }).on('fileuploaddone', function (e, data) {
        //TODO: What to do if file was uploaded OK
    }).on('fileuploadfail', function (e, data) {
        //TODO: What to do if there was an error uploading
        //errorMessage: data.jqXHR.responseText
    })
})