module Day5.Main where

type Instruction = Int
type Machine = ([Instruction], [Instruction])

makeMachine :: [Instruction] -> Machine
makeMachine (x:xs) = ([x], xs)

terminated :: Machine -> Bool
terminated ([], _) = True
terminated _       = False

updateCurrent :: (Instruction -> Instruction) -> Machine -> Machine
updateCurrent f (x:xs, ys) = (f x : xs, ys)

moveForward :: Machine -> Machine
moveForward (xs, []  ) = ([], xs)
moveForward (xs, y:ys) = (y : xs, ys)

moveBackward :: Machine -> Machine
moveBackward (x:xs, ys) = (xs, x : ys)

advance :: (Instruction -> Instruction) -> Machine -> Machine
advance f m@(x:_, _)
  | x >= 0    = iterate moveForward (updateCurrent f m) !! x
  | otherwise = iterate moveBackward (updateCurrent f m) !! (-x)

solve :: String -> IO ()
solve input = do
  let
    instructions = map read . lines $ input
    initialState = makeMachine instructions
    states f =
      takeWhile (not . terminated) . iterate (advance f) $ initialState
  print . length $ states succ
  print . length $ states (\x -> if x >= 3 then x - 1 else x + 1)
