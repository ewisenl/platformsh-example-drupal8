CHART ?= ./helmchart
TARGETS ?= testing staging prod
PROJECT_ID ?= kuberdrupal
RELEASE ?= {{REPO_NAME}}
BRANCH_NAME ?= $(shell git branch --show-current || echo "HEAD")
TAG_NAME ?= $(shell git describe --exact-match --tags 2>/dev/null || echo "")
COMMIT_SHA ?= $(shell git rev-parse HEAD)
COMMIT_MSG ?= $(shell /usr/bin/printf "%q " `git log --pretty=format:'%s' -1`)
HIDE_OUTPUT ?= > /dev/null
CONTEXT_SWITCH_SCRIPT_DIR ?= ../scripts/helm

TEST_TARGETS = $(addprefix test/,${TARGETS})
DEPLOY_TARGETS = $(addprefix deploy/,${TARGETS})
UNINSTALL_TARGETS = $(addprefix uninstall/,${TARGETS})
CONTEXT_TARGETS = $(addprefix context/,${TARGETS})

.PHONY: test test/all $(TEST_TARGETS)
.PHONY: deploy/all $(DEPLOY_TARGETS)
.PHONY: uninstall uninstall/all $(UNINSTALL_TARGETS)
.PHONY: context $(CONTEXT_TARGETS)
.PHONY: dependencies

test test/all: $(TEST_TARGETS)

$(TEST_TARGETS): test/%: context/% dependencies
	@echo "Testing [$*]..."
	@helm lint \
		--values=$(CHART)/values.yaml \
		--values=$(CHART)/values.$*.yaml \
		--set-string=global.env.projectId=$(PROJECT_ID) \
		--set-string=global.env.repoName=gcloud \
		--set-string=global.env.branchName=$(BRANCH_NAME) \
		--set-string=global.env.tagName=$(TAG_NAME) \
		--set-string=global.env.commitSha=$(COMMIT_SHA) \
		--set-string=global.env.commitMsg="$(COMMIT_MSG)" \
		./helmchart
	@helm upgrade --install \
		--dry-run \
		--namespace=$* \
		--values=$(CHART)/values.yaml \
		--values=$(CHART)/values.$*.yaml \
		--set-string=global.env.projectId=$(PROJECT_ID) \
		--set-string=global.env.repoName=gcloud \
		--set-string=global.env.branchName=$(BRANCH_NAME) \
		--set-string=global.env.tagName=$(TAG_NAME) \
		--set-string=global.env.commitSha=$(COMMIT_SHA) \
		--set-string=global.env.commitMsg="$(COMMIT_MSG)" \
		$(RELEASE)-$* $(CHART) $(HIDE_OUTPUT)
	@echo "Success!"

deploy/all:
	@echo "Please use one of the following commands instead:"
	@for target in $(TARGETS); do \
		echo "* make deploy/$$target"; \
	done
	@exit 1

$(DEPLOY_TARGETS): deploy/%: context/% dependencies
	@helm upgrade --install \
		--namespace=$* \
		--values=$(CHART)/values.yaml \
		--values=$(CHART)/values.$*.yaml \
		--set-string=global.env.projectId=$(PROJECT_ID) \
		--set-string=global.env.repoName=gcloud \
		--set-string=global.env.branchName=$(BRANCH_NAME) \
		--set-string=global.env.tagName=$(TAG_NAME) \
		--set-string=global.env.commitSha=$(COMMIT_SHA) \
		--set-string=global.env.commitMsg="$(COMMIT_MSG)" \
		$(RELEASE)-$* $(CHART)

uninstall uninstall/all: $(UNINSTALL_TARGETS)

$(UNINSTALL_TARGETS): uninstall/%: context/% dependencies
	@echo -n "Are you sure you want to completely remove $(RELEASE) from $*? [y/N] " && read ans && [ $${ans:-N} = y ]
	@helm uninstall $(RELEASE)-$* -n $*

dependencies:
	@helm dependency update $(CHART)

context:
	@$(CONTEXT_SWITCH_SCRIPT_DIR)/switch_context.sh
$(CONTEXT_TARGETS): context/%:
	@$(CONTEXT_SWITCH_SCRIPT_DIR)/switch_context.sh $*
