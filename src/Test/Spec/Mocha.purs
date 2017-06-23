module Test.Spec.Mocha (
  runMocha,
  MOCHA()
  ) where

import Prelude

import Control.Monad.Aff           (Aff())
import Control.Monad.Eff           (kind Effect, Eff())

import Data.Foldable               (traverse_)

import Test.Spec                   (Spec, Group(..), collect)

foreign import data MOCHA :: Effect

foreign import itAsync :: forall e.
                          Boolean
                       -> String
                       -> Aff e Unit
                       -> Eff (mocha :: MOCHA | e) Unit

foreign import itPending :: forall e. String
                         -> Eff (mocha :: MOCHA | e) Unit

foreign import describe :: forall e.
                           Boolean
                        -> String
                        -> Eff (mocha :: MOCHA | e) Unit
                        -> Eff (mocha :: MOCHA | e) Unit

registerGroup :: forall e. (Group (Aff e Unit))
              -> Eff (mocha :: MOCHA | e) Unit
registerGroup (It only name test) = itAsync only name test
registerGroup (Pending name) = itPending name
registerGroup (Describe only name groups) =
  describe only name (traverse_ registerGroup groups)

runMocha :: forall e. Spec e Unit
            -> Eff (mocha :: MOCHA | e) Unit
runMocha spec = traverse_ registerGroup (collect spec)
