module Database.IndexedDB.IDBFactory where

import Prelude                     (Unit)

import Control.Monad.Aff           (Aff)
import Control.Monad.Eff           (Eff)
import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn4)
import Data.Maybe                  (Maybe, fromMaybe)

import Database.IndexedDB.Core


--------------------
-- INTERFACE
--
type OpenRequest eff =
  { onBlocked       :: Maybe (Eff (idb :: INDEXED_DB | eff) Unit)
  , onUpgradeNeeded :: Maybe (Database -> Eff (idb :: INDEXED_DB | eff) Unit)
  }


deleteDatabase :: forall eff. String -> Aff (idb :: INDEXED_DB | eff) Int
deleteDatabase =
  _deleteDatabase


open :: forall eff .  String -> Maybe Int -> OpenRequest eff -> Aff (idb :: INDEXED_DB | eff) Database
open name mver req =
  Fn.runFn4 _open fromMaybe name mver req


--------------------
-- FFI
--
foreign import _deleteDatabase :: forall eff. String -> Aff (idb :: INDEXED_DB | eff) Int


foreign import _open :: forall a eff. Fn4 (a -> Maybe a -> a) String (Maybe Int) (OpenRequest eff) (Aff (idb :: INDEXED_DB | eff) Database)
