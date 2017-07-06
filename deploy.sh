#!/bin/sh

test -n "$TRAVIS_TAG" && ( yes | pulp publish --no-push )
