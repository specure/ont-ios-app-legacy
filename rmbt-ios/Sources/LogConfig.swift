/*****************************************************************************************************
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import Foundation
import XCGLogger

///
let logger = Log.logger

///
class LogConfig {
    /// setup logging system
    class func initLoggingFramework() {
        #if RELEASE
            // Release config
            logger.setup(level: .info, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil) /* .Error */
        #elseif DEBUG
            // Debug config
            logger.setup(level: .verbose, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil) // don't need log to file
        #elseif TEST
            // Test config
            logger.setup(level: .verbose, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        #elseif BETA
            // Beta config
            logger.setup(level: .debug, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        #else
            // Debug config
            logger.setup(level: .verbose, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil) // don't need log to file
        #endif
        self.setupDestination()
    }

    fileprivate class func setupDestination() {
        let logFilePath = getCurrentLogFilePath()

        let destination = FileDestination(owner: logger, writeToFile: logFilePath, shouldAppend: true)
        logger.add(destination: destination)
    }
    
    ///
    class func getCurrentLogFilePath() -> String {
        return getLogFolderPath() + "/" + getCurrentLogFileName()
    }

    ///
    class func getCurrentLogFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let name = dateFormatter.string(from: Date())
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "rmbt"
        return bundleIdentifier + "_" + name + "_" + "_log.log"
    }

    ///
    class func getLogFolderPath() -> String {
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let logDirectory = cacheDirectory + "/logs"

        // try to create logs directory if it doesn't exist yet
        if !FileManager.default.fileExists(atPath: logDirectory) {
            do {
                try FileManager.default.createDirectory(atPath: logDirectory, withIntermediateDirectories: false, attributes: nil)
            } catch {
                // TODO
            }
        }

        return logDirectory
    }

}
