module IDBDatabase where

import Prelude

import Data.Maybe(Maybe)
import Control.Monad.Eff.Console as Console
import Control.Monad.Aff(Aff)
import Control.Monad.Eff(kind Effect, Eff)
import Data.Function.Uncurried as Fn
import Data.Function.Uncurried(Fn3)

import Core


foreign import _open
    :: forall eff. Fn3
    String
    (Maybe Int)
    (IDBOpenRequest eff)
    (Aff (idb :: INDEXED_DB | eff) IDBDatabase)

open :: forall eff. String -> Maybe Int -> (IDBOpenRequest eff) -> Aff (idb :: INDEXED_DB | eff) IDBDatabase
open name mver req =
  Fn.runFn3 _open name mver req


foreign import name :: IDBDatabase -> String


foreign import version :: IDBDatabase -> Int
