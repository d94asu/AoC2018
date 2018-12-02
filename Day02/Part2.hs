import Data.List

main = interact (format . search . lines)

format (id1, id2) = map fst . filter (\(a, b) -> a == b) $ zip id1 id2

search :: [String] -> (String, String)
search ids = head [ (a, b) | a <- ids, b <- ids, differsByOne a b ]
  where differsByOne a b =
          length (filter (\(l, l') -> l == l') (zip a b)) == length a - 1

