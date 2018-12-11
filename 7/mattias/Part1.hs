import Data.List
import Text.Regex.Base
import Text.Regex.Posix
import qualified Data.Map.Strict as M

main = interact (findOrder . depGraph . parse)

findOrder :: M.Map Char [Char] -> [Char]
findOrder graph | M.null graph = ""
                | otherwise = next : findOrder updated
  where (next, _) = minimum . filter (null . snd) $ M.toList graph
        updated = M.map (delete next) (M.delete next graph)

depGraph :: [(Char, Char)] -> M.Map Char [Char]
depGraph deps = foldl' (\acc (s, d) -> M.insertWith (++) s [d] acc) graph0 deps
  where graph0 = M.fromList $ zip (map fst deps ++ map snd deps) (repeat [])

parse :: String -> [(Char, Char)]
parse = map parseLine . lines
  where parseLine :: String -> (Char, Char)
        parseLine l =
          let regex = "Step ([A-Z]) must be finished before step ([A-Z])"
              [[_, dependency:_, step:_]] = l =~ regex :: [[String]]
          in (step, dependency)
