module Day7.Main where

import qualified Data.Set as Set
import qualified Data.Map.Strict as Map
import Data.List (partition)
import Data.Attoparsec.ByteString (Parser, takeWhile1, inClass, parseOnly, string, option, sepBy1, sepBy, endOfInput)
import Data.Attoparsec.ByteString.Char8 (char, isDigit_w8)
import Data.ByteString.UTF8 (fromString, toString)

programName = toString <$> takeWhile1 (inClass "a-z")
weight = read . toString <$> takeWhile1 isDigit_w8 :: Parser Int
arrow = string (fromString " -> ")
dependantsList = programName `sepBy1` string (fromString ", ")
programDescription =
  (\a b c -> (a, b, c))
    <$> (programName <* char ' ')
    <*> (char '(' *> weight <* char ')')
    <*> option [] (arrow *> dependantsList)
programList = programDescription `sepBy` char '\n' <* char '\n' <* endOfInput

type WeightMap = Map.Map String Int
type AdjacencyList = [(String, String)]

childrenPrograms :: AdjacencyList -> String -> [String]
childrenPrograms adj prog = map snd . filter (\(p, c) -> p == prog) $ adj

progWeight :: WeightMap -> AdjacencyList -> String -> Int
progWeight w adj prog =
  (w Map.! prog) + (sum . map (progWeight w adj) $ childrenPrograms adj prog)

solve :: String -> IO ()
solve input = do
  let parseResult = parseOnly programList (fromString input)
  case parseResult of
    Left  err   -> print err
    Right progs -> do
      let
        progNames   = Set.fromList $ map (\(name, _, _) -> name) progs
        dependants  = Set.fromList $ concatMap (\(_, _, deps) -> deps) progs
        root        = Set.findMin $ Set.difference progNames dependants
        adjList     = concatMap (\(p, _, cs) -> [ (p, c) | c <- cs ]) progs
        weights     = Map.fromList $ map (\(name, w, _) -> (name, w)) progs
        children    = childrenPrograms adjList root
        getWeight   = progWeight weights adjList
        (bad, good) = partition
          ( \p ->
            notElem (getWeight p) . map getWeight . filter (/=p) $ children
          )
          children
        badWeight = weights Map.! head bad
        reqChange = (getWeight . head $ good) - (getWeight . head $ bad)
      print root
      print children
      print . map getWeight $ children
      print bad
      print good
      print $ badWeight + reqChange
