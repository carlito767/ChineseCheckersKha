@echo off
pushd ..
start /B node Kha/make html5 --watch
start /B node Kha/make --server
popd
