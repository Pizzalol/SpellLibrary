/**************************************************************************

Filename    :   System.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.gfx
{
    public final class SystemEx
    {
        // Enable/Disable opcode tracing.
        static public function set actionVerbose(v:Boolean) : void {}
        static public function get actionVerbose() : Boolean { return false; }

        // Set the alpha [0.0 - 1.0] value of the SWF background (value of 0.0 will hide it completely)
		static public function setBackgroundAlpha(value:Number) : void {}
        
        // Get current stack trace formatted as a string.
        static public function getStackTrace() : String { return ""; }

        // Get file name of currently executed code.
        static public function getCodeFileName() : String { return ""; }

        // Return an array of file names of all loaded swfs with ActionScript code sections.
        static public function getCodeFileNames() : Array { return new Array; }

        // Return data type of "v". This method is different from the standard
        // describeType() because it returns String and not XML, and it returns
        // more useful type description for method closures.
        static public function describeType(v:*) : String { return ""; }

		// Dump object dependency graph. This is useful for tracking down
		// resources that have not been released after explicit unloading.
		// In some cases, resources may have complicated dependencies that
		// will cause them to still be in memory.
		//
		// Use the following flags with printObjectsReport()
		static public const REPORT_SHORT_FILE_NAMES:uint		= 0x1;
		static public const REPORT_NO_CIRCULAR_REFERENCES:uint	= 0x2;
		static public const REPORT_SUPPRESS_OVERALL_STATS:uint 	= 0x4;
		static public const REPORT_ONLY_ANON_OBJ_ADDRESSES:uint = 0x8;
		//
		static public function printObjectsReport(runGarbageCollector:Boolean = true, reportFlags:uint = 0xB, swfFilter:String = null) : void {}
    }
}

