//
//  Gifsicle.swift
//  GIFPop
//
//  Created by Matt Reagan on 10/14/16.
//  Copyright © 2016 Matt Reagan. All rights reserved.
//

import Foundation

public typealias GifInfo = (numberOfFrames: Int, numberOfColors: Int, frameDelay: Double)

/****************************************************************************/
/*  Gifsicle */
/****************************************************************************/

class Gifsicle
{
    //MARK: - Properties -
    
    let pathToWhich = "/usr/bin/which"
    let gifsicleExecutableName = "gifsicle"
    var pathToGifsicle: String?
    
    init()
    {
        pathToGifsicle = runSystemTaskForStringOutput(executablePath: pathToWhich, arguments: [gifsicleExecutableName])
        
        if (pathToGifsicle?.characters.count == 0)
        {
            pathToGifsicle = Bundle.main.path(forResource: gifsicleExecutableName, ofType: nil)
        }
    }
}

extension Gifsicle
{
    //MARK: - Gifsicle wrapper functions -
    
    func runGifsicle(inputImage: String,
                     resizeTo: NSSize!,
                     optimize: Int?,
                     limitColors: Int?,
                     trimmedFrames: String?,
                     outputPath: String)
    {
        assert((pathToGifsicle?.characters.count)! > 0, "No path to Gifsicle executable")
        
        /*  Here the basic arguments for gifsicle are plugged in for the process
            See: https://www.lcdf.org/gifsicle/ */
        
        var arguments = ["-i", inputImage]
        
        if (trimmedFrames != nil)
        {
            let trimmedFramesArgument = "#\(trimmedFrames!)"
            
            arguments.append(trimmedFramesArgument)
        }
        
        if (resizeTo != nil)
        {
            arguments.append("--resize")
            arguments.append("\(Int(resizeTo!.width))x\(Int(resizeTo!.height))")
        }
        
        if (optimize != nil && optimize != 0)
        {
            assert(optimize! <= 3 && optimize! >= 1, "Only optimization levels O1-O3 supported")
            arguments.append("-O\(optimize!)")
        }
        
        if (limitColors != nil && limitColors != 0)
        {
            arguments.append("--colors")
            arguments.append("\(limitColors!)")
        }
        
        arguments.append("--output")
        arguments.append(outputPath)
        
        let _ = runSystemTask(executablePath: pathToGifsicle!,
                              arguments: arguments)
    }
    
    func getGifsicleInfo(inputImage: String) -> (GifInfo)
    {
        assert((pathToGifsicle?.characters.count)! > 0, "No path to Gifsicle executable")
        
        let gifInfo =
            runSystemTaskForStringOutput(executablePath: pathToGifsicle!,
                                         arguments: ["--info",
                                                     inputImage])
        
        var numberOfFrames = 0
        var totalColors = 0
        var frameDelay = 0.0
        var totalFrameDelaysComputed = 0
        
        gifInfo?.enumerateLines(invoking: { (line: String, stop: inout Bool) in
            let cleanLine = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            if (cleanLine.hasPrefix("+ image #"))
            {
                numberOfFrames += 1
            }
            else if (cleanLine.hasPrefix("disposal"))
            {
                if let lastWord = (line.components(separatedBy: " ").last as String?)
                {
                    if let delay = Double(lastWord.trimmingCharacters(in: CharacterSet.decimalDigits.inverted))
                    {
                        frameDelay += delay
                        totalFrameDelaysComputed += 1
                    }
                }
            }
            else if (cleanLine.contains("color table"))
            {
                if let lastWord = (line.components(separatedBy: " ").last as String?)
                {
                    if let colors = Int(lastWord.trimmingCharacters(in: CharacterSet.decimalDigits.inverted))
                    {
                        totalColors = colors
                    }
                }
            }
        })
        
        if (totalFrameDelaysComputed == 0 || frameDelay == 0.0)
        {
            print("Frame delay information unavailable, using default 0.1s")
            frameDelay = 0.1
        }
        else
        {
            frameDelay /= Double(totalFrameDelaysComputed)
        }
        
        return (numberOfFrames, totalColors, frameDelay)
    }
}

/****************************************************************************/
/*  NSTask (Process) Utility */
/****************************************************************************/

extension Gifsicle
{
    //MARK: - Gifsicle process utility functions -
    
    func runSystemTaskForStringOutput(executablePath: String, arguments: [String]) -> String?
    {
        let data = runSystemTask(executablePath: executablePath, arguments: arguments)
        let outputString = String.init(data: data, encoding: String.Encoding.utf8)
        
        return outputString
    }
    
    func runSystemTask(executablePath: String, arguments: [String]) -> Data
    {
        let task = Process()
        
        task.launchPath = executablePath
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let fileHandle = pipe.fileHandleForReading
        
        task.launch()
        task.waitUntilExit()
        
        let outputData = fileHandle.readDataToEndOfFile()
        
        return outputData
    }
}
