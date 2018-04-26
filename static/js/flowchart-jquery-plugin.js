// This plugin code courtesy of bwmarrin from: https://github.com/adrai/flowchart.js/issues/54
if (typeof jQuery != 'undefined') {
    (function( $ ) {
        $.fn.flowchart = function( options ) {
            return this.each(function() {
                var $this = $(this);
                var diagram = flowchart.parse($this.text());
                $this.html('');
                diagram.drawSVG(this, options);
            });
        };
    })( jQuery );
}
