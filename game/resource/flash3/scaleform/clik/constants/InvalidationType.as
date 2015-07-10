/**
 * Definitions for the component invalidation types. These types are used to segment parts of invalidation (which primarily occurs draw()) to minimize unnecessary updates.
 */

/**************************************************************************

Filename    :   InvalidationType.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.constants 
{
    
    public class InvalidationType 
    {
        public static const ALL:String = "all";
        public static const SIZE:String = "size";
        public static const STATE:String = "state";
        public static const DATA:String = "data";
        public static const SETTINGS:String = "settings";
        public static const RENDERERS:String = "renderers";
        public static const SCROLL_BAR:String = "scrollBar";
        public static const SELECTED_INDEX:String = "selectedIndex";
        
    }
    
}