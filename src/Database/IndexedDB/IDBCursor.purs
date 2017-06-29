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

import Prelude                     (Unit, (>>>))

import Control.Monad.Aff           (Aff)
import Control.Monad.Eff           (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn2, Fn3)
import Data.Maybe                  (Maybe)
import Data.Nullable               (Nullable, toNullable)
import Data.Foreign                (Foreign, toForeign, unsafeFromForeign)

import Database.IndexedDB.Core


--------------------
-- INTERFACES
--
class IDBCursor cursor where
    advance :: forall eff. cursor -> Int -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
    continue :: forall eff. cursor -> Maybe Key -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
    continuePrimaryKey :: forall eff. cursor -> Key -> Key -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
    delete :: forall eff. cursor -> Aff (idb ::INDEXED_DB, exception :: EXCEPTION | eff) Unit
    update :: forall val eff. cursor -> val -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Key


--------------------
-- ATTRIBUTES
--
direction :: KeyCursor -> CursorDirection
direction =
  Fn.runFn2 _direction (parse >>> toNullable)


key :: KeyCursor -> Key
key =
  _key


primaryKey :: KeyCursor -> Key
primaryKey =
  _primaryKey


source :: KeyCursor -> CursorSource
source =
  Fn.runFn3 _source ObjectStore Index


-- NOTE: Polymorphism not used here cause *we want* those methods to be distincs for
-- the concrete types mostly for consistency with the Database.IndexedDB.IDBIndex module
-- where the IDBIndex interfaces is shared by Index and ObjectStore, but attributes of
-- respective concrete types aren't shared.
direction' :: ValueCursor -> CursorDirection
direction' =
  Fn.runFn2 _direction (parse >>> toNullable)


key' :: ValueCursor -> Key
key' =
  _key


primaryKey' :: ValueCursor -> Key
primaryKey' =
  _primaryKey


source' :: ValueCursor -> CursorSource
source' =
  Fn.runFn3 _source ObjectStore Index


value :: forall val. ValueCursor -> val
value =
  _value >>> unsafeFromForeign


--------------------
-- INSTANCES
--
instance keyCursorKeyCursor :: IDBCursor KeyCursor where
  advance            = Fn.runFn2 _advance
  continue c mk      = Fn.runFn2 _continue c (toNullable mk)
  continuePrimaryKey = Fn.runFn3 _continuePrimaryKey
  delete             = _delete
  update c           = toForeign >>> Fn.runFn2 _update c


instance valueCursorKeyCursor :: IDBCursor ValueCursor where
  advance            = Fn.runFn2 _advance
  continue c mk      = Fn.runFn2 _continue c (toNullable mk)
  continuePrimaryKey = Fn.runFn3 _continuePrimaryKey
  delete             = _delete
  update c           = toForeign >>> Fn.runFn2 _update c


--------------------
-- FFI
--
foreign import _advance :: forall cursor eff. Fn2 cursor Int (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit)


foreign import _continue :: forall cursor eff. Fn2 cursor (Nullable Key) (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit)


foreign import _continuePrimaryKey :: forall cursor eff. Fn3 cursor Key Key (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit)


foreign import _delete :: forall cursor eff. cursor -> (Aff (idb ::INDEXED_DB, exception :: EXCEPTION | eff) Unit)


foreign import _direction :: forall cursor. Fn2 (String -> Nullable CursorDirection) cursor CursorDirection


foreign import _key :: forall cursor. cursor -> Key


foreign import _primaryKey :: forall cursor. cursor -> Key


foreign import _source :: forall cursor. Fn3 (ObjectStore -> CursorSource) (Index -> CursorSource) cursor CursorSource


foreign import _update :: forall cursor eff. Fn2 cursor Foreign (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Key)


foreign import _value :: forall cursor val. cursor -> val
