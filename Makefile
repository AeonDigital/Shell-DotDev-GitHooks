# ==============================================================================
# Shell-DotDev-GitHooks Development Automation Matrix
# ==============================================================================

.PHONY: help init update reset-config install-devexec install-vscode

# Core environmental and architectural path definitions
TOOLS_PATH  := .dev/tools/githooks
CONFIG_PATH := .dev/config/githooks

help: ## Display available technical execution targets
	@echo "================================================================================"
	@echo "Available Development Automation Targets (Alphabetical):"
	@echo "================================================================================"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' | sort
	@echo "================================================================================"

init: ## Initialize empty framework submodules and map local Git lifecycle hooks path
	@echo "================================================================================"
	@echo "[RUN] Synchronizing and populating detached submodule trees..."
	@echo "================================================================================"
	git submodule update --init --recursive
	@echo "[ . ] Redirecting workspace core hooks target execution path..."
	git config core.hooksPath $(TOOLS_PATH)
	@echo "[ . ] Enforcing executable states on master entrypoint..."
	@chmod +x $(TOOLS_PATH)/pre-commit 2>/dev/null || echo "[ ! ] Warning: Could not grant execution permission. Run manually if needed."
	@echo "[OKK] Git hooks framework initialized successfully on this workstation."

update: ## Update validation core logic with upstream remote main branch stability
	@echo "================================================================================"
	@echo "[RUN] Fetching newest compliance updates from origin main stream..."
	@echo "================================================================================"
	@if [ ! -d "$(TOOLS_PATH)" ]; then \
		echo "[ERR] Submodule core footprint is missing. Please execute 'make init' first."; \
		exit 1; \
	fi
	@cd $(TOOLS_PATH) && \
		git fetch origin --prune --quiet && \
		git reset --hard origin/main --quiet
	@echo "[ . ] Deploying newest hook lifecycle entrypoint blueprint..."
	@cp $(TOOLS_PATH)/setup/scripts/pre-commit.sh $(TOOLS_PATH)/pre-commit
	@chmod +x $(TOOLS_PATH)/pre-commit 2>/dev/null || true
	@echo "[ . ] Extracting synchronized architecture release metadata..."
	@commit_hash=$$(cd $(TOOLS_PATH) && git log -1 --format="%h" 2>/dev/null || echo "unknown"); \
	commit_date=$$(cd $(TOOLS_PATH) && git log -1 --format="%ai" 2>/dev/null || echo "unknown"); \
	commit_subject=$$(cd $(TOOLS_PATH) && git log -1 --format="%s" 2>/dev/null || echo "unknown"); \
	echo "================================================================================"; \
	echo "[OKK] Submodule architecture successfully aligned with origin/main."; \
	echo "      -> Target Path : $(TOOLS_PATH)"; \
	echo "      -> Commit Hash : $${commit_hash}"; \
	echo "      -> Auth Date   : $${commit_date}"; \
	echo "      -> Description : $${commit_subject}"; \
	echo "================================================================================"


reset-config: ## Reset and overwrite local rules with out-of-the-box factory defaults [DESTRUCTIVE]
	@echo "================================================================================"
	@echo "[ ! ] WARNING: DESTRUCTIVE ACTION DETECTED"
	@echo "      This operation will completely erase your local modified rulesets inside"
	@echo "      '$(CONFIG_PATH)/*' and restore default factory blueprints."
	@echo "================================================================================"
	@echo "[ ? ] Are you absolutely sure you want to proceed? (y/n)"; \
	printf "[ > ] :: "; \
	read -r local_choice </dev/tty; \
	normalized_choice=$$(echo "$$local_choice" | tr '[:upper:]' '[:lower:]'); \
	if [ "$$normalized_choice" != "y" ]; then \
		echo "[END] Operation aborted by user request."; \
		exit 0; \
	fi; \
	echo "[RUN] Purging existing local user rule configurations..."; \
	rm -rf $(CONFIG_PATH)/*; \
	echo "[ . ] Re-deploying initial system presets from submodule template storage..."; \
	cp $(TOOLS_PATH)/setup/config/* $(CONFIG_PATH)/; \
	echo "[OKK] Configuration environment successfully restored to original baseline state."

install-devexec: ## Deploy or update the localized terminal environment facilitator utility
	@echo "================================================================================"
	@echo "[RUN] Provisioning development terminal facilitator helper..."
	@echo "================================================================================"
	@if [ ! -f "$(TOOLS_PATH)/setup/scripts/devexec.sh" ]; then \
		echo "[ERR] Target script source blueprint not found under submodule storage paths."; \
		exit 1; \
	fi
	@cp $(TOOLS_PATH)/setup/scripts/devexec.sh .dev/devexec.sh
	@echo "[ . ] Enforcing executable states on utility entrypoint..."
	@chmod +x .dev/devexec.sh 2>/dev/null || echo "[ ! ] Warning: Could not grant execution permission. Run 'chmod +x .dev/devexec.sh' manually if needed."
	@echo "[OKK] 'devexec.sh' successfully deployed/updated into the '.dev/' root container."

install-vscode: ## Mount non-destructive workspace task integrations inside the active IDE tree
	@echo "================================================================================"
	@echo "[RUN] Evaluating Visual Studio Code automation profile footprints..."
	@echo "================================================================================"
	@if [ ! -f ".dev/tools/githooks/setup/vscode/tasks.json" ]; then \
		echo "[ERR] Master task template asset is missing from submodule assets."; \
		exit 1; \
	fi
	@if [ ! -f ".vscode/tasks.json" ]; then \
		echo "[ . ] Clean workspace environment detected. Writing task configurations..."; \
		mkdir -p .vscode && cp $(TOOLS_PATH)/setup/vscode/tasks.json .vscode/tasks.json; \
		echo "[OKK] Default VS Code tasks active."; \
	else \
		echo "[ ! ] Pre-existing 'tasks.json' custom configuration array discovered."; \
		echo "      To prevent losing custom settings, automated rewrites are disabled."; \
		echo "================================================================================"; \
		echo "[ ! ] MANUAL ACTION REQUIRED FOR VS CODE"; \
		echo "      Please append the task configuration block below into your file manually:"; \
		echo ""; \
		cat $(TOOLS_PATH)/setup/vscode/tasks.json; \
		echo ""; \
		echo "================================================================================"; \
	fi

run: ## Force immediate local execution of the pre-commit lifecycle hook validation
	@echo "================================================================================"
	@echo "[RUN] Executing localized verification modules manually..."
	@echo "================================================================================"
	@if [ ! -f "$(TOOLS_PATH)/pre-commit" ]; then \
		echo "[ERR] Target validation script is missing under '$(TOOLS_PATH)/pre-commit'."; \
		echo "      Please verify framework installation or run 'make init' first."; \
		exit 1; \
	fi
	@if [ ! -x "$(TOOLS_PATH)/pre-commit" ]; then \
		echo "[ ! ] Execution bit missing. Enforcing executable state on binary path..."; \
		chmod +x $(TOOLS_PATH)/pre-commit 2>/dev/null || true; \
	fi
	@$(TOOLS_PATH)/pre-commit
