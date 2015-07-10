﻿/**************************************************************************

Filename    :   DragManager.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.managers {
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.display.Bitmap;
    import flash.display.IBitmapDrawable;
    import flash.display.BitmapData;
    
    import scaleform.gfx.FocusManager;
    
    import scaleform.clik.events.DragEvent;
    import scaleform.clik.controls.DragSlot;
    import scaleform.clik.interfaces.IDragSlot;
    
    public class DragManager {
        
    // Constants:
        
    // Protected Properties:
        /** Reference to the Stage. */
        protected static var _stage:Stage;
        /** Reference to the Sprite to which all dragged Sprites are attached while being dragged. */
        protected static var _dragCanvas:Sprite;
        /** TRUE if the DragManager has been initialized using init(). FALSE if not. */
        protected static var _initialized:Boolean = false;
        /** TRUE if the DragManager is currently dragging. FALSE if not. */
        protected static var _inDrag:Boolean = false;
        
        /** The data behind the Sprite that is currently being dragged. */
        protected static var _dragData:Object;
        /** Reference to the Sprite being dragged by the DragManager. */
        protected static var _dragTarget:Sprite;
        /** Reference to the original DragSlot that initiated the current drag. */
        protected static var _origDragSlot:IDragSlot;

    // Initialization:
        public static function init(stage:Stage):void {
            if (_initialized) { return; }
            _initialized = true;
            
            DragManager._stage = stage;
            _dragCanvas = new Sprite();
            _dragCanvas.mouseEnabled = _dragCanvas.mouseChildren = false;
            _stage.addChild(_dragCanvas);
            
            _stage.addEventListener(DragEvent.DRAG_START, DragManager.handleStartDragEvent, false, 0, true);
        }
        
    // Public Methods:
        public static function inDrag():Boolean { return _inDrag; }
        
        public static function handleStartDragEvent( e:DragEvent ):void {
            if (e.dragTarget == null || e.dragSprite == null) { return; }
            
            _dragTarget = e.dragSprite;
            _dragData = e.dragData;
            
            // Store a reference to the original DragSlot so it can handle a failed Drag however it wants.
            _origDragSlot = e.dragTarget;
            
            // When we reparent the _dragTarget, we want it in the same global location (otherwise it'll be at 0,0).
            var dest:Point = _dragTarget.localToGlobal(new Point());
            var canvDest: Point = _dragCanvas.localToGlobal(new Point());
            
            // NFM: This should be changed so that original IDragSlot decides what it does with the Sprite rather than
            //      have it immediately removeChild()'d by the DragManager.
            // Remove the Sprite that we're dragging from it's parent.
            // var targetParent:DisplayObjectContainer = _dragTarget.parent as DisplayObjectContainer;
            // if (targetParent) { targetParent.removeChild(_dragTarget); }
            
            // _dragTarget = cloneDisplayObjectAsSprite(_dragTarget);
            _dragCanvas.addChild(_dragTarget);
            
            _dragTarget.x = dest.x - canvDest.x;
            _dragTarget.y = dest.y - canvDest.y;
            
            _inDrag = true;
            _stage.addEventListener(MouseEvent.MOUSE_UP, handleEndDragEvent, false, 0, true);
            
            var dragMC:MovieClip = _dragTarget as MovieClip;
            dragMC.startDrag();
            dragMC.mouseEnabled = dragMC.mouseChildren = false;
            dragMC.trackAsMenu = true; // May not need any of this or cast stuff. Just mouseEnabled = mouseChildren.
        }
        
        public static function handleEndDragEvent( e:MouseEvent ):void {
            _stage.removeEventListener(MouseEvent.MOUSE_UP, handleEndDragEvent, false);
            _inDrag = false;
            
            var isValidDrop:Boolean = false;
            var dropTarget:IDragSlot = findSpriteAncestorOf(_dragTarget.dropTarget) as IDragSlot;
            
            if (dropTarget != null && dropTarget is IDragSlot && dropTarget != _origDragSlot) {
                var dropEvent:DragEvent = new DragEvent(DragEvent.DROP, _dragData, _origDragSlot, dropTarget, _dragTarget);
                isValidDrop = dropTarget.handleDropEvent(dropEvent);
            }
            
            // Regardless of if the drop was valid or not, stop dragging the item around the stage.
            _dragTarget.stopDrag();
            _dragTarget.mouseEnabled = _dragTarget.mouseChildren = true;
            (_dragTarget as MovieClip).trackAsMenu = false;
            _dragCanvas.removeChild(_dragTarget);
            
            // Give the original DragSlot a chance to handle the DRAG_END.
            var dragEndEvent:DragEvent = new DragEvent(DragEvent.DRAG_END, _dragData, _origDragSlot, dropTarget, _dragTarget);
            _origDragSlot.handleDragEndEvent(dragEndEvent, isValidDrop); // NFM: This event isn't being dispatched for perf (reduces the number of IDragSlots who will receive / process the event).
            
            // Have to dispatch the event from one of the dragTargets since this class is static.
            _origDragSlot.dispatchEventAndSound(dragEndEvent); 
            
            // Reset the drag references.
            _dragTarget = null;
            _origDragSlot = null;
        }
        
    // Protected Methods:
        protected static function handleStageAddedEvent(e:Event):void {
            // NFM: We may need something like this for the DragSlot but we don't want it to intersect with a PopUp or anything.
            //      We'll probably need a special interface that uses the first few depths for DragManager / PopupManager / etc...
        }
        
        // Finds a IDragSlot ancestor in the display list of the target DisplayObject.
        protected static function findSpriteAncestorOf( obj:DisplayObject ):IDragSlot {
            while (obj && !(obj is IDragSlot)) {
                obj = obj.parent;
            }
            return obj as IDragSlot;
        }
    }
}