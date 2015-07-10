/**
 * A data structure that defines padding for the top, bottom, left, and right of a component. Use of the Padding class is at the discretion of the component.
 */
/**************************************************************************

Filename    :   Padding.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.utils {
    
    public class Padding {
        
    // Constants:
        
    // Public Properties:
        public var top:Number = 0;
        public var bottom:Number = 0;
        public var left:Number = 0;
        public var right:Number = 0;
        
    // Initialization:
        public function Padding(...args:Array) {
            switch (args.length) {
                case 0:
                    break;
                case 1:
                    top = right = bottom = left = Number(args[0]);
                    break;
                case 2:
                    top = bottom = Number(args[0]);
                    right = left = Number(args[1]);
                    break;
                case 4:
                    top = Number(args[0]);
                    right = Number(args[1]);
                    bottom = Number(args[2]);
                    left = Number(args[3]);
                    break;
                default:
                    throw(new Error("Padding can not have "+args.length+" values"));
                    break;
                    
            }
        }
        
        public function get vertical():Number {
            return top + bottom;
        }
        
        public function get horizontal():Number {
            return left + right;
        }
        
        public function toString():String {
            return "[Padding top=" + top + " bottom=" + bottom + " left=" + left + " right=" + right + "]";
        }
        
    }
    
}