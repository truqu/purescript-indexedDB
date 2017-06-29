module Database.IndexedDB.IDBCursorDirection where

import Prelude    (class Show)

import Data.Maybe (Maybe(..))


data IDBCursorDirection = Next | NextUnique | Prev | PrevUnique


instance showIDBCursorDirection :: Show IDBCursorDirection where
  show x =
    case x of
      Next       -> "next"
      NextUnique -> "nextunique"
      Prev       -> "prev"
      PrevUnique -> "prevunique"


fromString :: String -> Maybe IDBCursorDirection
fromString s =
  case s of
    "next"       -> Just Next
    "nextunique" -> Just NextUnique
    "prev"       -> Just Prev
    "prevunique" -> Just PrevUnique
    _            -> Nothing
