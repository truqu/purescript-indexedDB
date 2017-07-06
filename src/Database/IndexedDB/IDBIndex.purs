-- | An index allows looking up records in an object store using properties of the values
-- | in the object stores records.
module Database.IndexedDB.IDBIndex
  ( module Database.IndexedDB.IDBIndex.Internal
  ) where

import Database.IndexedDB.IDBIndex.Internal
  ( class IDBIndex, count, get, getAllKeys, getKey, openCursor, openKeyCursor
  , IDBIndexParameters
  , keyPath
  , multiEntry
  , name
  , objectStore
  , unique
  , defaultParameters
  )
