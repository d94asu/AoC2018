import Data.List

main = interact (show . calculate . process . lines)

process = map (map length . group . sort)

calculate input = numWith 2 * numWith 3
  where numWith n = length $ filter (elem n) input
