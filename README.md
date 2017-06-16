## API

This document is a general grooming of the current state of the IndexedDB API. It covers only
the features specified in the official specs. 

### Remarks

- Better define a 'all' range instead of using Maybe `IDBKeyRange` in function
signatures (Nothing meaning 'all').

- Some errors (like TypeError or DataError) can be avoided via static typing

- The `IDBRequest` is mostly a callback result holding an error or a value. We probably want to
  use a typed Except or ExceptT instead.


### Table of Contents

- [IDBCursor](#idbcursor)
- [IDBCursorWithValue](#idbcursorwithvalue)
- [IDBCursorDirection](#idbcursordirection)
- [IDBDatabase](#idbdatabase)
- [IDBError](#idberror)
- [IDBFactory](#idbfactory)
- [IDBIndex](#idbindex)
- [IDBKeyRange](#idbkeyrange)
- [IDBRequest](#idbrequest)
- [IDBOpenDBRequest](#idbopendbrequest)
- [IDBObjectStore](#idbobjectstore)
- [IDBTransaction](#idbtransaction)
- [IDBTransactionMode](#idbtransactionmode)


---


#### IDBCursor
> https://developer.mozilla.org/en-US/docs/Web/API/IDBCursor

- source :: [IDBIndex](#idbindex), [IDBObjectStore](#idbobjectstore)
- direction :: [IDBCursorDirection](#idbcursordirection)
- key :: [IDBKey](#idbkey)
- primaryKey :: [IDBKey](#idbkey)
- value :: Any
- advance :: [IDBCursor](#idbcursor) -> Int -> ()
  > `throw` TransactionInactiveError, TypeError, InvalidStateError
- continue :: [IDBCursor](#idbcursor) -> Maybe [IDBKey](#idbkey) -> ()
  > `throw` TransactionInactivError, DataError, InvalidStateError
- continuePrimaryKey :: [IDBCursor](#idbcursor) -> [IDBKey](#idbkey) -> [IDBKey](#idbkey) -> ()
  > `throw` TransactionInactiveError, DataError, InvalidStateError, InvalidAccessError


---


#### IDBCursorWithValue
> https://developer.mozilla.org/en-US/docs/Web/API/IDBCursorwithValue

Inherit from [IDBCursor](#idbcursor)

- delete :: [IDBCursor](#idbcursor) -> [IDBRequest](#idbrequest) ()
  > `throw` TransactionInactiveError, ReadOnlyError, InvalidStateError
- update :: [IDBCursor](#idbcursor) -> a -> [IDBRequest](#idbrequest) a
  > `throw` TransactionInactiveError, ReadOnlyError, InvalidStateError, DataError, DataCloneError


---


#### IDBCursorDirection
> https://www.w3.org/TR/IndexedDB/#idl-def-IDBCursorDirection

data [IDBCursorDirection](#idbcursordirection)
  = Next
  | NextUnique
  | Prev
  | PrevUnique


---


#### IDBDatabase
>  https://www.w3.org/TR/IndexedDB/#idl-def-IDBDatabase

- name :: String
- version :: Long
- objectStoreNames :: [String]
- close :: [IDBDatabase](#idbdatabase) -> ()
- createObjectStore :: [IDBDatabase](#idbdatabase) -> String -> { keyPath :: String, autoIncrement :: Bool } -> [IDBObjectStore](#idbobjectstore)
  > `throw` InvalidStateError, TransactionInactiveError, ConstraintError, InvalidAccessError
- deleteObjectStore :: [IDBDatabase](#idbdatabase) -> String -> ()
  > `throw` InvalidSateError, TransactionInactiveError, NotFoundError
- transaction :: [IDBDatabase](#idbdatabase) -> [String] -> [IDBTransactionMode](#idbtransactionmode) -> [IDBTransaction](#idbtransaction)
  > `throw` InvalidStateError, NotFoundError, TypeError, InvalidAccessError 

##### Events
- onabort
- onerror
- onversionchange


---


#### IDBError
> https://www.w3.org/TR/IndexedDB/#exceptions

data IDBError 
  = AbortError 
  | ConstraintError
  | QuotaExceededError
  | UnknownError
  | NoError
  | VersionError


---


#### IDBFactory
> https://www.w3.org/TR/IndexedDB/#idl-def-IDBFactory

The method `cmp` isn't included; instead, we consider [IDBKey](#idbkey) to be comparable.

- open :: String -> Maybe Long -> [IDBOpenDBRequest](#idbopendbrequest) ()
- deleteDatabase :: String -> [IDBOpenDBRequest](#idbopendbrequest) ()


---


#### IDBIndex
> https://www.w3.org/TR/IndexedDB/#index-concept  
> https://www.w3.org/TR/IndexedDB/#index

- name :: String
- objectStore :: [IDBObjectStore](#idbobjectstore)
- keyPath :: String
- multiEntry :: Bool
- unique :: Bool
- count :: [IDBIndex](#idbindex) -> Maybe [IDBKeyRange](#idbkeyrange) -> [IDBRequest](#idbrequest) Int
  > `throw` TransactionInactiveError, DataError, InvalidStateError
- get :: [IDBIndex](#idbindex) -> [IDBKeyRange](#idbkeyrange) -> [IDBRequest](#idbrequest) a
  > `throw` TransactionInactiveError, DataError, InvalidStateError
- getKey :: [IDBIndex](#idbindex) -> [IDBKeyRange](#idbkeyrange) -> [IDBRequest](#idbrequest) [IDBKey](#idbkey)
  > `throw` TransactionInactiveError, DataError, InvalidStateError
- openCursor :: [IDBIndex](#idbindex) -> Maybe [IDBKeyRange](#idbkeyrange)  -> Maybe Direction -> [IDBRequest](#idbrequest) CursorWithValue
  > `throw` TransactionInactiveError, DataError, TypeError, InvalidStateError
- openKeyCursor :: [IDBIndex](#idbindex) -> Maybe [IDBKeyRange](#idbkeyrange)-> Maybe Direction -> [IDBRequest](#idbrequest) Cursor
  > `throw` TransactionInactiveError, DataError, TypeError, InvalidStateError


---


#### IDBKey
> https://www.w3.org/TR/IndexedDB/#key-construct

Should be comparable / derive Ord

data IDBKey 
  = Int Int
  | Float Float
  | String String
  | Date Date
  | Array [[IDBKey](#idbkey)]


---


#### IDBKeyRange
> https://www.w3.org/TR/IndexedDB/#idl-def-IDBKeyRange

- lower :: [IDBKey](#idbkey)
- upper :: [IDBKey](#idbkey)
- lowerOpen :: Boolean
- upperOpen :: Boolean
- bound :: [IDBKey](#idbkey) -> [IDBKey](#idbkey) -> Bool -> Bool -> [IDBKeyRange](#idbkeyrange)
  > `throw` DataError
- only :: [IDBKey](#idbkey) -> [IDBKeyRange](#idbkeyrange)
  > `throw` DataError
- lowerBound :: [IDBKey](#idbkey) -> Bool -> [IDBKeyRange](#idbkeyrange)
  > `throw` DataError
- upperBound :: [IDBKey](#idbkey) -> Bool -> [IDBKeyRange](#idbkeyrange)
  > `throw` DataError
- includes :: [IDBKey](#idbkey) -> Boolean
  > `throw` DataError


---


#### IDBRequest
> https://www.w3.org/TR/IndexedDB/#idl-def-IDBRequest

- error :: [IDBError](#idberror)
- result :: a
- source :: [IDBIndex](#idbindex) | [IDBObjectStore](#idbobjectstore) | [IDBCursor](#idbcursor)
- readyState :: Bool
- transaction :: Maybe [IDBTransaction](#idbtransaction)

##### Events
- onerror
- onsuccess


---


#### IDBOpenDBRequest
> https://www.w3.org/TR/IndexedDB/#idl-def-IDBRequest

Inherit from [IDBRequest](#idbrequest)

##### Events
  - onblocked
  - onupgradeneeded


---


#### IDBObjectStore 
> https://www.w3.org/TR/IndexedDB/#idl-def-IDBObjectStore

- indexNames:: [String]
- keyPath :: String
- name :: String
- transaction :: [IDBTransaction](#idbtransaction)
- autoIncrement :: Bool
- add :: [IDBObjectStore](#idbobjectstore) -> Value -> Maybe [IDBKey](#idbkey) -> [IDBRequest](#idbrequest) ()
  > `throw` ReadOnlyError, TransactionInactiveError, DataError, InvalidStateError, DataCloneError
- clear :: [IDBObjectStore](#idbobjectstore) -> [IDBRequest](#idbrequest) ()
  > `throw` ReadOnlyError, TransactionInactiveError
- count :: [IDBObjectStore](#idbobjectstore) -> [IDBKeyRange](#idbkeyrange) -> [IDBRequest](#idbrequest) Int
  > `throw` InvalidStateError, TransactionInactiveError, DataError
- createIndex :: [IDBObjectStore](#idbobjectstore) -> String -> String -> { unique :: Bool, multiEntry :: true } -> [IDBIndex](#idbindex)
  > `throw` ConstraintError, InvalidAccessError, InvalidStateError, SyntaxError, TransactionInactiveError
- delete :: [IDBObjectStore](#idbobjectstore) -> [IDBKeyRange](#idbkeyrange) -> [IDBRequest](#idbrequest) ()
  > `throw` TransactionInactiveError, ReadOnlyError, InvalidStateError, DataError
- deleteIndex :: [IDBObjectStore](#idbobjectstore) -> String -> ()
  > `throw` InvalidStateError, TransactionInactiveError, NotFoundError
- get :: [IDBObjectStore](#idbobjectstore) -> [IDBKeyRange](#idbkeyrange) -> [IDBRequest](#idbrequest) a
  > `throw` InvalidStateError, TransactionInactiveError, DataError
- index :: [IDBObjectStore](#idbobjectstore) -> String -> [IDBIndex](#idbindex)
  > `throw` InvalidStateError, NotfoundError
- openCursor :: [IDBObjectStore](#idbobjectstore) -> Maybe [IDBKeyRange](#idbkeyrange) ->  Maybe [IDBCursorDirection](#idbcursordirection) -> [IDBRequest](#idbrequest) [IDBCursorWithValue](#idbcursorwithvalue)
  > `throw` TransactionInactiveError, InvalidStateError, DataError
- put :: [IDBObjectStore](#idbobjectstore) -> a -> [IDBKey](#idbkey) -> [IDBRequest](#idbrequest) ()
  > `throw` ReadOnlyError, TransactionInactiveError, DataError, InvalidStateError, DataCloneError


---


#### IDBTransaction
> https://www.w3.org/TR/IndexedDB/#idl-def-IDBTransaction

- db :: [IDBDatabase](#idbdatabase)
- error :: [IDBError](#idberror)
- mode :: [IDBTransactionMode](#idbtransactionmode)
- abort :: [IDBTransaction](#idbtransaction) -> ()
  > `throw` InvalidStateError
- objectStore :: [IDBTransaction](#idbtransaction) -> String -> [IDBObjectStore](#idbobjectstore)
  > `throw` InvalidStateError, NotFoundError

##### Events
- onabort
- oncomplete
- onerror

---


#### IDBTransactionMode
> https://www.w3.org/TR/IndexedDB/#idl-def-IDBTransactionMode

data IDBTransactionMode 
  = ReadOnly
  | ReadWrite
  | VersionChange
