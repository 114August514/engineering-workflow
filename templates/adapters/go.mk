# name: go
# desc: Go + gofmt + go vet + golangci-lint + go test
# needs: go

SETUP     := go mod download
DEV       := go run ./cmd/server
FMT       := gofmt -w .
FMT_CHECK := test -z "$$(gofmt -l .)"
LINT      := go vet ./... && golangci-lint run
TYPECHECK := go build ./...
TEST      := go test ./...
BUILD     := go build -o dist/server ./cmd/server
SHIP      :=
