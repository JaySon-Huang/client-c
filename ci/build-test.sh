#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
SRCPATH=$(cd $SCRIPTPATH/..; pwd -P)
NPROC=$(nproc || grep -c ^processor /proc/cpuinfo)

if [ -d "$SRCPATH/third_party/kvproto" ]; then
  cd "$SRCPATH/third_party/kvproto"
  rm -rf cpp/kvproto
  ./generate_cpp.sh
  cd -
fi

build_dir="$SRCPATH/build"
mkdir -p $build_dir && cd $build_dir
cmake "$SRCPATH" \
    -DENABLE_TESTS=on
make -j $NPROC

nohup /mock-tikv/bin/mock-tikv &
mock_kv_pid=$!

cd "$build_dir" && make test

kill -9 $mock_kv_pid


