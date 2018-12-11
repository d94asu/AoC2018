main = interact (show . maximum . powers 300 . read)

powers :: Int -> Int -> [(Int, (Int, Int))]
powers size serialNo = zip (map (squarePower serialNo) squares) squares
  where squares = [(x, y) | x <- [1..(size-2)], y <- [1..(size-2)]]

squarePower serialNo (x, y) = sum $ map (cellPower serialNo) cells
  where cells = [(x', y') | x' <- [x..(x+2)], y' <- [y..(y+2)]]

cellPower serialNo (x, y) =
  ((((rack * y + serialNo) * rack) `div` 100) `rem` 10) - 5
  where rack = x + 10
