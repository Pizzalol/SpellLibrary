/**************************************************************************

Filename    :   WrappingMode.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
package scaleform.clik.constants 
{
    /**
     *  Definitions for the available wrapping modes which affect list input.
     */
    public class WrappingMode 
    {
    // Constants:
        /** Focus can leave the component from all edges of the component using arrow keys. */
        public static const NORMAL:String = "normal";
        /** Focus wil be unable to leave the component from all edges of the component using arrow keys. */
        public static const STICK:String = "stick";
        /** When selection reaches the last item in row/column, the next move will cause it to wrap to the beginning. Focus will remain in the component. */
        public static const WRAP:String = "wrap";
    }
    
}