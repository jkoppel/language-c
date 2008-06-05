{-# OPTIONS  #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  CReportFatal
-- Copyright   :  (c) 2008 Benedikt Huber
-- License     :  BSD-style
-- Maintainer  :  benedikt.huber@gmail.com
-- Portability :  
--
-- Report a fatal error in a test (cannot be done within the test itself, e.g. out-of-memory)
-- Reads the error message from stdin.
-----------------------------------------------------------------------------
module Main (main)
where
import Language.C.Test.Framework

import Control.Monad (when)
import System.Environment (getArgs)
import System.IO (hPutStrLn, stderr)
import System.Exit (exitWith,ExitCode(..))
import System.Directory (doesFileExist)

bail :: String -> IO a
bail msg = hPutStrLn stderr msg >> exitWith (ExitFailure 1) >> error "<unreachable>"
usage :: String
usage = "CReportFatal report-file.dat arg_1 [ ... arg_n ] < error-log"
main :: IO ()
main = do
  arguments <- getArgs  
  (reportFile,testargs) <-
    case arguments of
      (rf:args@(_:_)) -> do
        return (rf,args)
      _ -> bail usage
  errMsg <- getContents
  appendFile reportFile $ show FatalError { fatalErrMsg = errMsg, runArgs = testargs } ++ "\n"
  
  