-- | A key has an associated type which is one of: number, date, string, or array.
-- |
-- | NOTE: Binary keys aren't supported yet.
module Database.IndexedDB.IDBKey
  ( module Database.IndexedDB.IDBKey.Internal
  ) where

import Database.IndexedDB.IDBKey.Internal
  ( class IDBKey
  , Key
  , none
  , toKey
  , fromKey
  , unsafeFromKey
  )
