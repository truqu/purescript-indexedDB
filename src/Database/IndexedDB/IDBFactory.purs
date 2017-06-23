module Database.IndexedDB.IDBFactory where

import Prelude

import Control.Monad.Aff(Aff)
import Control.Monad.Eff(Eff)
import Control.Monad.Eff.Exception(EXCEPTION)
import Data.Function.Uncurried as Fn
import Data.Function.Uncurried(Fn4)
import Data.Maybe(Maybe, fromMaybe)

import Database.IndexedDB.Core


type IDBOpenRequest eff =
  { onBlocked       :: Maybe (Eff (idb :: INDEXED_DB | eff) Unit)
  , onUpgradeNeeded :: Maybe (IDBDatabase -> Eff (idb :: INDEXED_DB | eff) Unit)
  }


foreign import deleteDatabase :: forall eff. String -> Aff (idb :: INDEXED_DB | eff) Int


foreign import _open :: forall a eff. Fn4 (a -> Maybe a -> a) String (Maybe Int) (IDBOpenRequest eff) (Aff (idb :: INDEXED_DB | eff) IDBDatabase)
open :: forall eff .  String -> Maybe Int -> IDBOpenRequest eff -> Aff (idb :: INDEXED_DB | eff) IDBDatabase
open name mver req =
  Fn.runFn4 _open fromMaybe name mver req
