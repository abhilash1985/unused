module Unused.CLI.ProgressIndicator
    ( ProgressIndicator
    , createProgressBar
    , createSpinner
    , progressWithIndicator
    ) where

import Control.Concurrent.ParallelIO
import Unused.CLI.Util
import Unused.CLI.ProgressIndicator.Types
import Unused.CLI.ProgressIndicator.Internal

createProgressBar :: ProgressIndicator
createProgressBar = ProgressBar Nothing Nothing

createSpinner :: ProgressIndicator
createSpinner =
    Spinner snapshots (length snapshots) 75000 colors Nothing
  where
    snapshots = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"]
    colors = cycle [Black, Red, Yellow, Green, Blue, Cyan, Magenta]

progressWithIndicator :: Monoid b => (a -> IO b) -> ProgressIndicator -> [a] -> IO b
progressWithIndicator f i terms = do
    printPrefix i
    (tid, indicator) <- start i $ length terms
    installChildInterruptHandler tid
    mconcat <$> parallel (ioOps indicator) <* stop indicator
  where
    ioOps i' = map (\t -> f t <* increment i') terms
