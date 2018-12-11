import Data.List
import qualified Data.Map.Strict as M
import Text.Regex.Base
import Text.Regex.Posix

type Square = (Int, Int, Int, Int, Int)

main = interact (show . process . parse)

parse :: String -> [Square]
parse input = map toTuple matches
  where matches = input =~ "#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)"
        toTuple match = let [_, id, x, y, w, h] = map read match
                        in (id, x, y, w, h)

process :: [Square] -> Maybe Square
process squares = findNonOverlapping squares $ foldr putInches M.empty squares
  where putInches square acc = foldr putInch acc (coverage square)
        putInch pos acc' = M.insertWith (+) pos 1 acc'

findNonOverlapping :: [Square] -> M.Map (Int, Int) Int -> Maybe Square
findNonOverlapping squares overlapMap = find nonOverlapping squares
  where nonOverlapping :: Square -> Bool
        nonOverlapping square =
          all (== Just 1) (map (flip M.lookup overlapMap) (coverage square))

coverage (_, x, y, w, h) = [(x', y') | x' <- [x..(x+w-1)], y' <- [y..(y+h-1)]]
