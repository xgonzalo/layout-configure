_2W.Application.Step1 = function(configObj) {
    
    _2W.Application.Step1.superclass.constructor.call(this, configObj);
} 

Util.extend(_2W.Application.Step1, _2W.Application.Step, {
    init: function(){
        this.render();
    },
    render: function() {
        var leftColumn = $('<div class="pull-left"></div>');
        var rightColumn = $('<div class="pull-left"></div>');
        
        var leftPartDom = $('<p class="leftPart"></p>');
        leftPartDom.text(Util.translate("wizzard.step1.introText"));
        
        var rightPartDom = $('<div class="rightPart"></div>')
        rightColumn.append(rightPartDom);
        
        var title = $('<h1></h1>');
        title.text(Util.translate("wizzard.step1.title"));
        
        var leftInstructionsDom = $('<p class="instructions-left pull-left"></p>');
        leftInstructionsDom.append(Util.translate("wizzard.step1.leftInstructions"));
        
        var rightInstructionsDom = $('<p class="instructions-right pull-left"></p>');
        rightInstructionsDom.append(Util.translate("wizzard.step1.rightInstructions"));
        
        leftColumn.append(leftPartDom);
        
        rightPartDom.append(title);
        rightPartDom.append(leftInstructionsDom);
        rightPartDom.append(rightInstructionsDom);
        
        rightColumn.append(rightPartDom);
        
        this.container.append(leftColumn);
        this.container.append(rightColumn);
    }
});