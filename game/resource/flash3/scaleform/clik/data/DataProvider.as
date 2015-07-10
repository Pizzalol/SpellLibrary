/**
 * A data provider for many of the CLIK components, often generated from an Array of data. Provides extra functionality and events for data changes.
 */
/**************************************************************************

Filename    :   DataProvider.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.data {
    
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.events.Event;
    
    import scaleform.clik.interfaces.IDataProvider;
    
    [Event(name="change", type="flash.events.Event")]
    
    dynamic public class DataProvider extends Array implements IDataProvider, IEventDispatcher {
        
    // Constants:
        
    // Public Properties:
        
    // Protected Properties:
        protected var dispatcher:EventDispatcher;
        
    // Initialization:
        public function DataProvider(source:Array = null) {
            dispatcher = new EventDispatcher(this);
            parseSource(source);
        }
        
    // Public getter / setters:
        
    // Public Methods:
        public function indexOf(item:Object, callBack:Function=null):int {
            var index:int = super.indexOf(item);
            if (callBack != null) { callBack(index); }
            return index;
        }
        
        public function requestItemAt(index:uint, callBack:Function=null):Object {
            var item:Object = this[index];
            if (callBack != null) { callBack(item); }
            return item;
        }
        
        public function requestItemRange(startPosition:int, endPosition:int, callBack:Function=null):Array {
            var items:Array = this.slice(startPosition, endPosition+1);
            if (callBack != null) { callBack(items); }
            return items;
        }
        
        public function cleanUp():void {
            this.splice(0,length);
        }
        
        public function invalidate(length:uint=0):void {
            // The length parameter is in the Array DataProvider for compatibility purposes, and is not used.
            dispatcher.dispatchEvent(new Event(Event.CHANGE));
        }
        
        /** Convenient way to set the source from native code or game script without using the constructor. */
        public function setSource(source:Array):void {
            parseSource(source);
        }
        
        public function toString():String {
            return "[CLIK DataProvider " + this.join(",") + "]";
        }
        
    // Protected Methods:
        protected function parseSource(source:Array):void {
            if (source == null) { return; }
            var l:uint = source.length;
            for (var i:uint=0; i<l; i++) {
                this[i] = source[i];
            }
        }
    
    // EventDispatcher Mix-in    
        public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
            dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
            dispatcher.removeEventListener(type, listener, useCapture);
        }
        public function dispatchEvent(event:Event):Boolean {
            return dispatcher.dispatchEvent(event);
        }
        public function hasEventListener(type:String):Boolean {
            return dispatcher.hasEventListener(type);
        }
        public function willTrigger(type:String):Boolean {
            return dispatcher.willTrigger(type);
        }
        
    }
    
}