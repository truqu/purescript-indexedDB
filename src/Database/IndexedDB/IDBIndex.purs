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

import Prelude                            (Unit, map, show, (<$>), (>>>))

import Control.Monad.Aff                  (Aff)
import Control.Monad.Eff                  (Eff)
import Control.Monad.Eff.Exception        (Error)
import Data.Foreign                       (Foreign, unsafeFromForeign)
import Data.Function.Uncurried             as Fn
import Data.Function.Uncurried            (Fn2, Fn3, Fn4)
import Data.Maybe                         (Maybe)
import Data.Nullable                      (Nullable, toMaybe, toNullable)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBKey.Internal (class IDBKey, toKey)


--------------------
-- TYPES
--

-- | Callbacks to manipulate a cursor from an Open*Cursor call
type Callbacks cursor e =
  { onSuccess  :: cursor -> Eff ( | e) Unit
  , onError    :: Error -> Eff ( | e) Unit
  , onComplete :: Eff ( | e) Unit
  }


--------------------
-- INTERFACES
--

-- | Retrieves the number of records matching the key range in query.
count
  :: forall e index. (IDBIndex index)
  =>  index
  -> Maybe KeyRange
  -> Aff (idb :: IDB | e) Int
count index range =
  Fn.runFn2 _count index (toNullable range)


-- | Retrieves the value of the first record matching the given key range in query.
-- |
-- | NOTE
-- | The coercion from `a` to any type is unsafe and might throw a runtime error if incorrect.
get
  :: forall a e index. (IDBIndex index)
  => index
  -> KeyRange
  -> Aff (idb :: IDB | e) (Maybe a)
get index range =
  (toMaybe >>> map unsafeFromForeign) <$> Fn.runFn2 _get index range


-- | Retrieves the keys of records matching the given key range in query
-- | (up to the number given if given).
getAllKeys
  :: forall e index key. (IDBIndex index) => (IDBKey key)
  => index
  -> Maybe KeyRange
  -> Maybe Int
  -> Aff (idb :: IDB | e) (Array key)
getAllKeys index range n =
  Fn.runFn3 _getAllKeys index (toNullable range) (toNullable n)


-- | Retrieves the key of the first record matching the given key or key range in query.
getKey
  :: forall e index key. (IDBIndex index) => (IDBKey key)
  => index
  -> KeyRange
  -> Aff (idb :: IDB | e) (Maybe key)
getKey index range =
  toMaybe <$> Fn.runFn2 _getKey index range


-- | Opens a ValueCursor over the records matching query, ordered by direction.
-- | If query is `Nothing`, all records in index are matched.
openCursor
  :: forall e e' index. (IDBIndex index)
  =>  index
  -> Maybe KeyRange
  -> CursorDirection
  -> Callbacks ValueCursor e'
  -> Aff (idb :: IDB | e) Unit
openCursor index range dir cb =
  Fn.runFn4 _openCursor index (toNullable range) (show dir) cb


-- | Opens a KeyCursor over the records matching query, ordered by direction.
-- | If query is `Nothing`, all records in index are matched.
openKeyCursor
  :: forall e e' index. (IDBIndex index)
    => index
    -> Maybe KeyRange
    -> CursorDirection
    -> Callbacks KeyCursor e'
    -> Aff (idb :: IDB | e) Unit
openKeyCursor index range dir cb =
  Fn.runFn4 _openKeyCursor index (toNullable range) (show dir) cb


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
    :: forall index e
    .  Fn2 index (Nullable KeyRange) (Aff (idb :: IDB | e) Int)


foreign import _get
    :: forall index e
    .  Fn2 index KeyRange (Aff (idb :: IDB | e) (Nullable Foreign))


foreign import _getAllKeys
    :: forall index e k. (IDBKey k)
    => Fn3 index (Nullable KeyRange) (Nullable Int) (Aff (idb :: IDB | e) (Array k))


foreign import _getKey
    :: forall index e k. (IDBKey k)
    => Fn2 index KeyRange (Aff (idb :: IDB | e) (Nullable k))


foreign import _openCursor
    :: forall index e e'
    .  Fn4 index (Nullable KeyRange) String (Callbacks ValueCursor e') (Aff (idb :: IDB | e) Unit)


foreign import _openKeyCursor
    :: forall index e e'
    .  Fn4 index (Nullable KeyRange) String (Callbacks KeyCursor e') (Aff (idb :: IDB | e) Unit)
