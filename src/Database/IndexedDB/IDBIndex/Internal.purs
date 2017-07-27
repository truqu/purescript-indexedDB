-- | An index allows looking up records in an object store using properties of the values
-- | in the object stores records.
module Database.IndexedDB.IDBIndex.Internal where

import Prelude

import Control.Monad.Aff                  (Aff)
import Control.Monad.Eff                  (Eff)
import Control.Monad.Eff.Exception        (Error)
import Data.Foreign                       (Foreign, unsafeFromForeign)
import Data.Function.Uncurried             as Fn
import Data.Function.Uncurried            (Fn2, Fn3, Fn4)
import Data.Maybe                         (Maybe)
import Data.Nullable                      (Nullable, toMaybe, toNullable)

import Database.IndexedDB.Core            (IDB, Index, Key, KeyRange, KeyPath, ObjectStore)
import Database.IndexedDB.IDBCursor       (CursorDirection, KeyCursor, ValueCursor)
import Database.IndexedDB.IDBKey.Internal (class IDBKey, Key(..))


--------------------
-- INTERFACES
--
-- | The IDBIndex interface represents an index handle.
-- | Any of these methods throw an "TransactionInactiveError" DOMException
-- | if called when the transaction is not active.
class IDBIndex index where
  -- | Retrieves the number of records matching the key range in query.
  count
    :: forall e
    .  index
    -> Maybe KeyRange
    -> Aff (idb :: IDB | e) Int

  -- | Retrieves the value of the first record matching the given key range in query.
  -- |
  -- | NOTE
  -- | The coercion from `a` to any type is unsafe and might throw a runtime error if incorrect.
  get
    :: forall a e
    .  index
    -> KeyRange
    -> Aff (idb :: IDB | e) (Maybe a)

  -- | Retrieves the keys of records matching the given key range in query
  -- | (up to the number given if given).
  getAllKeys
    :: forall e
    .  index
    -> Maybe KeyRange
    -> Maybe Int
    -> Aff (idb :: IDB | e) (Array Key)

  -- | Retrieves the key of the first record matching the given key or key range in query.
  getKey
    :: forall e
    .  index
    -> KeyRange
    -> Aff (idb :: IDB | e) (Maybe Key)

  -- | Opens a ValueCursor over the records matching query, ordered by direction.
  -- | If query is `Nothing`, all records in index are matched.
  openCursor
    :: forall e e'
    .  index
    -> Maybe KeyRange
    -> CursorDirection
    -> Callbacks ValueCursor e'
    -> Aff (idb :: IDB | e) Unit

  -- | Opens a KeyCursor over the records matching query, ordered by direction.
  -- | If query is `Nothing`, all records in index are matched.
  openKeyCursor
    :: forall e e'
    .  index
    -> Maybe KeyRange
    -> CursorDirection
    -> Callbacks KeyCursor e'
    -> Aff (idb :: IDB | e) Unit


-- | Flags to set on the index.
-- |
-- | An index has a `unique` flag. When this flag is set, the index enforces that no
-- | two records in the index has the same key. If a record in the index’s referenced
-- | object store is attempted to be inserted or modified such that evaluating the index’s
-- | key path on the records new value yields a result which already exists in the index,
-- | then the attempted modification to the object store fails.
-- |
-- | An index has a `multiEntry` flag. This flag affects how the index behaves when the
-- | result of evaluating the index’s key path yields an array key. If the `multiEntry` flag
-- | is unset, then a single record whose key is an array key is added to the index.
-- | If the `multiEntry` flag is true, then the one record is added to the index for each
-- | of the subkeys.
type IDBIndexParameters =
  { unique     :: Boolean
  , multiEntry :: Boolean
  }


-- | Callbacks to manipulate a cursor from an Open*Cursor call
type Callbacks cursor e =
  { onSuccess  :: cursor -> Eff ( | e) Unit
  , onError    :: Error -> Eff ( | e) Unit
  , onComplete :: Eff ( | e) Unit
  }


defaultParameters :: IDBIndexParameters
defaultParameters =
  { unique     : false
  , multiEntry : false
  }


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
-- INSTANCES
--
instance idbIndexIndex :: IDBIndex Index where
  count index range =
    Fn.runFn2 _count index (toNullable range)

  get index range =
    (toMaybe >>> map unsafeFromForeign) <$> Fn.runFn2 _get index range

  getAllKeys index range count =
    map Key <$> Fn.runFn3 _getAllKeys index (toNullable range) (toNullable count)

  getKey index range =
    (toMaybe >>> map Key) <$> Fn.runFn2 _getKey index range

  openCursor index range dir cb =
    Fn.runFn4 _openCursor index (toNullable range) (show dir) cb

  openKeyCursor index range dir cb =
    Fn.runFn4 _openKeyCursor index (toNullable range) (show dir) cb


instance idbIndexObjectStore :: IDBIndex ObjectStore where
  count store range =
    Fn.runFn2 _count store (toNullable range)

  get store range =
    (toMaybe >>> map unsafeFromForeign) <$> Fn.runFn2 _get store range

  getAllKeys store range count =
    map Key <$> Fn.runFn3 _getAllKeys store (toNullable range) (toNullable count)

  getKey store range =
    (toMaybe >>> map Key) <$> Fn.runFn2 _getKey store range

  openCursor store range dir cb =
    Fn.runFn4 _openCursor store (toNullable range) (show dir) cb

  openKeyCursor store range dir cb =
    Fn.runFn4 _openKeyCursor store (toNullable range) (show dir) cb


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
    . Fn2 index KeyRange (Aff (idb :: IDB | e) (Nullable Foreign))


foreign import _getAllKeys
    :: forall index e
    .  Fn3 index (Nullable KeyRange) (Nullable Int) (Aff (idb :: IDB | e) (Array Foreign))


foreign import _getKey
    :: forall index e
    .  Fn2 index KeyRange (Aff (idb :: IDB | e) (Nullable Foreign))


foreign import _openCursor
    :: forall index e e'
    .  Fn4 index (Nullable KeyRange) String (Callbacks ValueCursor e') (Aff (idb :: IDB | e) Unit)


foreign import _openKeyCursor
    :: forall index e e'
    .  Fn4 index (Nullable KeyRange) String (Callbacks KeyCursor e') (Aff (idb :: IDB | e) Unit)
