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

import Database.IndexedDB.Core

import Data.Function.Uncurried (Fn2, Fn3)
import Data.Function.Uncurried as Fn
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Data.String.Read (read)
import Database.IndexedDB.IDBKey.Internal (class IDBKey, Key, toKey, unsafeFromKey)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign, unsafeFromForeign, unsafeToForeign)
import Prelude (Unit, ($), (>>>), (<<<), map)

--------------------
-- INTERFACES
--

-- | Advances the cursor through the next count records in range.
advance
  :: forall cursor
   . (IDBCursor cursor)
  => cursor
  -> Int
  -> Aff Unit
advance c =
  fromEffectFnAff <<< Fn.runFn2 _advance c

-- | Advances the cursor to the next record in range matching or after key.
continue
  :: forall k cursor
   . (IDBKey k)
  => (IDBCursor cursor)
  => cursor
  -> Maybe k
  -> Aff Unit
continue c mk =
  fromEffectFnAff $ Fn.runFn2 _continue c (toNullable $ map (toKey >>> unsafeFromKey) mk)

-- | Advances the cursor to the next record in range matching or after key and primaryKey. Throws an "InvalidAccessError" DOMException if the source is not an index.
continuePrimaryKey
  :: forall k cursor
   . (IDBKey k)
  => (IDBCursor cursor)
  => cursor
  -> k
  -> k
  -> Aff Unit
continuePrimaryKey c k1 k2 =
  fromEffectFnAff $ Fn.runFn3 _continuePrimaryKey c (unsafeFromKey $ toKey k1) (unsafeFromKey $ toKey k2)

-- | Delete the record pointed at by the cursor with a new value.
delete
  :: forall cursor
   . (IDBCursor cursor)
  => cursor
  -> Aff Unit
delete =
  fromEffectFnAff <<< _delete

-- | Update the record pointed at by the cursor with a new value.
-- |
-- | Throws a "DataError" DOMException if the effective object store uses
-- | in-line keys and the key would have changed.
update
  :: forall val cursor
   . (IDBCursor cursor)
  => cursor
  -> val
  -> Aff Key
update c =
  map toKey <<< fromEffectFnAff <<< Fn.runFn2 _update c <<< unsafeToForeign

--------------------
-- ATTRIBUTES
--

-- | Returns the direction (Next|NextUnique|Prev|PrevUnique) of the cursor.
direction
  :: forall cursor
   . (IDBConcreteCursor cursor)
  => cursor
  -> CursorDirection
direction =
  Fn.runFn2 _direction (read >>> toNullable)

-- | Returns the key of the cursor. Throws a "InvalidStateError" DOMException
-- | if the cursor is advancing or is finished.
key
  :: forall cursor
   . (IDBConcreteCursor cursor)
  => cursor
  -> Aff Key
key =
  map toKey <<< fromEffectFnAff <<< _key

-- | Returns the effective key of the cursor. Throws a "InvalidStateError" DOMException
-- | if the cursor is advancing or is finished.
primaryKey
  :: forall cursor
   . (IDBConcreteCursor cursor)
  => cursor
  -> Aff Key
primaryKey =
  map toKey <<< fromEffectFnAff <<< _primaryKey

-- | Returns the IDBObjectStore or IDBIndex the cursor was opened from.
source
  :: forall cursor
   . (IDBConcreteCursor cursor)
  => cursor
  -> CursorSource
source =
  Fn.runFn3 _source ObjectStore Index

value
  :: forall val
   . ValueCursor
  -> val
value =
  _value >>> unsafeFromForeign

--------------------
-- FFI
--

foreign import _advance
  :: forall cursor
   . Fn2 cursor Int (EffectFnAff Unit)

foreign import _continue
  :: forall cursor
   . Fn2 cursor (Nullable Foreign) (EffectFnAff Unit)

foreign import _continuePrimaryKey
  :: forall cursor
   . Fn3 cursor Foreign Foreign (EffectFnAff Unit)

foreign import _delete
  :: forall cursor
   . cursor
  -> (EffectFnAff Unit)

foreign import _direction
  :: forall cursor
   . Fn2 (String -> Nullable CursorDirection) cursor CursorDirection

foreign import _key
  :: forall cursor
   . cursor
  -> EffectFnAff Key

foreign import _primaryKey
  :: forall cursor
   . cursor
  -> EffectFnAff Key

foreign import _source
  :: forall cursor
   . Fn3 (ObjectStore -> CursorSource) (Index -> CursorSource) cursor CursorSource

foreign import _update
  :: forall cursor
   . Fn2 cursor Foreign (EffectFnAff Foreign)

foreign import _value
  :: forall cursor val
   . cursor
  -> val
