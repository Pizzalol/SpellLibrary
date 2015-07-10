/**************************************************************************

Filename    :   ScrollBarTrackMode.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.constants 
{
    /**
     * Definitions for the available "track modes" for use with ScrollBar.
     */
    public class ScrollBarTrackMode 
    {
    // Constants:
        /** If SCROLL_PAGE is used, when the track is clicked, the scroll bar will be scrolled by one page. */
        public static const SCROLL_PAGE:String = "scrollPage";
        /** If SCROLL_TO_CURSOR is used, when the track is clicked, the scroll bar will be scrolled to the location of the click. */
        public static const SCROLL_TO_CURSOR:String = "scrollToCursor";
        
    }
    
}