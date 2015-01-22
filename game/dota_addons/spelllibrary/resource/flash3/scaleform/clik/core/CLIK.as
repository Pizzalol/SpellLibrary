/**
 * A global singleton for the CLIK framework that initializes the various CLIK subsystems (PopUpManager, FocusHandler, etc...).
 */

/**************************************************************************

Filename    :   CLIK.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.core 
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventPhase;
    import flash.utils.Dictionary;
    
    import scaleform.clik.managers.FocusHandler;
    import scaleform.clik.managers.PopUpManager;
    
    import scaleform.gfx.Extensions;
    
    dynamic public class CLIK 
    {
    // Constants:
        
    // Public Properties:
        /** Reference to the Stage since this static class is not part of the Display List. */
        public static var stage:Stage;
        /** true if this class has been initialized; false otherwise. */
        public static var initialized:Boolean = false;
        
        /** true if CLIK FocusHandler should never set focus to null or Stage. false to follow the default Flash focus behavior. */
        public static var disableNullFocusMoves:Boolean = false;
        /** true if CLIK FocusHandler should never set focus to "dynamic" TextFields. false to follow the default Flash focus behavior. */
        public static var disableDynamicTextFieldFocus:Boolean = false;
        /** true if prevent focus moves from TextField -> null. false to allow TextField -> null focus moves. */
        public static var disableTextFieldToNullFocusMoves:Boolean = true;
        /** this option maps the keyboard NumPad to GamePad navigation input events */
        public static var testGamePad: Boolean = false;
        
        /** False by default. True if UIComponent initCallbacks should be fired immediately as they are received. False if each callback should be queued til the end of the frame and then fired in reverse order. */
        public static var useImmediateCallbacks:Boolean = false; 
        
    // Protected Properties:
        /** 
         * Whether the fireInitCallback listener is active (optimization). 
         * @private
         */
        protected static var isInitListenerActive:Boolean = false;
        /** 
         * Whether fireInitCallback() is currently running. Used to avoid multiple fireInitCallback() calls occuring simulatenously
         * which will corrupt the Dictionaries they're sharing.
         * @private
         */
        protected static var firingInitCallbacks:Boolean = false;
        /** 
         * A dictionary of dictionaries so that we can use weak references and order the queue by number of parents.
         * initQueue[ number of parents ] = weak ref dictionary of objects with number of parents[ weak reference to an object as key ] = path to object.
         * @private
         */
        protected static var initQueue:Dictionary;
        /** @private */
        protected static var validDictIndices:Vector.<uint>;
        
    // Initialization:
        public static function initialize( stage:Stage, component:UIComponent ):void {
            if (initialized) { return; }
            
            CLIK.stage = stage;
            Extensions.enabled = true;
            initialized = true;
            
            FocusHandler.init(stage, component);
            PopUpManager.init(stage, false);
            
            initQueue = new Dictionary(true);
            validDictIndices = new Vector.<uint>();
        }
        
    // Public Getter / Setters:
        
    // Public Methods:
        public static function getTargetPathFor(clip:DisplayObjectContainer):String {
            if (!clip.parent) {
                return clip.name;
            }
            else {
                var targetPath:String = clip.name;
                return getTargetPathImpl(clip.parent as DisplayObjectContainer, targetPath);
            }
        }
        
        public static function queueInitCallback( ref:UIComponent ):void {
            var path:String = getTargetPathFor( ref );
            
            // In the unlikely case that we're queuing more callbacks while 
            // fireInitCallback is running, just fire the callback immediately. 
            // This will only occur if C++ interacts with the components immediately following 
            // their callback. If they call anything that causes a .gotoAndPlay(), that call will 
            // be executed immediately, potentially causing more EXIT_FRAME events to be fired simulatenously.
            if ( useImmediateCallbacks || firingInitCallbacks ) {
                Extensions.CLIK_addedToStageCallback( ref.name, path, ref );
            }
            else { // Default behavior.
                var parents:Array = path.split(".");
                var numParents:uint = parents.length - 1;
                var dict:Dictionary = initQueue[ numParents ];
                if (dict == null) {
                    dict = new Dictionary( true );
                    initQueue[numParents] = dict;
                    validDictIndices.push( numParents );
                    if (validDictIndices.length > 1) { 
                        validDictIndices.sort( sortFunc );
                    }
                }
                
                dict[ref] = path;
                if (!isInitListenerActive) {
                    isInitListenerActive = true;
                    stage.addEventListener(Event.EXIT_FRAME, fireInitCallback, false, 0, true);
                }
            }
        }
        
    // Protected Methods:
        /** @private */
        protected static function fireInitCallback(e:Event):void {
            firingInitCallbacks = true;
            stage.removeEventListener(Event.EXIT_FRAME, fireInitCallback, false);
            isInitListenerActive = false;
            
            for (var i:uint; i < validDictIndices.length; i++) {
                var numParents:uint = validDictIndices[i];
                var dict:Dictionary = initQueue[numParents] as Dictionary;
                
                for (var ref:Object in dict) {
                    var comp:UIComponent = ref as UIComponent;
                    Extensions.CLIK_addedToStageCallback(comp.name, dict[comp], comp);
                    dict[comp] = null;
                }        
            }
            
            validDictIndices.length = 0;
            clearQueue(); // Clean up all the keys in the initQueue by removing refs to the dictionaries.
            firingInitCallbacks = false;
        }
        
        /** Removes all of the reference to the Dictionaries used to track callbacks. @private */
        protected static function clearQueue():void {
            for (var numDict:* in initQueue) {
                initQueue[numDict] = null;
            }
        }
        
        /** Basic sorting function for the validDictIndices Vector. @private */
        protected static function sortFunc(a:uint, b:uint):Number {
            if (a < b) { return -1; }
            else if (a > b) { return 1; }
            else { return 0; }
        }
        
        /** @private */
        protected static function getTargetPathImpl(clip:DisplayObjectContainer, targetPath:String = ""):String {
            if (!clip) {
                return targetPath; 
            }
            else {
                var _name:String = (clip.name) ? (clip.name + ".") : "";
                targetPath = _name + targetPath;
                return getTargetPathImpl(clip.parent as DisplayObjectContainer, targetPath);
            }
        }
    }
    
}