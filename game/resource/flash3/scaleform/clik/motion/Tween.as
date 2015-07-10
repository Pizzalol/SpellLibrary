/**
 * Light-weight tween class specifically designed for use with GFx and CLIK.
 * 
 * Usage:
 * var tween1:Tween = new Tween(1000, myObject, {x:250, y:250, alpha:0}, {paused:false, ease:Strong.easeOut, onComplete:handleTweenComplete, loop:true});
 */

/**************************************************************************

Filename    :   Tween.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.motion {
    
    import flash.display.Shape;
    import flash.events.Event;
    import flash.utils.getTimer;
    
    import flash.display.DisplayObject;
    import flash.geom.Matrix;
    import flash.geom.Transform;

    public class Tween {
        
        protected static var ticker:Shape = new Shape();
        protected static var workingMatrix:Matrix = new Matrix();
        ticker.addEventListener(Event.ENTER_FRAME, Tween.tick, false, 0, true);
        
        protected static var firstTween:Tween;
        protected static var lastTime:uint = getTimer();
        protected static var degToRad:Number = 1/180*Math.PI;
        
        protected static function tick(evt:Event):void {
            var t:Number = getTimer();
            var delta:Number = t-lastTime;
            lastTime = t;
            var tween:Tween = firstTween;
            while (tween) {
				var nextTween:Tween = tween.next;
                tween.updatePosition(tween.frameBased ? 1 : delta);
                tween = nextTween;
            }
        }
        
        /** Removes a particular tween from the list of tweens being executed. */
        protected static function removeTween(tween:Tween):void {
            if (tween.prev) { tween.prev.next = tween.next; }
            if (tween.next) { tween.next.prev = tween.prev; }
            if (tween == firstTween) { firstTween = tween.next; }
            tween.prev = tween.next = null;
        }
        
        /** Removes all tweens from the list and stops execution. */
        public static function removeAllTweens():void {
            firstTween = null;
        }
        
        /*
        // For debugging
        public static function printTweens():void {
            var ret:String = ">> Tweens: ";
            if (firstTween) {
                var t:Tween = firstTween;
                while (t) { 
                    ret += "\t" + t.target.name;
                    t = t.next;
                }
            }
            trace(ret);
        }
        */
        
        public static var propsDO:Object = {x:true,y:true,rotation:true,scaleX:true,scaleY:true,alpha:true};
        
        public var target:Object;               // The object to be tweened.
        public var duration:Number;             // The duration of the tween in milliseconds.
        public var ease:Function;               // This is the easing function
        public var easeParam:Object;            // This is an extra parameter you can pass to the easing function
        public var onComplete:Function;         // This closure will be called when the Tween finishes
        public var onChange:Function;           // This closure will be called when the Tween updates its values (every tick/frame)
        public var data:Object;                 // Any custom data you want to attach to the Tween (this doesn't affect its behavior in any way)
        public var nextTween:Tween;             // Used if you want to chain another tween. The chained tween will be set to pause=false when the current Tween finishes.
        public var frameBased:Boolean = false;  // Use frame based timing instead of real time
        public var delay:Number=0;              // Delay the tween by x number of milli-seconds
        public var loop:Boolean=false;          // Loops the twee if true
        public var fastTransform:Boolean=true;  // Use matrix math for display object properties (better to keep it true always)
        
        protected var invalid:Boolean;
        protected var next:Tween; // linked list
        protected var prev:Tween; // linked list
        protected var _position:Number=0;
        protected var _paused:Boolean=true;
        protected var startMatrix:Matrix;
        protected var deltaMatrix:Matrix;
        protected var transform:Transform;
        protected var targetDO:DisplayObject;
        protected var firstProp:Prop;
        protected var props:Object;
        
        /**
         * Create a new Tween.
         * @param duration The duration of the tween in milliseconds.
         * @param target The DisplayObject to be tweened.
         * @param props An Object containing the properties and values that should be tweened to.
         * @param quickSet An Object containing properties for the tween including paused, ease, onComplete, loop, delay, and nextTween.
         */
        public function Tween(duration:Number, target:Object=null, props:Object=null, quickSet:Object=null) {
            this.duration = duration;
            this.target = target;
            if (target is DisplayObject) {
                targetDO = DisplayObject(target);
                transform = targetDO.transform;
            }
            this.props = props;
            if (quickSet) { this.quickSet(quickSet); }
            if (quickSet == null || quickSet.paused == null) { this.paused = false; }
        }
        
        public function set position(value:Number):void {
            updatePosition(value+delay-_position);
        }
        public function get position():Number {
            return _position-delay;
        }
        
        public function get paused():Boolean {
            return _paused;
        }
        public function set paused(value:Boolean):void {
            if (value == _paused) { return; }
            _paused = value;
            if (value) {
                removeTween(this); // When the tween is complete, it is immediately removed.
            } else {
                if (firstTween) { // Insert this tween at the front of the tween list.
                    firstTween.prev = this;
                    next = firstTween;
                }
                firstTween = this;
                if (_position >= delay + duration) { _position = 0; }
            }
        }
        
        public function reset():void {
            _position = 0;
        }
        
        public function quickSet(props:Object):void {
            for (var name:String in props) {
                this[name] = props[name];
            }
        }
        
        protected function constructProp(name:String):Prop {
            var prop:Prop = new Prop();
            prop.name = name;
            prop.prev = null;
            if (firstProp) { firstProp.prev = prop; }
            prop.next = firstProp;
            return firstProp = prop;
        }
        
        protected function init():void {
            var useMatrix:Boolean = false
            for (var name:String in props) {
                if (fastTransform && transform && propsDO[name]) { useMatrix=true; continue; }
                var prop:Prop = constructProp(name);
                prop.delta = props[name]-(prop.start = target[name]);
            }
            if (useMatrix) {
                startMatrix = new Matrix(targetDO.scaleX,targetDO.rotation*degToRad,targetDO.alpha,targetDO.scaleY,targetDO.x,targetDO.y);
                deltaMatrix = new Matrix(isNaN(props.scaleX) ? 0 : props.scaleX-startMatrix.a,
                                         isNaN(props.rotation) ? 0 : (props.rotation-targetDO.rotation)*degToRad,
                                         isNaN(props.alpha) ? 0 : props.alpha-startMatrix.c,
                                         isNaN(props.scaleY) ? 0 : props.scaleY-startMatrix.d,
                                         isNaN(props.x) ? 0 : props.x-startMatrix.tx,
                                         isNaN(props.y) ? 0 : props.y-startMatrix.ty);
            }
            props = null;
        }
        
        protected function updatePosition(value:Number):void {
            // Check to see if the target went out of scope. If so, stop advancing the tween.
            if (target == null) { 
                paused = true; 
                complete = true; 
                return;
            }
            
            _position += value;
            if (_position <= delay) { return }
            if (props) { init(); }
            
            var ratio:Number =  (_position-delay)/duration;
            var complete:Boolean = (ratio >= 1);
            if (complete) { ratio = 1; _position = duration+delay; }
            if (ease != null) { ratio = (easeParam == null) ? ease(ratio,0,1,1) : ease(ratio, 0,1,1, easeParam); }
            
            if (startMatrix) {
                var r:Number = startMatrix.b+deltaMatrix.b*ratio;
                if (r) {
                    var c:Number = Math.cos(r);
                    var s:Number = Math.sin(r);
                } else {
                    c = 1;
                    s = 0;
                }
                workingMatrix.a = c*startMatrix.a+deltaMatrix.a*ratio;
                workingMatrix.b = s;
                workingMatrix.c = -s;
                workingMatrix.d = c*startMatrix.d+deltaMatrix.d*ratio;
                workingMatrix.tx = startMatrix.tx+deltaMatrix.tx*ratio;
                workingMatrix.ty = startMatrix.ty+deltaMatrix.ty*ratio;
                transform.matrix = workingMatrix;
                if (deltaMatrix.c) { targetDO.alpha = startMatrix.c+deltaMatrix.c*ratio; }
            }
            
            var prop:Prop = firstProp;
            while (prop) {
                target[prop.name] = prop.start + prop.delta*ratio;
                prop = prop.next;
            }
            
            if (onChange != null) { onChange(this); }
            if (complete) {
                if (loop) { reset(); }
                else { paused = true; } 
                if (nextTween) { nextTween.paused = false; }
                if (onComplete != null) { onComplete(this); }
            }
        }
    }
}

final class Prop {
    public var next:Prop;
    public var prev:Prop;
    
    public var name:String;
    public var start:Number;
    public var delta:Number;
}