/**
    Layout is a component that can be used to layout elements within a context that may change in size and/or scale.
    Layouts can only manage Sprites (and any sub-class thereof) that exist within the same parent. That is, no element
    should be placed within a Layout instance itself, but rather at the same level of that Layout instance. For example,
    having two children at the same level (myWindow.myMovieClip and myWindow.layoutInstance) would allow the layoutInstance
    to manage myMovieClip.
    
    Layout only manages Sprites that have defined the .layoutData property with an instance of the LayoutData class.
    Multiple Layouts may exist within the same parent, provided that each has a unique .identifier property set and that
    all the LayoutData within same-level Sprites also define their .layoutIdentifier property.
    
    NOTE: All managed Sprites must have their registration point in the top left or the Layout's calculations will be incorrect.
    
    More information on the Layout system can be found in the CLIK AS3 User Guide.
    
    <br>
    <br>
    
    <b>Inspectable Properties</b>
    A class that derives from Layout will have the following inspectable properties:
    <ul>
        <li><i>tiedToStageSize</i>: true if this Layout's size should always be updated to match the stage size; false otherwise. </li>
        <li><i>tiedToParent</i>: true if this Layout's size should always be updated to match its parent's size; false otherwise. </li>
        <li><i>hidden</i>:  true if this Layout should be hidden at runtime; false otherwise. Allows for the Layout to have a visible background or placeholder image that will be set to visible = false; immediately at runtime. </li>
    </ul>
    
    <br>
    <br>
    
    <b>States</b>
    The Layout component does not support any states.
    
    <br>
    <br>
    
    <b>Events</b>
    The Layout component does not dispatch any Events.
  */

