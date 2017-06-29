module Database.IndexedDB.IDBCursor
  ( class IDBCursor, advance, continue, continuePrimaryKey, delete, direction, key, primaryKey, source, update
  , class IDBCursorWithValue, value
  ) where

import Prelude                               (Unit, (>>>))

import Control.Monad.Aff                     (Aff)
import Control.Monad.Eff                     (Eff)
import Control.Monad.Eff.Exception           (EXCEPTION)
import Data.Function.Uncurried                as Fn
import Data.Function.Uncurried               (Fn2, Fn3)
import Data.Maybe                            (Maybe)
import Data.Nullable                         (Nullable, toNullable)
import Data.Foreign (Foreign, toForeign, unsafeFromForeign)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBCursorDirection  as IDBCursorDirection


class IDBCursor cursor where
    advance :: forall eff. cursor -> Int -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
    continue :: forall eff. cursor -> Maybe IDBKey -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
    continuePrimaryKey :: forall eff. cursor -> IDBKey -> IDBKey -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
    delete :: forall eff. cursor -> Aff (idb ::INDEXED_DB, exception :: EXCEPTION | eff) Unit
    direction :: cursor -> IDBCursorDirection
    key :: cursor -> IDBKey
    primaryKey :: cursor -> IDBKey
    source :: cursor -> IDBCursorSource
    update :: forall val eff. cursor -> val -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBKey


class IDBCursor cursor <= IDBCursorWithValue cursor where
    value :: forall val. cursor -> val


instance keyCursorKeyCursor :: IDBCursor IDBKeyCursor where
  advance            = Fn.runFn2 _advance
  continue c mk      = Fn.runFn2 _continue c (toNullable mk)
  continuePrimaryKey = Fn.runFn3 _continuePrimaryKey
  delete             = _delete
  direction          = Fn.runFn2 _direction (IDBCursorDirection.fromString >>> toNullable)
  key                = _key
  primaryKey         = _primaryKey
  source             = Fn.runFn3 _source IDBObjectStore IDBIndex
  update c           = toForeign >>> Fn.runFn2 _update c


instance valueCursorKeyCursor :: IDBCursor IDBValueCursor where
  advance            = Fn.runFn2 _advance
  continue c mk      = Fn.runFn2 _continue c (toNullable mk)
  continuePrimaryKey = Fn.runFn3 _continuePrimaryKey
  delete             = _delete
  direction          = Fn.runFn2 _direction (IDBCursorDirection.fromString >>> toNullable)
  key                = _key
  primaryKey         = _primaryKey
  source             = Fn.runFn3 _source IDBObjectStore IDBIndex
  update c           = toForeign >>> Fn.runFn2 _update c


instance valueCursorWithValueCursor :: IDBCursorWithValue IDBValueCursor where
  value              = _value >>> unsafeFromForeign


foreign import _advance :: forall cursor eff. Fn2 cursor Int (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit)


foreign import _continue :: forall cursor eff. Fn2 cursor (Nullable IDBKey) (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit)


foreign import _continuePrimaryKey :: forall cursor eff. Fn3 cursor IDBKey IDBKey (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit)


foreign import _delete :: forall cursor eff. cursor -> (Aff (idb ::INDEXED_DB, exception :: EXCEPTION | eff) Unit)


foreign import _direction :: forall cursor. Fn2 (String -> Nullable IDBCursorDirection) cursor IDBCursorDirection


foreign import _key :: forall cursor. cursor -> IDBKey


foreign import _primaryKey :: forall cursor. cursor -> IDBKey


foreign import _source :: forall cursor. Fn3 (IDBObjectStore -> IDBCursorSource) (IDBIndex -> IDBCursorSource) cursor IDBCursorSource


foreign import _update :: forall cursor eff. Fn2 cursor Foreign (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBKey)


foreign import _value :: forall cursor val. cursor -> val
