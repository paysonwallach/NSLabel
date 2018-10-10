//
// NSLabel.swift
//
// Created by Payson Wallach on 28/9/18.
// Copyright © 2018 Payson Wallach
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without
// fee is hereby granted, provided that the above copyright notice and this permission notice
// appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS
// SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
// AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
// NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
// OF THIS SOFTWARE.
//

import Cocoa

/**
 # Summary
 A view that displays one or more lines of read-only text, often used in conjunction with controls to describe their intended purpose.
 # Declaration
    class NSLabel: NSView
 #Discussion
 The appearance of labels is configurable...
 */
class NSLabel: NSView {
    
    let defaultBackgroundColor = NSColor.clear
    
    // MARK: - Properties
    
    var text: String? {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay(drawingRect)
        }
    }
    
    var attributedText: NSAttributedString? {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay(drawingRect)
        }
    }
    
    var font: NSFont
    var textColor: NSColor
    var backgroundColor: NSColor
    var numberOfLines: Int
    var textAlignment: NSTextAlignment {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay(drawingRect)
        }
    }
    
    var lineBreakMode: NSLineBreakMode {
        didSet {
            self.invalidateIntrinsicContentSize()
            self.setNeedsDisplay(drawingRect)
        }
    }
    
    var preferredMaxLayoutWidth: CGFloat
    
    private var drawingRect = NSRect.zero
    
    // MARK: - Override methods
    
    override init(frame frameRect: NSRect) {
        self.font = NSFont.labelFont(ofSize: 12.0)
        self.textColor = NSColor.black
        self.backgroundColor = defaultBackgroundColor
        self.numberOfLines = 1
        self.textAlignment = NSTextAlignment.left
        self.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.preferredMaxLayoutWidth = 0
        
        super.init(frame: frameRect)
    }
    
    required init?(coder decoder: NSCoder) {
        if let text = decoder.decodeObject(forKey: "font") as? String {
            self.text = text
        }
        
        if let attributedText = decoder.decodeObject(forKey: "attributedText") as? NSAttributedString {
            self.attributedText = attributedText
        }
        
        self.font = decoder.decodeObject(forKey: "font") as! NSFont
        self.textColor = decoder.decodeObject(forKey: "textColor") as! NSColor
        self.backgroundColor = decoder.decodeObject(forKey: "backgroundColor") as! NSColor
        
        if let numberOfLines = decoder.decodeObject(forKey: "numberOfLines") as? Int {
            self.numberOfLines = numberOfLines
        } else {
            self.numberOfLines = 1
        }
        
        if let textAlignment = decoder.decodeObject(forKey: "textAlignment") as? NSTextAlignment {
            self.textAlignment = textAlignment
        } else {
            self.textAlignment = NSTextAlignment.left
        }
        
        if let lineBreakMode = decoder.decodeObject(forKey: "lineBreakMode") as? NSLineBreakMode {
            self.lineBreakMode = lineBreakMode
        } else {
            self.lineBreakMode = NSLineBreakMode.byTruncatingTail
        }
        
        self.preferredMaxLayoutWidth = decoder.decodeObject(forKey: "preferredMaxLayoutWidth") as! CGFloat
        
        super.init(coder: decoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        if let text = self.text {
            aCoder.encode(text, forKey: "text")
        }
        
        if let attributedText = self.attributedText {
            aCoder.encode(attributedText, forKey: "attributedText")
        }
        
        aCoder.encode(font, forKey: "font")
        aCoder.encode(textColor, forKey: "textColor")
        aCoder.encode(backgroundColor, forKey: "backgroundColor")
        aCoder.encode(numberOfLines, forKey: "numberOfLines")
        aCoder.encode(textAlignment, forKey: "textAlignment")
        aCoder.encode(lineBreakMode, forKey: "lineBreakMode")
        aCoder.encode(preferredMaxLayoutWidth, forKey: "preferredMaxLayoutWidth")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        
        drawingRect = setDrawingRect()
        
        let drawRect = NSRect(origin: self.drawingRect.origin, size: bounds.size)
        
        self.backgroundColor.setFill()
        dirtyRect.fill(using: NSCompositingOperation.destinationOver)
        
        if let text = self.text {
            text.draw(with: drawRect, options: self.drawingOptions(), attributes: [
                NSAttributedString.Key.font: self.font,
                NSAttributedString.Key.foregroundColor: self.textColor,
                NSAttributedString.Key.backgroundColor: self.backgroundColor,
                NSAttributedString.Key.paragraphStyle: self.drawingParagraphStyle()
                ])
        } else if let attributedText = self.attributedText {
            attributedText.draw(with: drawRect, options: self.drawingOptions())
        }
    }
    
    override func invalidateIntrinsicContentSize() {
        drawingRect = NSRect.zero
        super.invalidateIntrinsicContentSize()
    }
    
    // MARK: - Public methods
    
    public func isOpaque() -> Bool {
        return self.backgroundColor.alphaComponent == 1.0
    }
    
    public func baselineOffsetFromBottom() -> CGFloat {
        return self.drawingRect.origin.y
    }
    
    public func intrinsicContentSize() -> NSSize {
        return self.drawingRect.size
    }
    
    //MARK: - Private methods
    
    private func setDrawingRect() -> NSRect {
        if NSIsEmptyRect(drawingRect) {
            let size = NSMakeSize(self.preferredMaxLayoutWidth, 0)
            
            if let text = self.text {
                self.drawingRect = text.boundingRect(with: size, options: self.drawingOptions(), attributes: [
                    NSAttributedString.Key.font: self.font,
                    NSAttributedString.Key.foregroundColor: self.textColor,
                    NSAttributedString.Key.backgroundColor: self.backgroundColor,
                    NSAttributedString.Key.paragraphStyle: self.drawingParagraphStyle()
                    ])
            } else if let attributedText = self.attributedText {
                self.drawingRect = attributedText.boundingRect(with: size, options: self.drawingOptions())
            }
            
            drawingRect.origin.x = ceil(drawingRect.origin.x)
            drawingRect.origin.y = ceil(drawingRect.origin.y)
            
            drawingRect.size.width = ceil(drawingRect.size.width)
            drawingRect.size.height = ceil(drawingRect.size.height)
        }
        
        return drawingRect
    }
    
    private func drawingOptions() -> NSString.DrawingOptions {
        var options: NSString.DrawingOptions = .usesFontLeading
        
        if numberOfLines != 0 {
            options.insert(.usesLineFragmentOrigin)
        }
        
        return options
    }
    
    private func drawingParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.alignment = self.textAlignment

        if self.numberOfLines > 1 {
            paragraphStyle.lineBreakMode = self.lineBreakMode
        }

        return paragraphStyle
    }
}

let l = NSLabel()
