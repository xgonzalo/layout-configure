_2W.Application.Step5 = function(configObj) {
    _2W.Application.Step5.superclass.constructor.call(this, configObj);
} 

Util.extend(_2W.Application.Step5, _2W.Application.Step, {
    init: function(){
        this.render();
    },
    render: function() {
        var dom = $('<div class="rightPart pull-right"> \
                    <h1>'+Util.translate("wizzard.step5.title")+'</h1> \
                    <div class="container"> \
                        <div class="pull-left instructions-left"> \
                            <p>'+Util.translate("wizzard.step5.graytext")+'</p> \
                        </div> \
                        <div class="pull-left instructions-right"> \
                            <p>'+Util.translate("wizzard.step5.thankstext")+'</p> \
                        </div> \
                    </div> \
                </div>');
        this.container.append(dom);
    }
});
