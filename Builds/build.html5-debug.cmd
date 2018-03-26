@echo off
pushd ..
start /B node Kha/make html5 --watch --debug
start /B node Kha/make --server
popd
