-- | An object store is the primary storage mechanism for storing data in a database.
module Database.IndexedDB.IDBTransaction
  -- * Interface
  ( abort
  , objectStore

  -- * Attributes
  , error
  , mode

  -- * Event Handlers
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

import Database.IndexedDB.Core


--------------------
-- INTERFACES
--

-- | Aborts the transaction. All pending requests will fail with a "AbortError"
-- | DOMException and all changes made to the database will be reverted.
abort
  :: forall e tx. (IDBTransaction tx)
  => tx
  -> Aff (idb :: IDB | e) Unit
abort =
  _abort


-- | Returns an IDBObjectStore in the transaction's scope.
objectStore
  :: forall e tx. (IDBTransaction tx)
  => tx
  -> String
  -> Aff (idb :: IDB | e) ObjectStore
objectStore tx name =
    Fn.runFn2 _objectStore tx name


--------------------
-- ATTRIBUTES
--

--- | Returns the transaction’s connection.
db
  :: Transaction
  -> Database
db =
  _db


-- | If the transaction was aborted, returns the error (a DOMException) providing the reason.
error
  :: Transaction
  -> Maybe Error
error =
  _error >>> toMaybe


-- | Returns the mode the transaction was created with (`ReadOnly|ReadWrite`)
-- | , or `VersionChange` for an upgrade transaction.
mode
  :: Transaction
  -> TransactionMode
mode =
  Fn.runFn4 _mode ReadOnly ReadWrite VersionChange


-- | Returns a list of the names of object stores in the transaction’s scope.
-- | For an upgrade transaction this is all object stores in the database.
objectStoreNames
  :: Transaction
  -> Array String
objectStoreNames =
  _objectStoreNames


--------------------
-- EVENT HANDLERS
--

-- | Event handler for the `abort` event.
onAbort
  :: forall e e'
  .  Transaction
  -> Eff ( | e') Unit
  -> Aff (idb :: IDB | e) Unit
onAbort db' f =
  Fn.runFn2 _onAbort db' f


-- | Event handler for the `complete` event.
onComplete
  :: forall e e'
  .  Transaction
  -> Eff ( | e') Unit
  -> Aff (idb :: IDB | e) Unit
onComplete db' f =
  Fn.runFn2 _onComplete db' f


-- | Event handler for the `error` event.
onError
  :: forall e e'
  .  Transaction
  -> (Error -> Eff ( | e') Unit)
  -> Aff (idb :: IDB | e) Unit
onError db' f =
  Fn.runFn2 _onError db' f


--------------------
-- FFI
--

foreign import _abort
  :: forall tx e
  .  tx
  -> Aff (idb :: IDB | e) Unit


foreign import _db
  :: Transaction
  -> Database


foreign import _error
  :: Transaction
  -> (Nullable Error)


foreign import _mode
  :: Fn4 TransactionMode TransactionMode TransactionMode Transaction TransactionMode


foreign import _objectStoreNames
  :: Transaction
  -> Array String


foreign import _objectStore
  :: forall tx e
  .  Fn2 tx String (Aff (idb :: IDB | e) ObjectStore)


foreign import _onAbort
  :: forall tx e e'
  . Fn2 tx (Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _onComplete
  :: forall tx e e'
  . Fn2 tx (Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _onError
  :: forall tx e e'
  . Fn2 tx (Error -> Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)
