module Day6.Main where

import Data.Set (Set, member, insert, empty)
import Data.List (maximumBy, intercalate)
import Data.Ord (comparing)
import Data.Array.IArray (Array, (//), listArray, (!), bounds, assocs)
import Control.Monad (forM_)
import Text.Printf (printf)
import Control.Concurrent (threadDelay)
import System.IO (stdout, hFlush)

type BankList = Array Int Int

update :: (Int -> Int) -> Int -> BankList -> BankList
update f i banks = banks // [(i, f (banks ! i))]

dropBlocks :: BankList -> Int -> Int -> BankList
dropBlocks banks _ 0 = banks
dropBlocks banks i n = dropBlocks newBanks (succ i) (pred n)
 where
  j        = i `mod` (snd (bounds banks) + 1)
  newBanks = update succ j banks

redistribute :: BankList -> BankList
redistribute banks = dropBlocks (update (const 0) i banks) (succ i) n
  where (i, n) = maximumBy (comparing (\(x, y) -> (y, -x))) . assocs $ banks

takeWhileDistinct :: Ord a => [a] -> [a]
takeWhileDistinct = f empty
 where
  f seen (x:xs) | x `member` seen = []
                | otherwise       = x : f (insert x seen) xs

redistributeUntilLoopDetected :: BankList -> [BankList]
redistributeUntilLoopDetected = takeWhileDistinct . iterate redistribute

showBanks :: BankList -> String
showBanks banks = unlines rows
 where
  n = snd (bounds banks)
  row i =
    intercalate "  " $ map (\b -> if banks ! b >= i then "x" else " ") [0 .. n]
  labels    = concatMap (printf "%-3d") ([1 .. (n + 1)] :: [Int])
  separator = replicate (3 * (n + 1)) '-'
  rows      = (reverse $ map row [1 .. 15] :: [String]) ++ [separator, labels]

solve :: String -> IO ()
solve input = do
  let xs       = map read . words $ input
      maxIndex = length xs - 1
      banks    = listArray (0, maxIndex) xs
      states   = redistributeUntilLoopDetected banks
  forM_
    (zip states [1 ..])
    ( \(banks, i) -> do
      putStrLn . showBanks $ banks
      print i
      hFlush stdout
      threadDelay 5000
    )
  print . length . redistributeUntilLoopDetected . last $ states