/**************************************************************************

Filename    :   Layout.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.layout {
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.events.Event;
    import flash.geom.Rectangle;
    
    import scaleform.gfx.Extensions;
    
    import scaleform.clik.constants.LayoutMode;
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.events.ResizeEvent;
    import scaleform.clik.layout.LayoutData;
    
    public class Layout extends Sprite { // Layout extends Sprite so that it can be added to the stage.
        
    // Constants:
        public static const STAGE_ALIGN_CENTER:String = ""; // Since there is no definition in StageAlign for CENTER.
        
    // Public Properties:
        /** 
         * A unique identifer for this Layout to allow multiple Layouts to coexist in the same parent. 
         * LayoutData can be tied to a particular Layout using the Layout's identifier.
         */
        public var identifier:String = null;
        
    // Protected Properties:
        // The size of the Layout.
        protected var _rect:Rectangle = null;
        // true if this Layout's size should be bound to the stage size; false otherwise.
        protected var _tiedToStageSize:Boolean = false;
        // true if this Layout's size should be bound to the size of the parent; false otherwise.
        protected var _tiedToParent:Boolean = false;
        // true if this Layout should be hidden at runtime; false otherwise.
        protected var _hidden:Boolean = false;
        // The parent of this Layout on the Stage. Layout must be added to the Stage to work properly.
        protected var _parent:Sprite = null;
        // A list of Sprites that are currently being managed by the Layout.
        protected var _managedSprites:Vector.<Sprite>;
        // A String representation of the current AspectRatio.
        protected var _aspectRatio:String = "";
        
    // Initialization:
        public function Layout() {
            initialize();
        }
        
        public function initialize():void {
            addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
            _managedSprites = new Vector.<Sprite>();
        }
        
    // Public Getter / Setters:
        /** 
         * The "size" of the layout. Elements within will be laid out according to the x, y, width, and height of this property.
         * If the Layout's width != 0 (tied to a Symbol and placed on Stage), it will use the MovieClip's x, y, width, and height.
         * If the Layout's width == 0 (addChild() without a backing Symbol), it will use the parent's x, y, width, and height.
         * You can also assign a custom Rectangle using the .rect property.
         */
        public function get rect():Rectangle { return _rect; }
        public function set rect(value:Rectangle):void { 
            _rect = value; 
        }
        
        /** true if this Layout's size should always be updated to match the stage size; false otherwise. */
        [Inspectable(defaultValue="false")]
        public function get tiedToStageSize():Boolean { return _tiedToStageSize; }
        public function set tiedToStageSize(value:Boolean):void { 
            if (value == _tiedToStageSize) { return;}
            _tiedToStageSize = value;
            _tiedToParent = false;
             
            // Make sure we've been added to the stage first. If not, it will be handled in handleAddedToStage().
            if (stage != null) { 
                // Faster than properly checking for a Listener for this particular Layout.
                stage.removeEventListener(Event.RESIZE, handleStageResize, false);
                if (_tiedToStageSize) {
                    stage.addEventListener(Event.RESIZE, handleStageResize, false, 0, true); 
                    updateAspectRatio();
                }
            }
        }
        
        /** true if this Layout's size should always be updated to match its parent's size; false otherwise. */
        [Inspectable(defaultValue="false")]
        public function get tiedToParent():Boolean { return _tiedToParent; }
        public function set tiedToParent(value:Boolean):void { 
            if (value == _tiedToParent) { return;}
            _tiedToParent = value;
            _tiedToStageSize = false;
             
            if (_parent != null) { 
                // Faster than properly checking for a Listener for this particular Layout.
                _parent.removeEventListener(ResizeEvent.RESIZE, handleParentResize, false);
                if (_tiedToParent) {
                    _parent.addEventListener(ResizeEvent.RESIZE, handleParentResize, false, 0, true); 
                }
            }
        }
        
        /** 
         * true if this Layout should be hidden at runtime; false otherwise. Allows for the Layout to have
         * a visible background or placeholder image that will be set to visible = false; immediately at runtime. 
         */
        [Inspectable(defaultValue="true")]
        public function get hidden():Boolean { return _hidden; }
        public function set hidden(value:Boolean):void { 
            _hidden = value;
            visible = !_hidden;
        }
        
        /** @exclude */
        override public function get width():Number { return super.width; }
        override public function set width(value:Number):void { 
            super.width = value;
            if (value > 0) { invalidate(); }
        }
        
        /** @exclude */
        override public function get height():Number { return super.height; }
        override public function set height(value:Number):void { 
            super.height = value;
            if (value > 0) { invalidate() }
        }
        
        /** @exclude */
        override public function get scaleX():Number { return super.scaleX }
        override public function set scaleX(value:Number):void {
            super.scaleX = value;
            invalidate();
        }
        
        /** @exclude */
        override public function get scaleY():Number { return super.scaleY }
        override public function set scaleY(value:Number):void {
            super.scaleY = value;
            invalidate();
        }
    
    // Public Methods:
        /** Update the layout by reflowing the managed Sprites */
        public function reflow():void {
            for (var i:uint = 0; i < _managedSprites.length; i++) {
                var spr:Sprite = _managedSprites[i];
                var ld:LayoutData = spr["layoutData"] as LayoutData; // Sprites with null "layoutData" will never be added to Layout's managed list.
                
                // Store these values once for reuse.
                var alignH:String = ld.alignH;
                var alignV:String = ld.alignV;
                
                // If this Layout is tied to the stage size, then users can define their own hash table with values. 
                var offsetH:Number = (_tiedToStageSize && ld.offsetHashH[_aspectRatio] != undefined) ? ld.offsetHashH[_aspectRatio] : ld.offsetH;
                var offsetV:Number = (_tiedToStageSize && ld.offsetHashV[_aspectRatio] != undefined) ? ld.offsetHashV[_aspectRatio] : ld.offsetV;
                
                // Cache a reference to the relativeToH Sprite, if valid.
                var relativeH:String = ld.relativeToH;
                var relHObject:Sprite = (relativeH != null) ?  _parent.getChildByName( relativeH ) as Sprite : null;;
                
                // Cache a reference to the relativeToV Sprite, if valid.
                var relativeV:String = ld.relativeToV;
                var relVObject:Sprite = (relativeV != null) ? _parent.getChildByName( relativeV ) as Sprite : null;
                
                if (alignH != LayoutMode.ALIGN_NONE) { 
                    if (alignH == LayoutMode.ALIGN_LEFT) {
                        // The object will be aligned to our rect. If the offset is -1, use it's offset
                        // from the Layout on the Stage.
                        if (relHObject == null) {
                            spr.x = rect.x + offsetH;
                        }
                        // The object will be aligned to relHObject. If the offset is -1, use it's offset 
                        // from the Sprite on the Stage.
                        else {
                            spr.x = relHObject.x - spr.width + offsetH;
                        }
                    }
                    else if (alignH == LayoutMode.ALIGN_RIGHT) {
                        if (relHObject == null) {
                            spr.x = (rect.width - spr.width) + offsetH;
                            // If this Layout is tied to the Stage and the visibleRect changes and we're 
                            // stage.align  == CENTER, then the element will need to be further shifted by 
                            // the .x of the visibleRect.
                            if (_tiedToStageSize && (stage.align == STAGE_ALIGN_CENTER || stage.align == StageAlign.TOP || stage.align == StageAlign.BOTTOM)) {
                                spr.x += rect.x;
                            }
                        }
                        // The object will be aligned to relVObject. If the offset is -1, use it's offset from 
                        // the Sprite on the Stage.
                        else {
                            spr.x = relHObject.x + relHObject.width + offsetH;
                        }
                    }
                    else if (alignH == LayoutMode.ALIGN_CENTER) { 
						spr.x = (rect.width / 2 + rect.x) - ((spr.width/2) + offsetH);
                    }
                }
                
                if (alignV != LayoutMode.ALIGN_NONE) { 
                    if (alignV == LayoutMode.ALIGN_TOP) {
                        // The object will be aligned to our rect. If the offset is -1, use it's offset from the Layout on the Stage.
                        if (relVObject == null) {
                            spr.y = rect.y + offsetV;
                        }
                        // The object will be algined to relVObject. If the offset is -1, use it's offset from the Sprite on the Stage.
                        else {
                            spr.y = relVObject.y - spr.height + offsetV;
                        }
                    }
                    else if (alignV == LayoutMode.ALIGN_BOTTOM) {
                        if (relVObject == null) {
                            spr.y = (rect.height - spr.height) + offsetV;
                            // If this Layout is tied to the Stage and the visibleRect changes and we're 
                            // stage.align  == CENTER, then the element will need to be further shifted by 
                            // the .x of the visibleRect.
                            if (_tiedToStageSize && (stage.align == STAGE_ALIGN_CENTER || stage.align == StageAlign.TOP || stage.align == StageAlign.BOTTOM)) {
                                spr.y += rect.y;
                            }
                        }
                        // The object will be algined to relVObject. If the offset is -1, use it's offset from the Sprite on the Stage.
                        else {
                            spr.y = relVObject.y + relVObject.height + offsetV;
                        }
                    }
					else if (alignV == LayoutMode.ALIGN_CENTER) { 
						spr.y = (rect.height / 2 + rect.y) - ((spr.height/2) + offsetV);
                    }
                }
            }
        }
        
        /** 
         * Resets the Layout by clearing its list of managed Sprites, searching for new Sprites with LayoutData 
         * and recaculating offsets / reflowing those new Sprites from scratch. 
         */
        public function reset():void {
            if (stage == null) { return; }
            _managedSprites = new Vector.<Sprite>;
            configUI();
        }
        
        /** 
         * Sorts the managed Sprite list by their layoutData.layoutIndex property which defines the order in which
         * the layout is applied. This should be called if any layoutIndex is changed after the initial setup
         * of the Layout.
         */
        public function resortManagedSprites():void {
            var list:Vector.<Sprite> = new Vector.<Sprite>()
            while (_managedSprites.length >= 1) {
                insertIntoSortedVector( _managedSprites.pop(), list );
            }
            _managedSprites = list;
        }
        
    // Protected Methods:
        // Internal method for invalidating the Layout.
        protected function invalidate():void {
            addEventListener(Event.RENDER, handleStageInvalidation, false, 0, true);
            if (stage) { stage.invalidate(); }
        }
        
        protected function handleStageInvalidation(e:Event):void {
            removeEventListener(Event.RENDER, handleStageInvalidation, false);
            _rect.x = x;
            _rect.y = y;
            _rect.width = width;
            _rect.height = height;
            reflow();
        }
        
        protected function handleAddedToStage(e:Event):void {
            configUI();
        }
        
        protected function configUI():void {
            removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false);
            _parent = parent as MovieClip;
            
            visible = !_hidden;
            
            // If the layout is placed on the stage, use it's properties for laying out elements within it.
            if (width > 0 && height > 0) { 
                _rect = new Rectangle(x, y, width, height);
            }
            
            // By default, use the parent's width and height unless another 'rect' is provided.
            if (_rect == null) {
                // If the layout should be tied to the stage, have it match the stageWidth and stageHeight.
                if (_tiedToStageSize) {
                    _rect = (Extensions.enabled) ? Extensions.visibleRect : new Rectangle(0, 0, stage.stageWidth, stage.stageHeight); 
                }
                // Otherwise, use the _parent's size.
                else {
                    _rect = new Rectangle(0, 0, _parent.width, _parent.height);
                    _tiedToParent = true;
                }
            }
            
            // Delay the analysis of other Sprites a frame while they initialize. 
            // No good way to discern whether this was a result of a call to addChild() (which could call 
            // analyzeSprites() immediately) or adding to the Layout to the stage during design..
            addEventListener(Event.ENTER_FRAME, handleFirstEnterFrame, false, 0, true);
            
            _parent.addEventListener(Event.ADDED_TO_STAGE, handleSpriteAddedToParent, false, 0, true);
            _parent.addEventListener(Event.REMOVED_FROM_STAGE, handleSpriteRemovedFromParent, false, 0, true);
            
            // Listen to resize events from the _parent if stage if this Layout is tied to the stage's size.
            if (_tiedToStageSize) { 
                stage.addEventListener(Event.RESIZE, handleStageResize, false, 0, true);
            }
            // Listening for RESIZE events from the Parent may not be necessary in all cases, but 
            // the Event has to be implemented by the parent to track resizes to work, so we'll leave it to
            // the discretion of the user.
            else if (_tiedToParent){
                // The parent must implement dispatching this event when it's size changes or 
                // this Layout will not know that it's size has changed.
                _parent.addEventListener(ResizeEvent.RESIZE, handleParentResize, false, 0, true);
            }
        }
        
        // Used to delay the analysis of other Sprites a frame while they initialize.  
        protected function handleFirstEnterFrame(e:Event):void {
            removeEventListener(Event.ENTER_FRAME, handleFirstEnterFrame, false);
            analyzeSpritesOnStage();
        }
        
        // Analyzes the Sprites currently within the Parent and evaluates them for layout management
        // based on their "layoutData" property
        protected function analyzeSpritesOnStage():void {
            for (var i:uint = 0; i < _parent.numChildren; i++) {
                var spr:Sprite = _parent.getChildAt(i) as Sprite;
                if (spr != this) { // We don't want the Layout to manage itself.
                    evaluateLayoutForSprite(spr);
                }
            }
            reflow();
        }
        
        // Listener for Sprites being added to the parent.
        protected function handleSpriteAddedToParent(e:Event):void {
            var spr:Sprite = e.target as Sprite;
            if (spr.parent != _parent) { return; } // If the Sprite is of a different parent, ignore it.
            evaluateLayoutForSprite(spr);
            reflow();
        }
        
        // Listener for Sprites being removed from the parent.
        protected function handleSpriteRemovedFromParent(e:Event):void {
            var spr:Sprite = e.target as Sprite;
            if (spr.parent != _parent) { return; } // If the Sprite is of a different parent, ignore it.
            for (var i:uint = 0; i < _managedSprites.length; i++) {
                if (_managedSprites[i] == spr) { 
                    _managedSprites.splice(i, 1);
                }
            }
        }
        
        protected function handleParentResize(e:Event):void {
            _rect.width = _parent.width
            _rect.height = _parent.height;
            reflow();
        }
        
        protected function handleStageResize(e:Event):void {
            updateAspectRatio();
            reflow();
        }
        
        protected function updateAspectRatio():void {
            if (Extensions.enabled) { 
                _rect = Extensions.visibleRect; 
                var ar:Number = rect.width / rect.height;
                switch (ar) {
                    case (4 / 3):
                        _aspectRatio = LayoutData.ASPECT_RATIO_4_3;
                        break;
                    case (16 / 9):
                        _aspectRatio = LayoutData.ASPECT_RATIO_16_9;
                        break;
                    case (16 / 10):
                        _aspectRatio = LayoutData.ASPECT_RATIO_16_10;
                        break
                    default:
                        break;
                }
            }
            else {
                _rect.width = stage.stageWidth;
                _rect.height = stage.stageHeight;
            }
        }
        
        // NFM: Consider adding logic to UIComponent that fires an event when the layout properties are changed
        //      so we can update the _managedObjects list and reflow appropriately. For now, all settings must 
        //      be in place before the Layout is added to the parent.
        protected function evaluateLayoutForSprite(spr:Sprite):void { 
            if (spr == null) { return; }
            var lData:LayoutData = null;
            lData = spr["layoutData"];
            // Only add Sprites that have "layoutData" and have no layoutIdentifier or this layoutIdentifier set.
            if (lData != null && (lData.layoutIdentifier == null || lData.layoutIdentifier == identifier)) { 
                insertIntoSortedVector(spr, _managedSprites);
                calculateOffsets(spr);
            }
        }
        
        protected function insertIntoSortedVector(spr:Sprite, list:Vector.<Sprite>):void {
            // If there's no other _managedObjects or if we don't have a particular layoutIndex (-1), just add us to the end.
            var lIndex:int = (spr["layoutData"] as LayoutData).layoutIndex;
            if (list.length == 0 || lIndex == -1) {
                list.push(spr);
            }
            else {
                var inserted:Boolean = false;
                for (var i:uint = 0; i < list.length && !inserted; i++) {
                    var ld:LayoutData = list[i]["layoutData"] as LayoutData;
                    if (lIndex >= 0 && lIndex <= ld.layoutIndex) {
                        list.splice(i, 0, spr);
                        inserted = true;
                    }
                }
                // If we didn't find a spot for it, add it to the end.
                if (!inserted) {
                    list.push(spr);
                }
            }
        }
        
        protected function calculateOffsets(spr:Sprite):void {
            var ld:LayoutData = spr["layoutData"] as LayoutData;
            
            // Store these values once for reuse.
            var alignH:String = ld.alignH;
            var alignV:String = ld.alignV;
            
            // Cache a reference to the relativeToH Sprite, if valid.
            var relativeH:String = ld.relativeToH;
            var relHObject:Sprite = (relativeH != null) ?  _parent.getChildByName( relativeH ) as Sprite : null;;
            
            // Cache a reference to the relativeToV Sprite, if valid.
            var relativeV:String = ld.relativeToV;
            var relVObject:Sprite = (relativeV != null) ? _parent.getChildByName( relativeV ) as Sprite : null;
            
            // If no offsetH was provided in the LayoutData, the current horizontal offset will become the new offsetH.
            if (ld.offsetH == -1) { 
                if (alignH != LayoutMode.ALIGN_NONE) { 
                    if (alignH == LayoutMode.ALIGN_LEFT) {
                        // If the offset is -1, use its offset from the Layout on the Stage.
                        if (relHObject == null) {
                            ld.offsetH = spr.x - rect.x;
                        }
                        // The object will be algined to relHObject. If the offset is -1, use its offset from the Sprite on the Stage.
                        else {
                            ld.offsetH = spr.x - (relHObject.x + relHObject.width);
                        }
                    }
                    else if (alignH == LayoutMode.ALIGN_RIGHT) {
                        // If the offset is -1, use it's offset from the Layout on the Stage.
                        if (relHObject == null) {
                            ld.offsetH = (spr.x + spr.width)- rect.width;
                        }
                        // The object will be algined to relVObject. If the offset is -1, use it's offset from the Sprite on the Stage.
                        else {
                            ld.offsetH = spr.x - relHObject.x;
                        }
                    }
                }
            }
            // If no offsetV was provided in the LayoutData, the current vertical offset will become the new offsetV.
            if (ld.offsetV == -1) { 
                if (alignV != LayoutMode.ALIGN_NONE) { 
                    if (alignV == LayoutMode.ALIGN_TOP) {
                        // If the offset is -1, use its offset from the Layout on the Stage.
                        if (relVObject == null) {
                            ld.offsetV = spr.y - rect.y;
                        }
                        // The object will be algined to relVObject. If the offset is -1, use its offset from the Sprite on the Stage.
                        else {
                            ld.offsetV = spr.y - (relVObject.y + relVObject.height);
                        }
                    }
                    else if (alignV == LayoutMode.ALIGN_BOTTOM) {
                        // If the offset is -1, use it's offset from the Layout on the Stage.
                        if (relVObject == null) {
                            ld.offsetV = (spr.y + spr.height) - rect.height;
                        }
                        // The object will be algined to relVObject. If the offset is -1, use it's offset from the Sprite on the Stage.
                        else {
                            ld.offsetV = spr.y - relVObject.y;
                        }
                    }
                }
            }
        }
    }
}
