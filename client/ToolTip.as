/*
   @author        Versus 2004/01/12
   @author        Joseph Poidevin 04/11/2005
   @author        Jeremy Echols 2007/07/22
   @version       0.6
   @description   My AS3 version of the nifty tooltip object - removal of
                  unnecessary code, lots of random fixes for a more stable
                  object, more customizable object, etc.  Sadly I can't give
                  proper credit as I don't know where the file originated,
                  so those above names will have to suffice (they were in the
                  AS2 version of this file)
   @tooltip
*/

package {
    //          Imports!
    // Events
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.events.TimerEvent;
    // Things that show up on stage
    import flash.display.MovieClip;
    import flash.display.DisplayObjectContainer;
    import flash.display.Shape;
    import flash.text.TextField;
    // Utility classes
    import flash.utils.Timer;
    import flash.utils.Dictionary;
    import flash.text.AntiAliasType;

    public class ToolTip {

    /******************************
    *           Properties
    *******************************/
        // Options for customizing display
        private static var display_options:Object;

        // Stage object for reattaching container (to keep it above other
        // objects, since addChildAt doesn't work for higher numbers)
        private static var stage;

        // Stage dimensions for keeping labels onstage
        private static var stage_width: Number, stage_height: Number;

        // actual textfield object to hold our final string
        private static var label: TextField;

        // text that stores the string we're using
        private static var _text: String;

        // movieclips for this tooltip - container that holds everything together,
        // background for behind-tooltext-color, and clip for drop-shadow effect
        private static var _cont: MovieClip;
        private static var bg: Shape;
        private static var shadow: Shape;

        // Can the user see the tip?
        private static var _visible: Boolean;

        // Timer object for handling delayed hovers
        private static var timer: Timer;

        // Hash of hover objects' data
        public static var hover_objects:Dictionary;


    /******************************
          Accessors
    *******************************/
        // Text we're showing
        public static function set text(t:String) {
          _text = t;
          label.htmlText = '<p align="' + display_options.text_align + '">' +
              '<font face="Verdana" size="10">' + _text + '</font></p>';
          reset_bg();
        }
        public static function get text():String {return _text;}
        // Is tooltip active?
        public static function get active():Boolean {return _cont.visible;}

    /******************************
    *     "Regular" code
    *******************************/

        // Starts the clock for showing a tooltip, sets our text attribute
        public static function start_show_timer(hover_object: Object) {
            var delay_ms = hover_objects[hover_object].tip_delay;
            var tip_text = hover_objects[hover_object].tip_text;

            timer.delay = delay_ms;
            timer.repeatCount = 1;
            timer.start();
            ToolTip.text = tip_text;
        }

        public static function show_tip(e: Event) {
            // Make sure container is top-level object
            stage.addChild(_cont);
            _cont.visible = true;
        }

        public static function hide() {
            _cont.visible = false;
            timer.stop();
        }

        // Build the dynamic movie clips, set up defaults, hide the tooltip object
        public static function init(st, opt) {
            hover_objects = new Dictionary();

            // Store the stage for reattaching _cont
            stage = st;


            // store the stage's dimensions - for this to be accurate we
            // can't have objects offstage when this call is made because
            // FOR SOME UNGODLY REASON, Flash devs thought it wise to make the
            // stage auto-size.
            stage_width   = st.stageWidth;
            stage_height  = st.stageHeight;

            // Set up default options and/or grab parameter options
            display_options = opt;
            display_options.opacity ||= 1;
            // Be lenient and allow integer values of opacity - translate them
            // here
            if (display_options.opacity > 1) {display_options.opacity /= 100.0;}
            display_options.text_align ||= 'left';
            display_options.default_delay ||= 500;

            // Build movie clips
            _cont   = new MovieClip();
            shadow  = new Shape();
            bg      = new Shape();

            // Built the label
            label = new TextField();
            label.x = 5;
            label.y = 0;
            label.width = 5;
            label.height = 5;
            label.autoSize = 'left';
            label.antiAliasType = flash.text.AntiAliasType.ADVANCED;
            label.selectable = false;
            label.multiline = true;

            // Now attach them as necessary - _cont to stage, others to _cont
            st.addChild(_cont);
            _cont.addChild(shadow);
            _cont.addChild(bg);
            _cont.addChild(label);

            // Set up, but don't start, the timer object (for future use)
            timer = new Timer(0, 0);
            timer.addEventListener(flash.events.TimerEvent.TIMER_COMPLETE, show_tip);

            hide();
        }

        private static function set_tooltip_to_mouse(e: MouseEvent) {
            var w = label.textWidth;
            var h = label.textHeight;
            _cont.x   = e.stageX - (w / 2);
            _cont.y   = e.stageY - h - 15;

            // Check to see if our clip is falling off the stage
            if (_cont.x < 5) {_cont.x = 5;}
            if (_cont.y < 5) {_cont.y = e.stageY + 40;}

            if (_cont.x + _cont.width > stage_width) {
                 _cont.x = stage_width - _cont.width - 5;
            }

            if (_cont.y + _cont.height > stage_height) {
                 _cont.y = stage_height - _cont.height - 5;
            }

            e.updateAfterEvent();
        }

        // Reset the background and shadow to the size of the text label
        private static function reset_bg() {
            var l:Number = label.x;
            var t:Number = label.y;
            var w:Number = label.textWidth + 12;
            var h:Number = label.textHeight + 4;

            bg.graphics.clear();
            bg.graphics.lineStyle(0, 0x333333, display_options.opacity);
            bg.graphics.beginFill(0xFFFFCC, display_options.opacity);
            bg.graphics.drawRect(l, t, w, h);
            bg.graphics.endFill();

            shadow.graphics.clear();
            shadow.graphics.beginFill(0x000000, display_options.opacity / 2);
            shadow.graphics.drawRect(l + 3, t + 3, w, h);
            shadow.graphics.endFill();
        }

        // Given a stage object, adds event handling to it and makes it respond
        // to the awesomeness of hover tips
        public static function attach(hover_object, tip_text: String, delay_ms = null) {
            hover_objects[hover_object] = {
                tip_text:         tip_text,
                tip_delay:        delay_ms ? delay_ms : display_options.default_delay
            }

            hover_object.addEventListener(flash.events.MouseEvent.MOUSE_OVER, function(e: MouseEvent) {
                ToolTip.start_show_timer(hover_object);
            });
            hover_object.addEventListener(flash.events.MouseEvent.MOUSE_OUT, function(e: MouseEvent) {
                ToolTip.hide();
            });
            hover_object.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, function(e: MouseEvent) {
                ToolTip.set_tooltip_to_mouse(e);
            });
        }
    }
}
