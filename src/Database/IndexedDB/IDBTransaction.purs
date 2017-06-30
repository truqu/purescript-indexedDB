module Database.IndexedDB.IDBTransaction
  (class IDBTransaction, abort, objectStore
  , error
  , mode
  , onAbort
  , onComplete
  , onError
  ) where

import Prelude                     (Unit, (>>>))

import Control.Monad.Aff           (Aff)
import Control.Monad.Eff           (Eff)
import Control.Monad.Eff.Exception (Error)
import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn2, Fn4)
import Data.Maybe                  (Maybe)
import Data.Nullable               (Nullable, toMaybe)

import Database.IndexedDB.Core     (IDB, ObjectStore, Transaction, TransactionMode(..))


--------------------
-- INTERFACES
--
class IDBTransaction tx where
  abort :: forall e. tx -> Aff (idb :: IDB | e) Unit
  objectStore :: forall e. tx -> String -> Aff (idb :: IDB | e) ObjectStore


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
-- EVENT HANDLERS
--
onAbort :: forall e e'. Transaction -> Eff ( | e') Unit -> Aff (idb :: IDB | e) Unit
onAbort db f =
  Fn.runFn2 _onAbort db f


onComplete :: forall e e'. Transaction -> Eff ( | e') Unit -> Aff (idb :: IDB | e) Unit
onComplete db f =
  Fn.runFn2 _onComplete db f


onError :: forall e e'. Transaction -> (Error -> Eff ( | e') Unit) -> Aff (idb :: IDB | e) Unit
onError db f =
  Fn.runFn2 _onError db f


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
foreign import _abort :: forall tx e. tx -> Aff (idb :: IDB | e) Unit


foreign import _error :: Transaction -> (Nullable Error)


foreign import _mode :: Fn4 TransactionMode TransactionMode TransactionMode Transaction TransactionMode


foreign import _objectStore :: forall tx e. Fn2 tx String (Aff (idb :: IDB | e) ObjectStore)


foreign import _onAbort :: forall tx e e'. Fn2 tx (Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _onComplete :: forall tx e e'. Fn2 tx (Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _onError :: forall tx e e'. Fn2 tx (Error -> Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)
