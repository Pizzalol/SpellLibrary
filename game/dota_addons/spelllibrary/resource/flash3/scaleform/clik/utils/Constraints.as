/**
 * The Constraints utility helps symbols scale and align the assets contained within them. Elements can be added to a Constraints instance, and they will be reflowed when the {@code update(width,height)} method is called.
 *
 * This utility supports both re-scaling and counter-scaling methods.  Rescaling occurs when the component is scaled back to 100%, and the assets are reflowed and scaled to look correct. Counter-scaling occurs when the component is left at its transformed size, and the assets are scaled inversely to the parent clip.
 */

/**************************************************************************

Filename    :   Constraints.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.utils {
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.text.TextField;

    import scaleform.clik.constants.ConstrainMode;
    import scaleform.clik.controls.ScrollBar;
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.events.ResizeEvent;
    
    public class Constraints extends EventDispatcher {
    
    // Constants:
        public static const LEFT:uint = 1;
        public static const RIGHT:uint = 2;
        public static const TOP:uint = 4;
        public static const BOTTOM:uint = 8;
        public static var ALL:uint = LEFT | RIGHT | TOP | BOTTOM;
        
        public static const CENTER_H:uint = 16;
        public static const CENTER_V:uint = 32;
        
    // Public Properties:    
        /**
         * The component that owns the constraints, and which is the direct parent to the display objects
         * getting constrained.
         */
        public var scope:DisplayObject;
        
        /**
         * Determines how the component scales its children.
         */
        public var scaleMode:String = ConstrainMode.COUNTER_SCALE;
        
        /**
         * The x scale factor of the parent, which is a composite scale that originates from the stage, factoring
         * in all components or clips above it that use a constraints. This value does not include the current scope
         * scale value.
         * @default 1
         */
        public var parentXAdjust:Number = 1;
        public var parentYAdjust:Number = 1;
        
    // Private Properties:
        //LM: Consider using Dictionary instead for faster lookups
        protected var elements:Object;
        protected var elementCount:int = 0;
        /**
         * A reference to the constraints that belong to the first container above the scope that specifies
         * a Constraints of its own. This is found by calling {@code addToParentConstraints()}.
         */
        protected var parentConstraints:Constraints;
        
        /**
         * The last width set on this constraints by the scope. This value is stored off in order to preserve
         * it if the parent constraints updates its scale value. The component needs to be updated with its last
         * known width and the new scale value.
         */
        public var lastWidth:Number = NaN;
        public var lastHeight:Number = NaN;
    
    // Initialization:
        /**
         * Create a new Constraints instance to assist in the positioning and scaling of an asset inside a component.
         * Note that it is VERY important that constraints instances in components are created before the super() call
         * to ensure parent constraints are initialized.
         * @param scope The component scope which contains the constrained asset.
         * @param scaleMode Determines how the component scales its elements. The default is counter-scaling.
         */
        public function Constraints(scope:Sprite, scaleMode:String="counterScale") {
            this.scope = scope;
            this.scaleMode = scaleMode;
            elements = {};
            
            lastWidth = scope.width;
            lastHeight = scope.height;
            
            scope.addEventListener(Event.ADDED_TO_STAGE, handleScopeAddedToStage, false, 0, true);
            scope.addEventListener(Event.REMOVED_FROM_STAGE, handleScopeAddedToStage, false, 0, true);
        }
    
    // Public Methods:
        public function addElement(name:String, clip:DisplayObject, edges:uint):void {
            if (clip == null) { return; }
            
            // Determine the scope width.  If it is the stage, use the full swf size, otherwise we get 0,0.
            var w:Number = scope.width;
            var h:Number = scope.height;
            if (scope.parent != null && scope.parent is Stage) {
                w = scope.stage.stageWidth;
                h = scope.stage.stageHeight;
            }
            
            var element:ConstrainedElement = new ConstrainedElement(
                clip, edges,
                clip.x, 
                clip.y,
                w/scope.scaleX - (clip.x + clip.width), 
                h/scope.scaleY - (clip.y + clip.height),
                clip.scaleX, clip.scaleY
            );
            
            if (elements[name] == null) { elementCount++; }
            elements[name] = element;
        }
        
        public function removeElement(name:String):void {
            if (elements[name] != null) { elementCount--; }
            delete elements[name];
        }
        
        public function removeAllElements():void {
            for (var name:String in elements) { 
                if (elements[name] is ConstrainedElement) {
                    elementCount--;
                    delete elements[name];
                }
            }
        }
        
        /**
         * Get the contraints rules for a given object.
         * @param clip A reference to the DisplayObject (Sprite or TextField) the contraints apply to.
         * @returns the constraints rules object for the specified clip
         */
        public function getElement(name:String):ConstrainedElement {
            return elements[name] as ConstrainedElement;
        }
        
        /**
         * Update the reference to a display object. This is required if the component exists on multiple
         * frames, as Flash will re-assign the reference, but not update external references, such as 
         * the {@code ConstrainedElement}.
         * @param name The name of the clip in the ConstrainedElement
         * @param clip The new reference to the display object.
         */
        public function updateElement(name:String, clip:DisplayObject):void {
            if (clip == null) { return; }
            var element:ConstrainedElement = elements[name] as ConstrainedElement;
            if (element == null) { return; }
            element.clip = clip;
        }
        
        /**
         * Determine the x scale adjustment factoring in the parent scale and the scope scale. Used internally
         * but is also requested by child constraints when determining their own scale.
         */
        public function getXAdjust():Number {
            if (scaleMode == ConstrainMode.REFLOW) { return parentXAdjust; }
            return parentXAdjust / scope.scaleX;
        }
    
        public function getYAdjust():Number {
            if (scaleMode == ConstrainMode.REFLOW) { return parentYAdjust; }
            return parentYAdjust / scope.scaleY;
        }
        
        /**
         * Change the width/height and x/y of each registered component based on the scope's updated size and the constraint rules.
         * This is usually called by the scope when its size changes, but may also be called when a parent constraints changes its
         * scale value.
         * @param width The new width of the scope component.
         * @param height The new height of the scope component.
         */
        public function update(width:Number, height:Number):void {
            lastWidth = width;
            lastHeight = height;
            if (elementCount == 0) { return; }
            
            // Deterine the counter-scale factor
            var xAdjust:Number = getXAdjust();
            var yAdjust:Number = getYAdjust();
            
            var counterScale:Boolean = (scaleMode == ConstrainMode.COUNTER_SCALE);
            
            // Loop through elements, and adjust each one
            for (var n:String in elements) {
                var element:ConstrainedElement = elements[n] as ConstrainedElement;
                var edges:uint = element.edges;
                var clip:DisplayObject = element.clip;
                
                if (counterScale) {
                    
                    clip.scaleX = element.scaleX * xAdjust;
                    clip.scaleY = element.scaleY * yAdjust;
                    
                    if ((edges & Constraints.CENTER_H) == 0) {
                        if ((edges & Constraints.LEFT) > 0) {
                            clip.x = element.left * xAdjust;
                            if ((edges & Constraints.RIGHT) > 0) {
                                var nw:Number = (width - element.left - element.right);
                                if (!(clip is TextField)) { nw = nw * xAdjust; }
                                clip.width = nw;
                            }
                        } else if ((edges & Constraints.RIGHT) > 0) {
                            clip.x = (width - element.right) * xAdjust - clip.width;
                        }
                    }
                    if ((edges & Constraints.CENTER_V) == 0) {
                        if ((edges & Constraints.TOP) > 0) {
                            clip.y = element.top * yAdjust;
                            if ((edges & Constraints.BOTTOM) > 0) {
                                var nh:Number = height - element.top - element.bottom;
                                if (!(clip is TextField)) { nh = nh * yAdjust; }
                                clip.height = nh;
                            }
                        } else if ((edges & Constraints.BOTTOM) > 0) {
                            clip.y = (height - element.bottom) * yAdjust - clip.height;
                        }
                    }
                }
            
                // Use reflowing
                else {
                    //LM: Might have to use xAdjust/yAdjust because a parent could use counterScaling.
                    //LM: Adjusted scale to accommodate counter-scaling.
                    if ((edges & Constraints.CENTER_H) == 0 && (edges & Constraints.RIGHT) > 0) {
                        if ((edges & Constraints.LEFT) > 0) {
                            clip.width = width - element.left - element.right; // Stretch
                        } else {
                            clip.x = width - clip.width - element.right; // Just move
                        }
                    }

                    if ((edges & Constraints.CENTER_V) == 0 && (edges & Constraints.BOTTOM) > 0) {
                        if ((edges & Constraints.TOP) > 0) {
                            clip.height = height - element.top - element.bottom;
                        } else {
                            clip.y = height - clip.height - element.bottom;
                        }
                    }
                    
                    if (clip is UIComponent) {
                        (clip as UIComponent).validateNow();
                    }
                }
                
                if ((edges & Constraints.CENTER_H) > 0) {
                    clip.x = (width * 0.5 * xAdjust) - (clip.width * 0.5);
                }
                
                if ((edges & Constraints.CENTER_V) > 0) {
                    clip.y = (height * 0.5 * yAdjust) - (clip.height * 0.5);
                }
                
            }
            
            // Set this after, because it causes invalidation in components.
            if (!counterScale) {
                scope.scaleX = parentXAdjust;
                scope.scaleY = parentYAdjust;
            }
            
            if (hasEventListener(ResizeEvent.RESIZE)) {
                dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, xAdjust, yAdjust));
            }
        }
            
        /** @exclude */
        override public function toString():String {
            var l:uint = elements.length;
            var str:String = "[CLIK Constraints (" + l + ")]";
            for (var n:String in elements) {
                str += "\n\t" + n + ": " + elements[n].toString();
            }
            return str;
        }
        
    // Protected Methods:
        protected function handleScopeAddedToStage(event:Event):void {
            addToParentConstraints();
        }
        
        protected function addToParentConstraints():void {
            if (parentConstraints != null) {
                parentConstraints.removeEventListener(ResizeEvent.RESIZE, handleParentConstraintsResize);
            }
            parentConstraints = null;
            
            var p:DisplayObjectContainer = scope.parent;
            if (p == null) { return; }
            
            while (p != null) {
                if (p.hasOwnProperty("constraints")) {
                    parentConstraints = p["constraints"] as Constraints;
                    // Only add if immediate parent is COUNTER_SCALED to compensate for parent's scaling. Immediate parent's scale
                    // will not change for reflowing. !! Experimental.
                    if (parentConstraints != null && parentConstraints.scaleMode == ConstrainMode.REFLOW) { return; }
                    else if (parentConstraints != null && scaleMode == ConstrainMode.REFLOW) { return; } // NFM: 10/10: Added for TextArea.
                    if (parentConstraints != null) {
                        parentConstraints.addEventListener(ResizeEvent.RESIZE, handleParentConstraintsResize, false, 0, true);
                        break;
                    }
                }
                p = p.parent;
            }
            
            // TD: optimize:
            if (parentConstraints != null) {
                parentXAdjust = parentConstraints.getXAdjust();
                parentYAdjust = parentConstraints.getYAdjust();
            }
        }
        
    // Event Handlers:
        protected function handleParentConstraintsResize(event:ResizeEvent):void {
            parentXAdjust = event.scaleX;
            parentYAdjust = event.scaleY;
            update(lastWidth, lastHeight);
        }
    
    }
    
}