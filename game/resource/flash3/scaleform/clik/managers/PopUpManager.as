/**************************************************************************

Filename    :   PopUpManager.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

﻿package scaleform.clik.managers {
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.geom.Point;
    import scaleform.gfx.FocusManager;
    
    public class PopUpManager {
        protected static var initialized:Boolean = false;
        public static function init(stage:Stage, createCanvas: Boolean = true):void {
            if (initialized) { return; }
            PopUpManager._stage = stage;
            
            if(createCanvas)
                checkDefaultPopupCanvasExists();
            
            initialized = true;
        }
        
    // Constants:
    
    // Protected Properties:
        protected static var _stage:Stage;
        protected static var _defaultPopupCanvas:MovieClip;
        
        protected static var _modalMc:Sprite;
        protected static var _modalBg:Sprite;
        
        public static function checkDefaultPopupCanvasExists():void
        {
            if (_defaultPopupCanvas != null)
                return;
            _defaultPopupCanvas = new MovieClip();
            // Listen to children being removed from the _defaultPopupCanvas to track whether we need to actively keep
            // _defaultPopupCanvas on top of everything else.
            _defaultPopupCanvas.addEventListener(Event.REMOVED, handleRemovePopup, false, 0, true);
            _stage.addChild(_defaultPopupCanvas);
        }
        
    // Public Methods:
        public static function show(mc:DisplayObject, x:Number = 0, y:Number = 0, scope:DisplayObjectContainer = null):void {
            if (!_stage) { trace("PopUpManager has not been initialized. Automatic initialization has not occured or has failed; call PopUpManager.init() manually."); return; }
            
            // Remove from existing parent
            if (mc.parent) { mc.parent.removeChild(mc); }
            
            // Reparent to popup canvas layer
            handleStageAddedEvent(null);
            
            
            checkDefaultPopupCanvasExists();
            _defaultPopupCanvas.addChild(mc);
            
            // Move to location by scope
            if (!scope) {
                scope = _stage;
            }
            
            var p:Point = new Point(x, y);
            p = scope.localToGlobal(p);
            mc.x = p.x;
            mc.y = p.y;
            
            _stage.setChildIndex(_defaultPopupCanvas, _stage.numChildren - 1);
            _stage.addEventListener(Event.ADDED, PopUpManager.handleStageAddedEvent, false, 0, true);
        }
        
        public static function showModal(mc:Sprite, mcX:Number = 0, mcY:Number = 0, bg:Sprite = null, controllerIdx:uint = 0, newFocus:Sprite = null):void {
            if (!_stage) { trace("PopUpManager has not been initialized. Automatic initialization has not occured or has failed; call PopUpManager.init() manually."); return; }
            
            checkDefaultPopupCanvasExists();           
            // Remove previous modal mc and bg if applicable
            // - Background is removed via event listener automatically
            if (_modalMc) { 
                _defaultPopupCanvas.removeChild(_modalMc); 
            }
            
            // If mc is null, return (Useful to clear a modal mc)
            if (mc == null) {
                return;
            }
            
            // If bg is null, create an alpha 0 sprite the size of the stage and add it at 0, 0.
            if (bg == null) {
                bg = new Sprite();
                bg.graphics.lineStyle(0, 0xffffff, 0);
                bg.graphics.beginFill(0xffffff, 0);
                bg.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
                bg.graphics.endFill();
            }
            
            // Track current modal mc and bg
            _modalMc = mc;
            _modalBg = bg;
            
            // Reparent to popup canvas layer
            _modalMc.x = mcX;
            _modalMc.y = mcY;
            _defaultPopupCanvas.addChild(_modalBg);
            _defaultPopupCanvas.addChild(_modalMc);
            FocusHandler.getInstance().setFocus(newFocus, controllerIdx, false);
            FocusManager.setModalClip(_modalMc, controllerIdx);
            
            // Get notified when the modal mc is removed for cleanup purposes
            _modalMc.addEventListener(Event.REMOVED_FROM_STAGE, handleRemoveModalMc, false, 0, true);			
            _stage.addEventListener(Event.ADDED, PopUpManager.handleStageAddedEvent, false, 0, true);
        }
        
    // Protected Methods:
        protected static function handleStageAddedEvent(e:Event):void {
            // We make sure that the defaultPopupCanvas is always on top of everything else on the stage
            checkDefaultPopupCanvasExists();
            _stage.setChildIndex(_defaultPopupCanvas, _stage.numChildren - 1);
        }
        
        protected static function handleRemovePopup(e:Event):void {
            removeAddedToStageListener();
        }
        
        protected static function handleRemoveModalMc(e:Event):void {
            
            _modalBg.removeEventListener(Event.REMOVED_FROM_STAGE, handleRemoveModalMc, false);
            if (_modalBg) {
                
                checkDefaultPopupCanvasExists();
                // Remove modal background if applicable
                _defaultPopupCanvas.removeChild(_modalBg);
            }
            
            // Clear tracking variables
            _modalMc = null;
            _modalBg = null;
            
            // Remove from FocusManager
            FocusManager.setModalClip(null);
            
            removeAddedToStageListener();
        }
        
        protected static function removeAddedToStageListener():void {
            
            checkDefaultPopupCanvasExists();
            if (_defaultPopupCanvas.numChildren == 0 && _modalMc == null) { 
                _stage.removeEventListener(Event.ADDED, PopUpManager.handleStageAddedEvent, false);
            }
        }
    }
    
}