#!/bin/sh

set -e

spago bundle-app -m Test.Main --to test.js

xdg-open test.html

