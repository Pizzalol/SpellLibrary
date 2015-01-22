/**
 * The public interface that all ScrollBars must expose to be used with other CLIK components.
 */

/**************************************************************************

Filename    :   IScrollBar.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.interfaces {
    
    import flash.geom.Rectangle;
    
    public interface IScrollBar extends IUIComponent {
        
    // Public getter / setters:
        function get position():Number;
        function set position(value:Number):void;
                
        /*
            LM: Need to determine best way to apply a ScrollBar interface. Might want to consider supporting either in List-based components.
            ScrollBar needs:
                * setScrollProperties
                * position
            Slider needs:
                * minimum
                * maximum
                * value
        */
        
    // Public Methods:
        
    }
    
}