module Test.Main where

import Prelude
import Control.Monad.Aff.AVar    (AVAR)
import Control.Monad.Aff.Console (CONSOLE)
import Control.Monad.Eff         (Eff)
import Test.Unit                 (success, suite, test)
import Test.Unit.Karma           (runKarma)

main :: forall e. Eff (avar :: AVAR, console :: CONSOLE | e) Unit
main = runKarma do
  suite "hello" $
    test "patate!" $ success
