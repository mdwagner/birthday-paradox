import System.Random
import Data.Time.Clock.POSIX
import Data.List.Split
import qualified Data.IntSet as IntSet
import System.Environment

getTimeMillis :: (Integral a) => IO a
getTimeMillis = round <$> (*1000) <$> getPOSIXTime

roundTo n =
  let shifter = 10^n
  in (/shifter) . fromIntegral . round . (*shifter)

main = do
  start <- getTimeMillis
  iterations <- read <$> head <$> getArgs :: IO Int
  gen <- getStdGen
  let sampleSize = 23 :: Int
      range = (0, 364) :: (Int, Int)
      results = (/ (fromIntegral iterations)) . fromIntegral . simulate iterations sampleSize range $ gen
  putStrLn . ("iterations: " ++) . show $ iterations
  putStrLn . ("sample-size: " ++) . show $ 23
  putStrLn . ("percent: " ++) . show . roundTo 2 . (*100) $ results
  end <- getTimeMillis
  putStrLn . ("seconds: " ++) . show . (/1000) . fromIntegral $ (end - start)

simulate :: Int -> Int -> (Int, Int) -> StdGen -> Int
simulate iterations sampleSize range =
  let generateLists = take iterations . chunksOf sampleSize . randomRs range
      listHasDuplicates = (/= sampleSize) . IntSet.size . IntSet.fromList
  in length . filter listHasDuplicates . generateLists

-- iterations       100000
-- sample-size      23
----------------------------
-- data-structure   time (s)
----------------------------
-- Infinite List    0.918
-- Full IntSet      1.040
-- Partial IntSet   1.069
-- Partial List     1.142
-- Full List        1.209
-- Partial Array    4.470
