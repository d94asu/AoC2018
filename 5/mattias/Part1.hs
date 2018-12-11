import Data.List.Zipper
import Data.Char

main = interact (show . length . toList . reduce . fromList . filter isLetter)

reduce :: Zipper Char -> Zipper Char
reduce z
  | endp (right z) = z
  | cursor z `matches` cursor (right z) = reduce . left . delete $ delete z
  | otherwise = reduce $ right z
  where matches a b = toLower a == toLower b && a /= b
