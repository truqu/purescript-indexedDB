-- | A cursor is used to iterate over a range of records in an index or
-- | an object store in a specific direction.
module Database.IndexedDB.IDBCursor
  -- * Interface
  ( advance
  , continue
  , continuePrimaryKey
  , delete
  , update

  -- * Attributes
  , direction
  , key
  , primaryKey
  , source
  , value
  ) where

import Prelude                            (Unit, ($), (>>>), (<<<), map)

import Control.Monad.Aff                  (Aff)
import Control.Monad.Aff.Compat           (fromEffFnAff, EffFnAff)
import Data.Foreign                       (Foreign, toForeign, unsafeFromForeign)
import Data.Function.Uncurried             as Fn
import Data.Function.Uncurried            (Fn2, Fn3)
import Data.Maybe                         (Maybe)
import Data.Nullable                      (Nullable, toNullable)
import Data.String.Read                   (read)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBKey.Internal (class IDBKey, Key, toKey, unsafeFromKey)


--------------------
-- INTERFACES
--

-- | Advances the cursor through the next count records in range.
advance
    :: forall e cursor. (IDBCursor cursor)
    => cursor
    -> Int
    -> Aff (idb :: IDB | e) Unit
advance c =
  fromEffFnAff <<< Fn.runFn2 _advance c


-- | Advances the cursor to the next record in range matching or after key.
continue
    :: forall e k cursor. (IDBKey k) => (IDBCursor cursor)
    => cursor
    -> Maybe k
    -> Aff (idb :: IDB | e) Unit
continue c mk =
  fromEffFnAff $ Fn.runFn2 _continue c (toNullable $ map (toKey >>> unsafeFromKey) mk)


-- | Advances the cursor to the next record in range matching or after key and primaryKey. Throws an "InvalidAccessError" DOMException if the source is not an index.
continuePrimaryKey
    :: forall e k cursor. (IDBKey k) => (IDBCursor cursor)
    => cursor
    -> k
    -> k
    -> Aff (idb :: IDB | e) Unit
continuePrimaryKey c k1 k2 =
  fromEffFnAff $ Fn.runFn3 _continuePrimaryKey c (unsafeFromKey $ toKey k1) (unsafeFromKey $ toKey k2)


-- | Delete the record pointed at by the cursor with a new value.
delete
    :: forall e cursor. (IDBCursor cursor)
    => cursor
    -> Aff (idb :: IDB | e) Unit
delete =
  fromEffFnAff <<< _delete


-- | Update the record pointed at by the cursor with a new value.
-- |
-- | Throws a "DataError" DOMException if the effective object store uses
-- | in-line keys and the key would have changed.
update
    :: forall val e cursor. (IDBCursor cursor)
    => cursor
    -> val
    -> Aff (idb :: IDB | e) Key
update c =
  map toKey <<< fromEffFnAff <<< Fn.runFn2 _update c <<< toForeign


--------------------
-- ATTRIBUTES
--

-- | Returns the direction (Next|NextUnique|Prev|PrevUnique) of the cursor.
direction
  :: forall cursor. (IDBConcreteCursor cursor)
  => cursor
  -> CursorDirection
direction =
  Fn.runFn2 _direction (read >>> toNullable)


-- | Returns the key of the cursor. Throws a "InvalidStateError" DOMException
-- | if the cursor is advancing or is finished.
key
  :: forall e cursor. (IDBConcreteCursor cursor)
  => cursor
  -> Aff (idb :: IDB | e) Key
key =
  map toKey <<< fromEffFnAff <<< _key


-- | Returns the effective key of the cursor. Throws a "InvalidStateError" DOMException
-- | if the cursor is advancing or is finished.
primaryKey
  :: forall e cursor. (IDBConcreteCursor cursor)
  => cursor
  -> Aff (idb :: IDB | e) Key
primaryKey =
  map toKey <<< fromEffFnAff <<< _primaryKey


-- | Returns the IDBObjectStore or IDBIndex the cursor was opened from.
source
  :: forall cursor. (IDBConcreteCursor cursor)
  => cursor
  -> CursorSource
source =
  Fn.runFn3 _source ObjectStore Index


value
  :: forall val
  .  ValueCursor
  -> val
value =
  _value >>> unsafeFromForeign


--------------------
-- FFI
--

foreign import _advance
  :: forall cursor e
  .  Fn2 cursor Int (EffFnAff (idb :: IDB | e) Unit)


foreign import _continue
  :: forall cursor e
  .  Fn2 cursor (Nullable Foreign) (EffFnAff (idb :: IDB | e) Unit)


foreign import _continuePrimaryKey
  :: forall cursor e
  .  Fn3 cursor Foreign Foreign (EffFnAff (idb :: IDB | e) Unit)


foreign import _delete
  :: forall cursor e
  .  cursor
  -> (EffFnAff (idb :: IDB | e) Unit)


foreign import _direction
  :: forall cursor
  .  Fn2 (String -> Nullable CursorDirection) cursor CursorDirection


foreign import _key
  :: forall cursor e
  .  cursor
  -> EffFnAff (idb :: IDB | e) Key


foreign import _primaryKey
  :: forall cursor e
  .  cursor
  -> EffFnAff (idb :: IDB | e) Key


foreign import _source
  :: forall cursor
  .  Fn3 (ObjectStore -> CursorSource) (Index -> CursorSource) cursor CursorSource


foreign import _update
  :: forall cursor e
  .  Fn2 cursor Foreign (EffFnAff (idb :: IDB | e) Foreign)


foreign import _value
  :: forall cursor val
  .  cursor
  -> val
