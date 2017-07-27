-- | A cursor is used to iterate over a range of records in an index or
-- | an object store in a specific direction.
module Database.IndexedDB.IDBCursor
  -- * Cursor Manipulation
  ( KeyCursor
  , ValueCursor
  , CursorDirection(..)
  , advance
  , continue
  , continuePrimaryKey
  , delete
  , update

  -- * Concrete Cursor Manipulation
  , direction
  , key
  , primaryKey
  , source
  , value
  ) where

import Prelude                            (class Show, Unit, ($), (>>>), map)

import Control.Monad.Aff                  (Aff)
import Data.Foreign                       (Foreign, toForeign, unsafeFromForeign)
import Data.Function.Uncurried             as Fn
import Data.Function.Uncurried            (Fn2, Fn3)
import Data.Maybe                         (Maybe(..))
import Data.Nullable                      (Nullable, toNullable)
import Data.String.Read                   (class Read, read)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBKey.Internal (class IDBKey, Key(..), toKey, extractForeign)
import Database.IndexedDB.Class           (class IDBCursor, class IDBConcreteCursor)


--------------------
-- TYPES
--

-- | A cursor is used to iterate over a range of records in an index or an object store
-- | in a specific direction. A KeyCursor doesn't hold any value.
foreign import data KeyCursor :: Type


-- | A cursor is used to iterate over a range of records in an index or an object store
-- | in a specific direction. A ValueCursor also holds the value corresponding to matching key.
foreign import data ValueCursor :: Type


-- | A cursor has a direction that determines whether it moves in monotonically
-- | increasing or decreasing order of the record keys when iterated, and if it
-- | skips duplicated values when iterating indexes.
-- | The direction of a cursor also determines if the cursor initial position is at
-- | the start of its source or at its end.
data CursorDirection
  = Next
  | NextUnique
  | Prev
  | PrevUnique


--------------------
-- INTERFACES
--

-- | Advances the cursor through the next count records in range.
advance
    :: forall e cursor. (IDBCursor cursor)
    => cursor
    -> Int
    -> Aff (idb :: IDB | e) Unit
advance =
  Fn.runFn2 _advance


-- | Advances the cursor to the next record in range matching or after key.
continue
    :: forall e k cursor. (IDBKey k) => (IDBCursor cursor)
    => cursor
    -> Maybe k
    -> Aff (idb :: IDB | e) Unit
continue c mk =
  Fn.runFn2 _continue c (toNullable $ map (toKey >>> extractForeign) mk)


-- | Advances the cursor to the next record in range matching or after key and primaryKey. Throws an "InvalidAccessError" DOMException if the source is not an index.
continuePrimaryKey
    :: forall e k cursor. (IDBKey k) => (IDBCursor cursor)
    => cursor
    -> k
    -> k
    -> Aff (idb :: IDB | e) Unit
continuePrimaryKey c k1 k2 =
  Fn.runFn3 _continuePrimaryKey c (extractForeign $ toKey k1) (extractForeign $ toKey k2)


-- | Delete the record pointed at by the cursor with a new value.
delete
    :: forall e cursor. (IDBCursor cursor)
    => cursor
    -> Aff (idb :: IDB | e) Unit
delete =
  _delete


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
  toForeign >>> Fn.runFn2 _update c >>> map Key


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
  _key >>> map Key


-- | Returns the effective key of the cursor. Throws a "InvalidStateError" DOMException
-- | if the cursor is advancing or is finished.
primaryKey
  :: forall e cursor. (IDBConcreteCursor cursor)
  => cursor
  -> Aff (idb :: IDB | e) Key
primaryKey =
  _primaryKey >>> map Key


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
-- INSTANCES
--

instance idbCursorKeyCursor :: IDBCursor KeyCursor


instance idbCursorValueCursor :: IDBCursor ValueCursor


instance idbConcreteCursorKeyCursor :: IDBConcreteCursor KeyCursor


instance idbConcreteCursorValueCursor :: IDBConcreteCursor ValueCursor


instance showKeyCursor :: Show KeyCursor where
  show = _showCursor


instance showValueCursor :: Show ValueCursor where
  show = _showCursor


instance showCursorDirection :: Show CursorDirection where
  show x =
    case x of
      Next       -> "next"
      NextUnique -> "nextunique"
      Prev       -> "prev"
      PrevUnique -> "prevunique"



instance readCursorDirection :: Read CursorDirection where
  read s =
    case s of
      "next"       -> Just Next
      "nextunique" -> Just NextUnique
      "prev"       -> Just Prev
      "prevunique" -> Just PrevUnique
      _            -> Nothing


--------------------
-- FFI
--

foreign import _showCursor
  :: forall cursor
  .  cursor
  -> String


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
