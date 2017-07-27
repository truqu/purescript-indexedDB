-- | A cursor is used to iterate over a range of records in an index or
-- | an object store in a specific direction.
module Database.IndexedDB.IDBCursor
  ( class IDBCursor, advance, continue, continuePrimaryKey, delete, update
  , direction
  , key
  , primaryKey
  , source
  , direction'
  , key'
  , primaryKey'
  , source'
  , value
  ) where

import Prelude                            (Unit, ($), (>>>), map)

import Control.Monad.Aff                  (Aff)
import Data.Foreign                       (Foreign, toForeign, unsafeFromForeign)
import Data.Function.Uncurried             as Fn
import Data.Function.Uncurried            (Fn2, Fn3)
import Data.Maybe                         (Maybe)
import Data.Nullable                      (Nullable, toNullable)
import Data.String.Read                   (read)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBKey.Internal (class IDBKey, Key(..), toKey, extractForeign)


--------------------
-- INTERFACES
--
-- | Cursor objects implement the IDBCursor interface.
-- | There is only ever one IDBCursor instance representing a given cursor.
-- | There is no limit on how many cursors can be used at the same time.
class IDBCursor cursor where
    -- | Advances the cursor through the next count records in range.
    advance
        :: forall e
        .  cursor
        -> Int
        -> Aff (idb :: IDB | e) Unit

    -- | Advances the cursor to the next record in range matching or after key.
    continue
        :: forall e k. (IDBKey k)
        => cursor
        -> Maybe k
        -> Aff (idb :: IDB | e) Unit

    -- | Advances the cursor to the next record in range matching or after key and primaryKey. Throws an "InvalidAccessError" DOMException if the source is not an index.
    continuePrimaryKey
        :: forall e k. (IDBKey k)
        => cursor
        -> k
        -> k
        -> Aff (idb :: IDB | e) Unit

    -- | Delete the record pointed at by the cursor with a new value.
    delete
        :: forall e
        .  cursor
        -> Aff (idb :: IDB | e) Unit

    -- | Update the record pointed at by the cursor with a new value.
    -- |
    -- | Throws a "DataError" DOMException if the effective object store uses
    -- | in-line keys and the key would have changed.
    update
        :: forall val e
        .  cursor
        -> val
        -> Aff (idb :: IDB | e) Key


--------------------
-- ATTRIBUTES
--
-- | Returns the direction (Next|NextUnique|Prev|PrevUnique) of the cursor.
direction'
  :: KeyCursor
  -> CursorDirection
direction' =
  Fn.runFn2 _direction (read >>> toNullable)


-- | Returns the key of the cursor. Throws a "InvalidStateError" DOMException
-- | if the cursor is advancing or is finished.
key'
  :: forall e
  .  KeyCursor
  -> Aff (idb :: IDB | e) Key
key' =
  _key >>> map Key


-- | Returns the effective key of the cursor. Throws a "InvalidStateError" DOMException
-- | if the cursor is advancing or is finished.
primaryKey'
  :: forall e
  .  KeyCursor
  -> Aff (idb :: IDB | e) Key
primaryKey' =
  _primaryKey >>> map Key


-- | Returns the IDBObjectStore or IDBIndex the cursor was opened from.
source'
  :: KeyCursor
  -> CursorSource
source' =
  Fn.runFn3 _source ObjectStore Index


-- NOTE: Polymorphism not used here cause *we want* those methods to be distincs for
-- the concrete types mostly for consistency with the Database.IndexedDB.IDBIndex module
-- where the IDBIndex interfaces is shared by Index and ObjectStore, but attributes of
-- respective concrete types aren't shared.


-- | Returns the direction (Next|NextUnique|Prev|PrevUnique) of the cursor.
direction
  :: ValueCursor
  -> CursorDirection
direction =
  Fn.runFn2 _direction (read >>> toNullable)


-- | Returns the key of the cursor. Throws a "InvalidStateError" DOMException
-- | if the cursor is advancing or is finished.
key
  :: forall e
  .  ValueCursor
  -> Aff (idb :: IDB | e) Key
key =
  _key >>> map Key


-- | Returns the effective key of the cursor. Throws a "InvalidStateError" DOMException
-- | if the cursor is advancing or is finished.
primaryKey
  :: forall e
  .  ValueCursor
  -> Aff (idb :: IDB | e) Key
primaryKey =
  _primaryKey >>> map Key


-- | Returns the IDBObjectStore or IDBIndex the cursor was opened from.
source
  :: ValueCursor
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
-- INSTANCES
--
instance keyCursorKeyCursor :: IDBCursor KeyCursor where
  advance                    = Fn.runFn2 _advance
  continue c mk              = Fn.runFn2 _continue c (toNullable $ map (toKey >>> extractForeign) mk)
  continuePrimaryKey c k1 k2 = Fn.runFn3 _continuePrimaryKey c (extractForeign $ toKey k1) (extractForeign $ toKey k2)
  delete                     = _delete
  update c                   = toForeign >>> Fn.runFn2 _update c >>> map Key


instance valueCursorKeyCursor :: IDBCursor ValueCursor where
  advance                    = Fn.runFn2 _advance
  continue c mk              = Fn.runFn2 _continue c (toNullable $ map (toKey >>> extractForeign) mk)
  continuePrimaryKey c k1 k2 = Fn.runFn3 _continuePrimaryKey c (extractForeign $ toKey k1) (extractForeign $ toKey k2)
  delete                     = _delete
  update c                   = toForeign >>> Fn.runFn2 _update c >>> map Key


--------------------
-- FFI
--
foreign import _advance
  :: forall cursor e
  .  Fn2 cursor Int (Aff (idb :: IDB | e) Unit)


foreign import _continue
  :: forall cursor e
  .  Fn2 cursor (Nullable Foreign) (Aff (idb :: IDB | e) Unit)


foreign import _continuePrimaryKey
  :: forall cursor e
  .  Fn3 cursor Foreign Foreign (Aff (idb :: IDB | e) Unit)


foreign import _delete
  :: forall cursor e
  .  cursor
  -> (Aff (idb :: IDB | e) Unit)


foreign import _direction
  :: forall cursor
  .  Fn2 (String -> Nullable CursorDirection) cursor CursorDirection


foreign import _key
  :: forall cursor e
  .  cursor
  -> Aff (idb :: IDB | e) Foreign


foreign import _primaryKey
  :: forall cursor e
  .  cursor
  -> Aff (idb :: IDB | e) Foreign


foreign import _source
  :: forall cursor
  .  Fn3 (ObjectStore -> CursorSource) (Index -> CursorSource) cursor CursorSource


foreign import _update
  :: forall cursor e
  . Fn2 cursor Foreign (Aff (idb :: IDB | e) Foreign)


foreign import _value
  :: forall cursor val
  .  cursor
  -> val
