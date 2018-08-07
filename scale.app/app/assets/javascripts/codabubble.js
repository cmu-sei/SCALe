/*!
* jQuery Codabubble Plugin
* http://github.com/elidupuis
*
* Copyright 2010, Eli Dupuis
* Version: 0.4
* Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) and GPL (http://creativecommons.org/licenses/GPL/2.0/) licenses.
* Requires: jQuery v1.4.2 or later
* Based heavily on Remy Sharp's snippet at http://jqueryfordesigners.com/coda-popup-bubbles/

TODO:
- destroy function
- add smart-direction feature? if direction is set to RIGHT and there's no room for element, make it appear on the left.
*/


(function($) {

  var ver = '0.4',
  methods = {
    init: function( options ) {
      // iterate and reformat each matched element
     return this.each(function() {
     var $this = $(this),
     opts = $.extend({}, $.fn.codabubble.defaults, options),
            data = $this.data('codabubble');

        // If the plugin hasn't been initialized yet
        if ( ! data ) {

          var hideDelayTimer = null,
              beingShown = false, // tracker
              shown = false,
              trigger = $(opts.triggerClass, this),
              popup = $(opts.popupClass, this).css('opacity', 0),
              offset,
              defaultCss = {},
              directionProperty;
          
          // determine offset format:
          if ( typeof opts.offset === 'function' ) {
            offset = opts.offset.call(this, popup, $this) + 'px';
          }else{
            offset = opts.offset + 'px';
          };

          // determine desired direction:
          switch ( opts.direction ) {
            case 'left' :
              directionProperty = 'left';
              break;
            case 'right' :
              directionProperty = 'right';
              break;
            case 'down' :
              directionProperty = 'bottom';
              break;
            default :
              directionProperty = 'top';
              break;
          };
          
          // setup default css based on desired direction:
          defaultCss[directionProperty] = offset;
          defaultCss['display'] = 'block';

          // attach mouseover/mouseout listeners and functionality:
          $([trigger.get(0), popup.get(0)]).bind({
            'mouseover.codabubble': function () {
              // stops the hide event if we move from the trigger to the popup element
              if (hideDelayTimer) {
                clearTimeout(hideDelayTimer);
              };

              // don't trigger the animation again if we're being shown, or already visible
              if (beingShown || shown) {
                return;
              } else {
                beingShown = true;

                // setup animation properties
                var animCSS = { opacity: 1 };
                animCSS[directionProperty] = '-=' + opts.distance + 'px';

                // reset position of popup box and animate:
                popup.css( defaultCss ).animate(animCSS, opts.time, 'swing', function() {
                  // once the animation is complete, set the tracker variables
                  beingShown = false;
                  shown = true;
                });
                
              }
            },
            'mouseout.codabubble': function () {
              // reset the timer if we get fired again - avoids double animations
              if (hideDelayTimer) {
                clearTimeout(hideDelayTimer);
              };
            
              // store the timer so that it can be cleared in the mouseover if required
              hideDelayTimer = setTimeout(function () {
                hideDelayTimer = null;

                var animCSS = { opacity: 0 };
                animCSS[directionProperty] = '-=' + opts.distance + 'px';
               
                popup.animate(animCSS, opts.time, 'swing', function () {
                  shown = false; // once the animate is complete, set the tracker variables
                  popup.hide(); // hide the popup entirely after the effect (opacity alone doesn't do the job)
                });
              }, opts.hideDelay);
            }
          }).trigger('mouseout.codabubble');
          

          // attach data:
          $(this).data('codabubble', {
            target : $this,
            opts: opts
          });

        };
      });
    },
    destroy: function() {
      // to be implemented....
      if(window.console) window.console.log('destroy called.');
    }
  };

  $.fn.codabubble = function( method ) {
    if ( methods[method] ) {
      return methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      return methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' + method + ' does not exist on jQuery.codabubble' );
    };
  };

  // defaults
  $.fn.codabubble.defaults = {
   distance: 10, // distance traveled by bubble during animation.
   offset: 0, // offset distance. either an integer of a function that returns an integer
    time: 250, // milliseconds. duration of the animation.
    hideDelay: 500, // milliseconds. time before bubble fades out (after mouseout)
    direction: 'up', // either 'left', 'right', down' or 'up'
    triggerClass: '.trigger', // class of the trigger (in your markup)
    popupClass: '.popup' // class of the bubble (in your markup)
  };

  $.fn.codabubble.ver = function() { return "jquery.codabubble ver. " + ver; };

})(jQuery);
