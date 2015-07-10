/**
 * Definitions for the available "focus modes" that FocusHandler should use when moving focus.
 */

/**************************************************************************

Filename    :   FocusMode.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.constants 
{
    public class FocusMode 
    {
    // Constants:
        /** If LOOP is used, FocusHandler will search for avaiable focus targets in the target direction until it reaches the end of the document. If no valid target is found before the end of the document, it will begin a new search from the opposite side of the document and repeat the process. */
        public static const LOOP:String = "loop";
        /** If DEFAULT is used, FocusHandler will search for available focus targets in the target direction until it reaches the end of the document. If no valid target is found before the end of the document, the search will end there. */
        public static const DEFAULT:String = "default";
        public static const VERTICAL:String = "focusModeVertical";
        public static const HORIZONTAL:String = "focusModeHorizontal";
        
    }
    
}