import Data.List.Zipper
import Data.Char

main = interact (show . minimum . map length . tryAll . filter isLetter)

tryAll :: String -> [String]
tryAll input = map (toList . reduce . fromList . remove) ['a'..'z']
  where remove c = filter (\c' -> c' /= c && c' /= toUpper c) input

reduce :: Zipper Char -> Zipper Char
reduce z
  | endp (right z) = z
  | cursor z `matches` cursor (right z) = reduce . left . delete $ delete z
  | otherwise = reduce $ right z
  where matches a b = toLower a == toLower b && a /= b
