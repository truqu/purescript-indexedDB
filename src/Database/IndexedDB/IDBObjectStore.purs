module Database.IndexedDB.IDBObjectStore
  ( add
  , autoIncrement
  , clear
  , count
  , createIndex
  , delete
  , deleteIndex
  , get
  , getAllKeys
  , getKey
  , index
  , indexNames
  , keyPath
  , name
  , openCursor
  , openKeyCursor
  , put
  ) where

import Prelude

import Control.Monad.Aff           (Aff)
import Control.Monad.Eff           (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn2, Fn3, Fn4)
import Data.Maybe                  (Maybe, fromMaybe)
import Data.Nullable               (Nullable, toMaybe, toNullable)

import Database.IndexedDB.Core


foreign import _add :: forall value eff. Fn3 IDBObjectStore value (Nullable KeyPath) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) KeyPath)
add :: forall value eff. IDBObjectStore -> value -> Maybe KeyPath -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) KeyPath
add store value mkey =
  Fn.runFn3 _add store value (toNullable mkey)


foreign import autoIncrement :: IDBObjectStore -> Boolean


foreign import clear :: IDBObjectStore -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION) Unit


foreign import _count :: forall eff. Fn2 IDBObjectStore (Nullable IDBKeyRange) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Int)
count :: forall eff. IDBObjectStore -> Maybe IDBKeyRange -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Int
count store range =
  Fn.runFn2 _count store (toNullable range)


foreign import _createIndex :: forall eff. Fn4 IDBObjectStore String (Array KeyPath) { unique :: Boolean, multiEntry :: Boolean } (Eff (idb :: INDEXED_DB, exception :: EXCEPTION) IDBIndex)
createIndex :: forall eff. IDBObjectStore -> String -> (Array KeyPath) -> { unique :: Boolean, multiEntry :: Boolean } -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION) IDBIndex
createIndex store name path params =
  Fn.runFn4 _createIndex store name path params


foreign import _delete :: forall eff. Fn2 IDBObjectStore (Nullable IDBKeyRange) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit)
delete :: forall eff. IDBObjectStore -> Maybe IDBKeyRange -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
delete store range =
  Fn.runFn2 _delete store (toNullable range)


foreign import _deleteIndex :: forall eff. Fn2 IDBObjectStore String (Eff (idb :: INDEXED_DB, exception :: EXCEPTION) Unit)
deleteIndex :: forall eff. IDBObjectStore -> String -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION) Unit
deleteIndex store name  =
  Fn.runFn2 _deleteIndex store name


foreign import _get :: forall a eff. Fn2 IDBObjectStore (Nullable IDBKeyRange) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Nullable a))
get :: forall a eff. IDBObjectStore -> Maybe IDBKeyRange -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Maybe a)
get store range =
  toMaybe <$> Fn.runFn2 _get store (toNullable range)


foreign import _getKey :: forall eff. Fn2 IDBObjectStore (Nullable IDBKeyRange) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Nullable KeyPath))
getKey :: forall eff. IDBObjectStore -> Maybe IDBKeyRange -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Maybe KeyPath)
getKey store range =
  toMaybe <$> Fn.runFn2 _getKey store (toNullable range)


foreign import _getAllKeys :: forall eff. Fn3 IDBObjectStore (Nullable IDBKeyRange) (Nullable Int) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Array KeyPath))
getAllKeys :: forall eff. IDBObjectStore -> Maybe IDBKeyRange -> Maybe Int -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Array KeyPath)
getAllKeys store range count =
  Fn.runFn3 _getAllKeys store (toNullable range) (toNullable count)


foreign import _openCursor :: forall eff. Fn3 IDBObjectStore (Nullable IDBKeyRange) (Nullable IDBCursorDirection) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBCursorWithValue)
openCursor :: forall eff. IDBObjectStore -> Maybe IDBKeyRange -> Maybe IDBCursorDirection -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBCursorWithValue
openCursor store range dir =
  Fn.runFn3 _openCursor store (toNullable range) (toNullable dir)


foreign import _openKeyCursor :: forall eff. Fn3 IDBObjectStore (Nullable IDBKeyRange) (Nullable IDBCursorDirection) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBKeyCursor)
openKeyCursor :: forall eff. IDBObjectStore -> Maybe IDBKeyRange -> Maybe IDBCursorDirection -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBKeyCursor
openKeyCursor store range dir =
  Fn.runFn3 _openKeyCursor store (toNullable range) (toNullable dir)


foreign import _index :: forall eff. Fn2 IDBObjectStore String (Eff (idb :: INDEXED_DB, exception :: EXCEPTION) IDBIndex)
index :: forall eff. IDBObjectStore -> String -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION) IDBIndex
index store name =
  Fn.runFn2 _index store name


foreign import indexNames :: IDBObjectStore -> Array String


foreign import keyPath :: IDBObjectStore -> Array String


foreign import name :: IDBObjectStore -> String


foreign import _put :: forall value eff. Fn3 IDBObjectStore value (Nullable KeyPath) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) KeyPath)
put :: forall value eff. IDBObjectStore -> value -> Maybe KeyPath -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) KeyPath
put store value mkey =
  Fn.runFn3 _put store value (toNullable mkey)
