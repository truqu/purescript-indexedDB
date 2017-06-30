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
type OpenRequest e =
  { onBlocked       :: Maybe (Eff (| e) Unit)
  , onUpgradeNeeded :: Maybe (Database -> Eff (| e) Unit)
  }


deleteDatabase :: forall e. String -> Aff (idb :: IDB | e) Int
deleteDatabase =
  _deleteDatabase


open :: forall e e'.  String -> Maybe Int -> OpenRequest e' -> Aff (idb :: IDB | e) Database
open name mver req =
  Fn.runFn4 _open fromMaybe name mver req


--------------------
-- FFI
--
foreign import _deleteDatabase :: forall e. String -> Aff (idb :: IDB | e) Int


foreign import _open :: forall a e e'. Fn4 (a -> Maybe a -> a) String (Maybe Int) (OpenRequest e') (Aff (idb :: IDB | e) Database)
