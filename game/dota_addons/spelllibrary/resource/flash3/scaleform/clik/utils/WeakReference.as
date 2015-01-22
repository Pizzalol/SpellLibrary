/**************************************************************************

Filename    :   WeakReference.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
package scaleform.clik.utils {
    
    import flash.utils.Dictionary;
    
    public class WeakReference {
        
    // Constants:
        
    // Public Properties:
        
    // Protected Properties:
        protected var _dictionary:Dictionary;
        
    // Initialization:
        public function WeakReference(obj:Object) {
            _dictionary = new Dictionary( true ); // Create a weak ref dictionary.    
            _dictionary[obj] = 1;
        }
        
    // Public Getter / Setters:
        
    // Public Methods:
        
        public function get value():Object {
            for (var dvalue:Object in _dictionary) {
                return dvalue;
			}
            return null;
        }
    
    // Protected Methods:
    }
    
}