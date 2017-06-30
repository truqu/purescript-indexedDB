PureScript IndexedDB [![](https://img.shields.io/badge/doc-pursuit-60b5cc.svg)](http://pursuit.purescript.org/packages/purescript-indexeddb) [![Build Status](https://travis-ci.org/truqu/purescript-indexeddb.svg?branch=master)](https://travis-ci.org/truqu/purescript-indexeddb)
=====

This package offers complete bindings and type-safety upon the [IndexedDB API](https://w3c.github.io/IndexedDB).

## Overview 

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

## Changelog

- Release incoming

#### TODO

- Add support for `index.getAll` method
- Complete the specifications with the [official tests list](https://github.com/w3c/web-platform-tests/blob/master/IndexedDB/README.md) provided by W3C

## Documentation

Module documentation is [published on Pursuit](http://pursuit.purescript.org/packages/purescript-indexeddb).

## Testing 
Tested in the cloud on multiple browsers and operating systems thanks to [BrowserStack](https://www.browserstack.com)


| IE / Edge | Chrome | Firefox | Safari  | Opera | Android | iOS Safari |
| ----------| ------ | ------- | ------- | ----- | ------- | ---------- |
| -         | >= 56  | >= 51   | >= 10.1 | >= 43 | >= 4.4  | >= 10.3    |

<p align="center">
  <a href="https://www.browserstack.com"><img alt="browserstack" src=".github/browserstack.png" /></a>
</p>
