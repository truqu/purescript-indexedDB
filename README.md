PureScript IndexedDB [![](https://img.shields.io/badge/doc-pursuit-60b5cc.svg)](http://pursuit.purescript.org/packages/purescript-indexeddb) [![Build Status](https://travis-ci.org/truqu/purescript-indexeddb.svg?branch=master)](https://travis-ci.org/truqu/purescript-indexeddb)
=====

This package offers complete bindings and type-safety upon the [IndexedDB API](https://w3c.github.io/IndexedDB).

## Overview 

The `IDBCore` and `IDBFactory` are the two entry points required to create and connect to an
indexed database. From there, modules are divided such that each of them covers a specific IDB
interface. 

They are designed to be used as qualified imports such that each method gets prefixed with a
menaingful namespace (e.g `IDBIndex.get`, `IDBObjectStore.openCursor` ...)

Here's a quick example of what it look likes. 
```purescript
main :: Eff (idb :: IDB, exception :: EXCEPTION, console :: CONSOLE) Unit
main = launchAff' do
  db <- IDBFactory.open "db" Nothing { onBlocked       : Nothing
                                     , onUpgradeNeeded : Just onUpgradeNeeded
                                     }

  tx    <- IDBDatabase.transaction db ["store"] ReadOnly
  store <- IDBTransaction.objectStore tx "store"
  (val :: Maybe String) <-  IDBObjectStore.get store (IDBKeyRange.only 1)
  log $ maybe "not found" id val


onUpgradeNeeded :: forall e. Database -> Transaction -> Eff (idb :: IDB, exception :: EXCEPTION | e) Unit
onUpgradeNeeded db _ = launchAff' do
  store <- IDBDatabase.createObjectStore db "store" IDBObjectStore.defaultParameters
  _     <- IDBObjectStore.add store "patate" (Just 1)
  _     <- IDBObjectStore.add store { property: 42 } (Just 2)
  _     <- IDBObjectStore.createIndex store "index" ["property"] IDBIndex.defaultParameters
  pure unit
```

## Notes

### Errors
Errors normally thrown by the IDB\* interfaces are wrapped in the `Aff` Monad as `Error`
where the `message` corresponds to the error's name (e.g. "InvalidStateError").
Pattern matching can therefore be done on any error message to handle specific errors thrown
by the API.

### Examples
The `test` folder contains a great amount of examples showing practical usage of the IDB\*
interfaces. Do not hesitate to have a peek should you wonder how to use one of the module. The
wrapper tries to keep as much as possible an API consistent with the original IndexedDB API.
Hence, it should be quite straightforward to translate any JavaScript example to a PureScript
one. 

## Changelog

#### v0.9.0

- [Indexed Database API 2.0](https://w3c.github.io/IndexedDB/) totally covered apart from 
  - `index.getAll` method (and the associated one for the IDBObjectStore)
  - binary keys

## Documentation

Module documentation is [published on Pursuit](http://pursuit.purescript.org/packages/purescript-indexeddb).

## Testing 
Tested in the cloud on multiple browsers and operating systems thanks to [BrowserStack](https://www.browserstack.com)


| IE / Edge | Chrome | Firefox | Safari  | Opera | Android | iOS Safari |
| ----------| ------ | ------- | ------- | ----- | ------- | ---------- |
| -         | >= 57  | >= 51   | -       | >= 46 | -       | -          |

<p align="center">
  <a href="https://www.browserstack.com"><img alt="browserstack" src=".github/browserstack.png" /></a>
</p>
