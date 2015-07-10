/**
 * Wrapper and data structure for a DisplayObject under CLIK Constraints. 
 */

/**************************************************************************

Filename    :   ConstraintedElement.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.utils {
    
    import flash.display.DisplayObject;
    
    public class ConstrainedElement {
        
    // Constants:
        
    // Public Properties:
        public var clip:DisplayObject;
        public var edges:uint;
        
        public var left:Number;
        public var top:Number;
        public var right:Number;
        public var bottom:Number;
        
        public var scaleX:Number;
        public var scaleY:Number;
        
        // public var originalWidth:Number;
        // public var originalHeight:Number;
        
    // Initialization:
        public function ConstrainedElement(clip:DisplayObject, edges:uint,
                left:Number, top:Number, right:Number, bottom:Number, 
                scaleX:Number, scaleY:Number) {
            
            this.clip = clip;
            this.edges = edges;
            
            this.left = left;
            this.top = top;
            this.right = right;
            this.bottom = bottom;
            
            this.scaleX = scaleX;
            this.scaleY = scaleY;
        }
        
    // Public getter / setters:
        
    // Public Methods:
        public function toString():String {
            return "[ConstrainedElement "+clip+", edges="+edges+", left="+left+", right="+right+", top="+top+", bottom="+bottom+", scaleX="+scaleX+", scaleY="+scaleY+"]";
        }
        
    // Protected Methods:
        
    }
    
}