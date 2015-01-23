/** 
 * Interface for a CLIK DataProvider.
 */
/**************************************************************************

Filename    :   IDataProvider.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.interfaces {
    
    import flash.events.IEventDispatcher;
    import flash.events.Event;
    
    public interface IDataProvider {
        
    // Public getter / setters:
        function get length():uint;
        
    // Public Methods:
        function requestItemAt(index:uint, callBack:Function=null):Object;
        function requestItemRange(startIndex:int, endIndex:int, callBack:Function=null):Array;
        function indexOf(item:Object, callBack:Function=null):int;
        function cleanUp():void;
        function invalidate(length:uint=0):void;
        
        function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void;
        function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void;
        function dispatchEvent(event:Event):Boolean;
        function hasEventListener(type:String):Boolean;
        function willTrigger(type:String):Boolean;
    }
    
}