SHELL := /bin/bash
PROJECT_NAME ?= krew-installer

.PHONY: deps
deps:
	yarn --silent --frozen-lockfile

.PHONY: test
test: deps
	yarn run --cwd=web test
	# missing api-tests, pact tests

.PHONY: prebuild
prebuild:
	rm -rf build
	mkdir -p build

.PHONY: lint
lint:
	npx tslint --project ./tsconfig.json --fix

.PHONY: build
build: prebuild
	`yarn bin`/tsc --project .
	mkdir -p bin
	cp newrelic.js bin/newrelic.js
	cp build/krew-installer.js bin/krew-installer
	chmod +x bin/krew-installer

.PHONY: run
run:
	bin/krew-installer serve

.PHONY: run-debug
run-debug:
	node --inspect=0.0.0.0:9229 bin/krew-installer serve

.PHONY: archive-modules
archive-modules:
	tar cfz node_modules.tar.gz node_modules/

.PHONY: build-cache
build-cache:
	@-docker pull repldev/${PROJECT_NAME}:latest > /dev/null 2>&1 ||:
	docker build -f Dockerfile.skaffoldcache -t repldev/${PROJECT_NAME}:latest .

.PHONY: publish-cache
publish-cache:
	docker push repldev/${PROJECT_NAME}:latest

.PHONY: build-staging
build-staging: REGISTRY = 923411875752.dkr.ecr.us-east-1.amazonaws.com
build-staging: build_and_push

.PHONY: build-production
build-production: REGISTRY = 799720048698.dkr.ecr.us-east-1.amazonaws.com
build-production: build_and_push

build_and_push:
	docker build -f deploy/Dockerfile-slim -t $(REGISTRY)/${PROJECT_NAME}:$${BUILDKITE_COMMIT:0:7} --build-arg version=$${BUILDKITE_COMMIT:0:7} .
	docker push $(REGISTRY)/${PROJECT_NAME}:$${BUILDKITE_COMMIT:0:7}

.PHONY: publish-staging
publish-staging: OVERLAY = staging
publish-staging: GITOPS_OWNER = replicatedcom
publish-staging: GITOPS_REPO = gitops-deploy
publish-staging: GITOPS_BRANCH = main
publish-staging: GITOPS_FILENAME = krew-installer
publish-staging: REGISTRY = 923411875752.dkr.ecr.us-east-1.amazonaws.com
publish-staging: build_and_publish

.PHONY: publish-production
publish-production: OVERLAY = production
publish-production: GITOPS_OWNER = replicatedcom
publish-production: GITOPS_REPO = gitops-deploy
publish-production: GITOPS_BRANCH = release
publish-production: GITOPS_FILENAME = krew-installer
publish-production: REGISTRY = 799720048698.dkr.ecr.us-east-1.amazonaws.com
publish-production: build_and_publish

build_and_publish:
	cd kustomize/overlays/$(OVERLAY); sed -i -- 's/GIT_SHA_PLACEHOLDER/'$${BUILDKITE_COMMIT:0:7}'/g' *.yaml
	cd kustomize/overlays/$(OVERLAY); kustomize edit set image $(REGISTRY)/${PROJECT_NAME}=$(REGISTRY)/${PROJECT_NAME}:$${BUILDKITE_COMMIT:0:7}

	rm -rf deploy/$(OVERLAY)/work
	mkdir -p deploy/$(OVERLAY)/work; cd deploy/$(OVERLAY)/work; git clone --single-branch -b $(GITOPS_BRANCH) git@github.com:$(GITOPS_OWNER)/$(GITOPS_REPO)
	mkdir -p deploy/$(OVERLAY)/work/$(GITOPS_REPO)/${PROJECT_NAME}

	kustomize build kustomize/overlays/$(OVERLAY) > deploy/$(OVERLAY)/work/$(GITOPS_REPO)/${PROJECT_NAME}/${GITOPS_FILENAME}.yaml

	cd deploy/$(OVERLAY)/work/$(GITOPS_REPO)/${PROJECT_NAME}; \
	  git add . ;\
	  git commit --allow-empty -m "$${BUILDKITE_BUILD_URL}"; \
          git push origin $(GITOPS_BRANCH)
