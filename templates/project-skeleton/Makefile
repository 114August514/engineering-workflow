# 标准动词接口 —— 语言无关，不要改这个文件。
# 语言相关的具体命令全部在 stack.mk 里。换技术栈只换那一个文件。

ifeq (,$(wildcard stack.mk))
$(error 缺少 stack.mk —— 从 templates/adapters/ 拷一个过来，或用 new-project.sh 建项目)
endif
include stack.mk

# 项目自带 scripts/，不依赖 skill 是否装在这台机器上。
# 没有的话再退回到 skill 目录。
EW_SKILL ?= $(HOME)/.claude/skills/engineering-project
AUDIT  := $(if $(wildcard scripts/audit.sh),./scripts/audit.sh,$(EW_SKILL)/scripts/audit.sh)
DOCTOR := $(if $(wildcard scripts/doctor.sh),./scripts/doctor.sh,$(EW_SKILL)/scripts/doctor.sh)
REVIEW := $(if $(wildcard scripts/review.sh),./scripts/review.sh,$(EW_SKILL)/scripts/review.sh)

.DEFAULT_GOAL := help
.PHONY: help setup dev fmt fmt-check lint typecheck test check build ship audit review doctor

help: ## 列出所有目标
	@grep -hE '^[a-z][a-z-]*:.*?## ' $(MAKEFILE_LIST) \
		| awk -F':.*?## ' '{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## 全新机器到可开发（幂等）
	$(SETUP)

dev: ## 本地起起来（前台、热重载）
	$(DEV)

fmt: ## 格式化（会改文件）
	$(FMT)

fmt-check: ## 检查格式（只读）
	$(FMT_CHECK)

lint: ## 静态检查（只读）
	$(LINT)

typecheck: ## 类型检查
	@$(if $(TYPECHECK),$(TYPECHECK),echo "（本技术栈无类型检查，跳过）")

test: ## 跑测试
	$(TEST)

check: fmt-check lint typecheck test ## 提交前唯一要记的命令
	@echo ""
	@echo "  ✓ check 全部通过"

build: ## 产出可部署产物
	@$(if $(BUILD),$(BUILD),echo "（本项目无构建步骤）")

ship: ## 部署（幂等）
	@$(if $(SHIP),$(SHIP),echo "!! 还没配置部署。把命令填进 stack.mk 的 SHIP" && exit 1)

audit: ## 生成待人审清单（增量：这次改动）
	@$(AUDIT)

review: ## 里程碑复盘（全量：整个仓库）
	@$(REVIEW)

doctor: ## 工程基线体检
	@$(DOCTOR)
