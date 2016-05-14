#SHELL := /bin/bash

all: install

clean:
	rm -f $(GOPATH)/bin/todd-server
	rm -f $(GOPATH)/bin/todd
	rm -f $(GOPATH)/bin/todd-agent

build:
	docker build -t mierdin/todd -f Dockerfile .

install: configureenv
	go install ./cmd/...

fmt:
	go fmt github.com/mierdin/todd/...

test: 
	go test ./... -cover

update_deps:
	go get -u github.com/tools/godep
	godep save ./...

update_assets:
	go get -u github.com/jteeuwen/go-bindata/...
	$(GOPATH)/bin/go-bindata -o assets/assets_unpack.go -pkg="assets" -prefix="agent" agent/testing/testlets/... agent/facts/collectors/...

start: install
	start-containers.sh 3 /etc/todd/server-int.cfg /etc/todd/agent-int.cfg

configureenv:
	mkdir -p /etc/todd
	chmod -R 777 /opt/todd
	cp -f etc/{agent,server}.cfg /etc/todd/
	mkdir -p /opt/todd/{agent,server}/assets/{factcollectors,testlets}
