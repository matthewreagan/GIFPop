//
//  NSPasteboard.swift
//  GIFPop
//
//  Created by Aaron Raimist on 2018-11-15.
//  Copyright © 2018 Matt Reagan. All rights reserved.
//

import AppKit

extension NSPasteboard.PasteboardType {

	static let backwardsCompatibleFileURL: NSPasteboard.PasteboardType = {

		if #available(OSX 10.13, *) {
			return NSPasteboard.PasteboardType.fileURL
		} else {
			return NSPasteboard.PasteboardType(kUTTypeFileURL as String)
		}

	} ()

}
