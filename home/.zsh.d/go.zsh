# export GOPATH=$HOME/src/golang
# #export GOROOT="/usr/local/Cellar/go/1.7.4_2/libexec"
# zph/add_to_path "$GOPATH/bin"
# zph/add_to_path "/usr/local/opt/go/libexec/bin"
# For vendored gopath w/ GB
# export GOPATH=./vendor:$GOPATH
alias gogo="cd $GOPATH/src/github.com/zph/"
export PATH=$PATH:/usr/local/opt/go/libexec/bin


go-cover () {
    t="/tmp/go-cover.$$.tmp"
    go test -coverprofile=$t $@ && go tool cover -html=$t && unlink $t
}
