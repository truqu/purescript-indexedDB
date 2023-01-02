-- | An index allows looking up records in an object store using properties of the values
-- | in the object stores records.
module Database.IndexedDB.IDBIndex
  -- * Types
  ( Callbacks

  -- * Interface
  , count
  , get
  , getAllKeys
  , getKey
  , openCursor
  , openKeyCursor

  -- * Attributes
  , keyPath
  , multiEntry
  , name
  , objectStore
  , unique
  ) where

import Database.IndexedDB.Core

import Data.Function.Uncurried (Fn2, Fn3, Fn4)
import Data.Function.Uncurried as Fn
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe, toNullable)
import Database.IndexedDB.IDBKey.Internal (Key, toKey)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Exception (Error)
import Foreign (Foreign, unsafeFromForeign)
import Prelude (Unit, map, show, ($), (>>>))

--------------------
-- TYPES
--

-- | Callbacks to manipulate a cursor from an Open*Cursor call
type Callbacks cursor =
  { onSuccess :: cursor -> Effect Unit
  , onError :: Error -> Effect Unit
  , onComplete :: Effect Unit
  }

--------------------
-- INTERFACES
--

-- | Retrieves the number of records matching the key range in query.
count
  :: forall index
   . (IDBIndex index)
  => index
  -> Maybe KeyRange
  -> Aff Int
count index range =
  fromEffectFnAff $ Fn.runFn2 _count index (toNullable range)

-- | Retrieves the value of the first record matching the given key range in query.
-- |
-- | NOTE
-- | The coercion from `a` to any type is unsafe and might throw a runtime error if incorrect.
get
  :: forall a index
   . (IDBIndex index)
  => index
  -> KeyRange
  -> Aff (Maybe a)
get index range =
  map (toMaybe >>> map unsafeFromForeign) $ fromEffectFnAff $ Fn.runFn2 _get index range

-- | Retrieves the keys of records matching the given key range in query
-- | (up to the number given if given).
getAllKeys
  :: forall index
   . (IDBIndex index)
  => index
  -> Maybe KeyRange
  -> Maybe Int
  -> Aff (Array Key)
getAllKeys index range n =
  map (map toKey) $ fromEffectFnAff $ Fn.runFn3 _getAllKeys index (toNullable range) (toNullable n)

-- | Retrieves the key of the first record matching the given key or key range in query.
getKey
  :: forall index
   . (IDBIndex index)
  => index
  -> KeyRange
  -> Aff (Maybe Key)
getKey index range =
  map (toMaybe >>> map toKey) $ fromEffectFnAff $ Fn.runFn2 _getKey index range

-- | Opens a ValueCursor over the records matching query, ordered by direction.
-- | If query is `Nothing`, all records in index are matched.
openCursor
  :: forall index
   . (IDBIndex index)
  => index
  -> Maybe KeyRange
  -> CursorDirection
  -> Callbacks ValueCursor
  -> Aff Unit
openCursor index range dir cb =
  fromEffectFnAff $ Fn.runFn4 _openCursor index (toNullable range) (show dir) cb

-- | Opens a KeyCursor over the records matching query, ordered by direction.
-- | If query is `Nothing`, all records in index are matched.
openKeyCursor
  :: forall index
   . (IDBIndex index)
  => index
  -> Maybe KeyRange
  -> CursorDirection
  -> Callbacks KeyCursor
  -> Aff Unit
openKeyCursor index range dir cb =
  fromEffectFnAff $ Fn.runFn4 _openKeyCursor index (toNullable range) (show dir) cb

--------------------
-- ATTRIBUTES
--
-- | Returns the key path of the index.
keyPath
  :: Index
  -> KeyPath
keyPath =
  _keyPath

-- | Returns true if the index's multiEntry flag is set.
multiEntry
  :: Index
  -> Boolean
multiEntry =
  _multiEntry

-- | Returns the name of the index.
name
  :: Index
  -> String
name =
  _name

-- | Returns the IDBObjectStore the index belongs to.
objectStore
  :: Index
  -> ObjectStore
objectStore =
  _objectStore

-- | Returns true if the index's unique flag is set.
unique
  :: Index
  -> Boolean
unique =
  _unique

--------------------
-- FFI
--
foreign import _keyPath
  :: Index
  -> Array String

foreign import _multiEntry
  :: Index
  -> Boolean

foreign import _name
  :: Index
  -> String

foreign import _objectStore
  :: Index
  -> ObjectStore

foreign import _unique
  :: Index
  -> Boolean

foreign import _count
  :: forall index
   . Fn2 index (Nullable KeyRange) (EffectFnAff Int)

foreign import _get
  :: forall index
   . Fn2 index KeyRange (EffectFnAff (Nullable Foreign))

foreign import _getAllKeys
  :: forall index
   . Fn3 index (Nullable KeyRange) (Nullable Int) (EffectFnAff (Array Foreign))

foreign import _getKey
  :: forall index
   . Fn2 index KeyRange (EffectFnAff (Nullable Foreign))

foreign import _openCursor
  :: forall index
   . Fn4 index (Nullable KeyRange) String (Callbacks ValueCursor) (EffectFnAff Unit)

foreign import _openKeyCursor
  :: forall index
   . Fn4 index (Nullable KeyRange) String (Callbacks KeyCursor) (EffectFnAff Unit)
