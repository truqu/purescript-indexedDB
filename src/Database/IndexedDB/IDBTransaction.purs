module Database.IndexedDB.IDBTransaction
  (class IDBTransaction, abort, objectStore
  , error
  , mode
  ) where

import Prelude                     (Unit, (>>>))

import Control.Monad.Eff           (Eff)
import Control.Monad.Eff.Exception (EXCEPTION, Error)
import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn2, Fn4)
import Data.Maybe                  (Maybe)
import Data.Nullable               (Nullable, toMaybe)

import Database.IndexedDB.Core     (IDB, ObjectStore, Transaction, TransactionMode(..))


--------------------
-- INTERFACES
--
class IDBTransaction tx where
  abort :: forall e. tx -> Eff (idb :: IDB, exception :: EXCEPTION | e) Unit
  objectStore :: forall e. tx -> String -> Eff (idb :: IDB, exception :: EXCEPTION | e) ObjectStore


--------------------
-- ATTRIBUTES
--
error :: Transaction -> Maybe Error
error =
  _error >>> toMaybe


mode :: Transaction -> TransactionMode
mode =
  Fn.runFn4 _mode ReadOnly ReadWrite VersionChange


--------------------
-- INSTANCES
--
instance idbTransactionTransaction :: IDBTransaction Transaction where
  objectStore tx name =
    Fn.runFn2 _objectStore tx name

  abort =
    _abort


--------------------
-- FFI
--
foreign import _abort :: forall tx e. tx -> Eff (idb :: IDB, exception :: EXCEPTION | e) Unit


foreign import _error :: Transaction -> (Nullable Error)


foreign import _mode :: Fn4 TransactionMode TransactionMode TransactionMode Transaction TransactionMode


foreign import _objectStore :: forall tx e. Fn2 tx String (Eff (idb :: IDB, exception :: EXCEPTION | e) ObjectStore)
