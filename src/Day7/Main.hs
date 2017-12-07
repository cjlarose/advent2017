module Day7.Main where

import Data.Attoparsec.ByteString (Parser, takeWhile1, inClass, parseOnly, string, option, sepBy1, sepBy, endOfInput)
import Data.Attoparsec.ByteString.Char8 (char, isDigit_w8)
import Data.ByteString.UTF8 (fromString, toString)

programName = takeWhile1 $ inClass "a-z"
weight = read . toString <$> takeWhile1 isDigit_w8 :: Parser Int
arrow = string (fromString " -> ")
dependantsList = programName `sepBy1` string (fromString ", ")
programDescription =
  (\a b c -> (a, b, c))
    <$> (programName <* char ' ')
    <*> (char '(' *> weight <* char ')')
    <*> option [] (arrow *> dependantsList)
programList = programDescription `sepBy` char '\n' <* char '\n' <* endOfInput

solve :: String -> IO ()
solve input = do
  let parseResult = parseOnly programList (fromString input)
  case parseResult of
    Left  err -> print err
    Right str -> print str