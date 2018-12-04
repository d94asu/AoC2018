import qualified Data.Set as S

main = interact (show . search . scanl1' (+) . parse . cycle)

parse = map read . lines . filter (/= '+')

search = loop 0 S.empty
  where loop reached (change:changes)
          | S.member current reached = current
          | otherwise = let next = current + change
                        in loop next (S.insert current reached) changes
