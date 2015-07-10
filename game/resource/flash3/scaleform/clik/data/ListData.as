/*
 * A data structure that can be passed to a ListItemRenderer. Currently unused.
 */

/**************************************************************************

Filename    :   ListData.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.data {
        
    public class ListData  {
        
    // Constants:
        
    // Public Properties:
        public var index:uint = 0;
        public var label:String = "Empty";
        public var selected:Boolean = false;
        
    // Protected Properties:
        
    // Initialization:
        public function ListData(index:uint, label:String="Empty", selected:Boolean=false) {
            this.index = index;
            this.label = label;
            this.selected = selected;
        }
        
    // Public Getter / Setters:
        
    // Public Methods:
        public function toString():String {
            return "[ListData " + index + ", " + label + ", " + selected + "]";
        }
        
    // Protected Methods:
        
    }
    
}