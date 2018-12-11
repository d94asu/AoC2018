import Data.List
import Data.Ord
import Text.Regex.Base
import Text.Regex.Posix
import qualified Data.Map.Strict as M

type Time = ((Int, Int, Int), (Int, Int))
type Event = (Time, EventType)
data EventType = Asleep | Awake | Begin Int deriving (Show, Ord, Eq)

main = interact (show . calculate . sort . parse)

parse :: String -> [Event]
parse = map parseLine . lines

parseLine :: String -> Event
parseLine l =
  let regex = "\\[([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+)\\] (.*)$"
      [[_, year, month, day, hour, minute, eventText]] = l =~ regex
      time = ((read year, read month, read day), (read hour, read minute))
      eventType | eventText == "falls asleep" = Asleep
                | eventText == "wakes up" = Awake
                | otherwise = let [[_, id]] = eventText =~ "#([0-9]+)"
                              in Begin (read id)
  in (time, eventType)

calculate :: [Event] -> Int
calculate events = guardId * minute
  where (guardId, minutes) = sleepiestGuard . sleepPerGuard $ sleepPerShift events
        minute = sleepiestMinute minutes

sleepPerShift :: [Event] -> [(Int, [Int])]
sleepPerShift = map shiftMinutes . shifts
  where shifts = groupBy (const (\(_,e) -> e == Awake || e == Asleep))
        shiftMinutes ((_, Begin id):sleeps) = (id, sleepMinutes sleeps)
        sleepMinutes [] = []
        sleepMinutes ((((_,_,_),(_,from)),Asleep):
                      (((_,_,_),(_,to)),Awake):rest) =
          [from..(to-1)] ++ sleepMinutes rest

sleepPerGuard :: [(Int, [Int])] -> M.Map Int [Int]
sleepPerGuard shiftSleeps =
  foldl' (\m (id, s) -> M.insertWith (++) id s m) M.empty shiftSleeps

sleepiestGuard :: M.Map Int [Int] -> (Int, [Int])
sleepiestGuard = maximumBy (comparing (length . snd)) . M.toList

sleepiestMinute :: [Int] -> Int
sleepiestMinute =
  snd . last . sort . map (\l@(e:_) -> (length l, e)) . group . sort
