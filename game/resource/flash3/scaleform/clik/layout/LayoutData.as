/**
    Data that defines the layout for this Sprite. Must be used with a valid scaleform.clik.layout.Layout instance.
  */

/**************************************************************************

Filename    :   LayoutData.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.layout {
    
    import flash.utils.Dictionary;
    
    public class LayoutData  {
        
    // Constants:
        /** String constant for 4:3 aspect ratio. Used for setting particular aspect ratio offsets in LayoutData.offsetHash Dictionaries. */
        public static const ASPECT_RATIO_4_3:String = "4:3"; 
        /** String constant for 16:9 aspect ratio. Used for setting particular aspect ratio offsets in LayoutData.offsetHash Dictionaries. */
        public static const ASPECT_RATIO_16_9:String = "16:9";
        /** String constant for 16:10 aspect ratio. Used for setting particular aspect ratio offsets in LayoutData.offsetHash Dictionaries. */
        public static const ASPECT_RATIO_16_10:String = "16:10";
        
    // Public Properties:
        /** 
         * The horizontal alignment for this Sprite. 
         * Valid values: LayoutMode.ALIGN_NONE, LayoutMode.ALIGN_LEFT, LayoutMode.ALIGN_RIGHT.
         */
        public var alignH:String = null;
        /** 
         * The vertical alignment for this Sprite. 
         * Valid values: LayoutMode.ALIGN_NONE, LayoutMode.TOP, LayoutMode.BOTTOM.
         */
        public var alignV:String = null;
        
        /** 
         * The horizontal offset from the edge of the Layout or the relativeToH Sprite. 
         * If it is left unchanged (-1), the Layout will auto-set it to original horizontal offset from the Layout/Sprite on
         * the Stage, as defined by the artist during design.
         */
        public var offsetH:int = -1;
        /** 
         * The vertical offset from the edge of the Layout or the relativeToV Sprite. 
         * If it is left unchanged (-1), the Layout will auto-set it to original vertical offset from the Layout/Sprite on
         * the Stage, as defined by the artist during design.
         */
        public var offsetV:int = -1;
        
        /** 
         * A hash table of user-defined horizontal offsets for various aspect ratios. These values will be queried if
         * the Layout is tied to the stage's size (Layout.tiedToStageSize == true).
         * For example, "LayoutData.offsetHashH[LayoutData.ASPECT_RATIO_4_3] = 70;" will cause this Sprite to use a
         * horizontal offset of 70px if the Layout is tied to the Stage's size and the aspect ratio is currently 4:3.
         */
        public var offsetHashH:Dictionary = null;
         /** 
         * A hash table of user-defined vertical offsets for various aspect ratios. These values will be queried if
         * the Layout is tied to the stage's size (Layout.tiedToStageSize == true).
         * For example, "LayoutData.offsetHashV[LayoutData.ASPECT_RATIO_4_3] = 70;" will cause this Sprite to use a
         * vertical offset of 70px if the Layout is tied to the Stage's size and the aspect ratio is currently 4:3.
         */
        public var offsetHashV:Dictionary = null;
        
        /** 
         * The instance name of the Sprite that this Sprite should be relative to horizontally. If left as null,
         * the Sprite will be aligned relative to the Layout.
         */
        public var relativeToH:String = null;
        /** 
         * The instance name of the Sprite that this Sprite should be relative to vertically. If left as null,
         * the Sprite will be aligned relative to the Layout.
         */
        public var relativeToV:String = null;
        
        /** 
         * The order in which this Sprite should be laid out relative to other Sprites in the same Layout.
         * Should be set if using relativeToH or relativeToV to ensure that Sprite's Layout is updated before
         * this Sprite. If the layoutIndex is left unchanged (-1), it will be added to the end of the list arbitrarily. 
         */
        public var layoutIndex:int = -1; // If the layoutIndex is -1, it will be ignored.
        /**
         * String that defines which Layout this LayoutData object should be associated with if multiple Layouts exist
         * within a single DisplayObjectContainer. If left unchanged (null), it will be managed by all Layouts within
         * the same parent automatically. This property, if set, should match a Layout instance's identifer property.
         */
        public var layoutIdentifier:String = null;
        
    // Protected Properties:
        
    // Initialization:
        public function LayoutData( _alignH:String = "none", // Can't use LayoutMode.ALIGN_NONE here, error 1047.
                                    _alignV:String = "none",
                                    _offsetH:int = -1,
                                    _offsetV:int = -1,
                                    _relativeToH:String = null,
                                    _relativeToV:String = null,
                                    _layoutIndex:int = -1,
                                    _layoutIdentifer:String = null) {
            
            alignH = _alignH;
            alignV = _alignV;
            offsetH = _offsetH;
            offsetV = _offsetV;
            relativeToH = _relativeToH;
            relativeToV = _relativeToV;
            layoutIndex = _layoutIndex;
            layoutIdentifier = _layoutIdentifer;
            
            // Just to save the user from having to create these if they want them.
            offsetHashH = new Dictionary();
            offsetHashV = new Dictionary();
        }
        
    // Public Getter / Setters:
        
    // Public Methods:
        public function toString():String {
            return "[LayoutData, h: " + alignH + ", v: " + alignV + ", oh: " + offsetH + ", ov: " + offsetV + ", relh: " + relativeToH + ", relv: " + relativeToV + ", idx: " + layoutIndex + "]";
        }
        
    // Protected Methods:
        
    }
    
}