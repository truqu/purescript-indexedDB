-- | Opaque typeclass definitions for easy reuse of functions over
-- | imported foreign types.
module Database.IndexedDB.Class where


-- | Cursor objects implement the IDBCursor interface.
-- | There is only ever one IDBCursor instance representing a given cursor.
-- | There is no limit on how many cursors can be used at the same time.
class IDBCursor cursor

-- | A concrete cursor not only shares IDBCursor properties, but also some
-- | specific attributes (see KeyCursor or CursorWithValue).
class (IDBCursor cursor) <= IDBConcreteCursor cursor
