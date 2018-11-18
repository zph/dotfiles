#!/usr/bin/env bash

# Required to kill gocode & on some platforms it needs kill -9
# https://github.com/Microsoft/vscode-go/issues/441#issuecomment-257314322
gocode close
killall -9 gocode

# https://github.com/Microsoft/vscode-go#tools
# go get -u -v github.com/nsf/gocode
(cd $GOPATH/src/github.com/nsf/gocode && go install)
go get -u -v github.com/rogpeppe/godef
go get -u -v github.com/zmb3/gogetdoc
go get -u -v github.com/golang/lint/golint
go get -u -v github.com/lukehoban/go-outline
go get -u -v sourcegraph.com/sqs/goreturns
go get -u -v golang.org/x/tools/cmd/gorename
go get -u -v github.com/tpng/gopkgs
go get -u -v github.com/newhook/go-symbols
go get -u -v golang.org/x/tools/cmd/guru
go get -u -v github.com/cweill/gotests/...
