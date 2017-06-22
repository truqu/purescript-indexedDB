module Database.IndexedDB.IDBFactory where

import Prelude

import Control.Monad.Aff(Aff)
import Control.Monad.Eff(kind Effect, Eff)
import Control.Monad.Eff.Exception(EXCEPTION)
import Data.Function.Uncurried as Fn
import Data.Function.Uncurried(Fn3)
import Data.Maybe(Maybe)

import Database.IndexedDB.Core


type IDBOpenRequest eff =
  { onBlocked       :: Maybe (IDBDatabase -> Eff (idb :: INDEXED_DB | eff) Unit)
  , onUpgradeNeeded :: Maybe (IDBDatabase -> Eff (idb :: INDEXED_DB | eff) Unit)
  }


foreign import deleteDatabase :: forall eff. String -> Aff (idb :: INDEXED_DB | eff) Int


foreign import _open :: forall eff. Fn3 String (Maybe Int) (IDBOpenRequest eff) (Aff (idb :: INDEXED_DB | eff) IDBDatabase)
open :: forall eff .  String -> Maybe Int -> IDBOpenRequest eff -> Aff (idb :: INDEXED_DB | eff) IDBDatabase
open name mver req =
  Fn.runFn3 _open name mver req
