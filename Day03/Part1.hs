import Data.List
import qualified Data.Map.Strict as M
import Text.Regex.Base
import Text.Regex.Posix

main = interact (show . countOverlap . process . parse)

parse :: String -> [(Int, Int, Int, Int)]
parse input = map toTuple matches
  where matches = input =~ "#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)"
        toTuple match = let [_, _, x, y, w, h] = map read match
                        in (x, y, w, h)

process :: [(Int, Int, Int, Int)] -> M.Map (Int, Int) Int
process = foldr putInches M.empty
  where putInches (x, y, w, h) acc =
          foldr putInch acc [(x', y') | x' <- [x..(x+w-1)], y' <- [y..(y+h-1)]]
        putInch pos acc' = M.insertWith (+) pos 1 acc'

countOverlap :: M.Map (Int, Int) Int -> Int
countOverlap = length . filter (>1) . M.elems
