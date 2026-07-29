#!/usr/bin/env bash
# CI relevance receipt 的最小一致性检查。只保护本仓已经采用的三类词汇、终态等待点和双平台入口。
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT/.github/pull_request_template.md"
AGENTS="$ROOT/AGENTS.md"
WORKFLOW="$ROOT/.github/workflows/ci.yml"

for f in "$TEMPLATE" "$AGENTS" "$WORKFLOW"; do
  [ -s "$f" ] || { echo "✗ CI scope 输入为空或不存在：$f"; exit 1; }
done

validate() {
  root=$1
  template="$root/.github/pull_request_template.md"
  agents="$root/AGENTS.md"
  workflow="$root/.github/workflows/ci.yml"

  grep -Fq 'ci-scope: required=<checks|none>; advisory=<checks|none>; n/a=<checks|none>; reason=<why>' "$template" || {
    echo "✗ PR 模板缺少完整 ci-scope receipt"; return 1;
  }
  grep -Fq '`required`：失败能推翻当前 acceptance；只在 merge、gate、tag 等终态动作前等待相关 checks。' "$agents" || {
    echo "✗ required 分类或终态等待规则错误"; return 1;
  }
  grep -Fq '`advisory`：有信息价值，不阻塞独立工作。' "$agents" || {
    echo "✗ advisory 分类错误"; return 1;
  }
  grep -Fq '`n/a`：与当前变更无因果关系。' "$agents" || {
    echo "✗ n/a 分类错误"; return 1;
  }
  grep -Fq 'pending CI 不改变 task state' "$agents" || {
    echo "✗ 缺少 pending CI 状态规则"; return 1;
  }
  grep -Fq 'os: [ubuntu-latest, macos-latest]' "$workflow" || {
    echo "✗ CI 不再覆盖 Ubuntu/macOS"; return 1;
  }
  grep -Fq 'run: bash tests/ci-scope-consistent.sh' "$workflow" || {
    echo "✗ CI 未调用 ci-scope 一致性检查"; return 1;
  }
}

fail=0
ck() { if eval "$2"; then echo "  ✓ $1"; else echo "  ✗ $1"; fail=1; fi; }
out() { "$@" 2>&1 || true; }

ck "仓库包含完整 receipt、三类语义和双平台入口" 'validate "$ROOT"'

T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/.github/workflows"
cp "$TEMPLATE" "$T/.github/pull_request_template.md"
cp "$AGENTS" "$T/AGENTS.md"
cp "$WORKFLOW" "$T/.github/workflows/ci.yml"

# 故障注入 1：把 advisory 的含义换成阻塞，必须给出分类错误，而不是只看退出码。
sed 's/`advisory`：有信息价值，不阻塞独立工作。/`advisory`：有信息价值，并阻塞独立工作。/' \
  "$T/AGENTS.md" > "$T/AGENTS.tmp" && mv "$T/AGENTS.tmp" "$T/AGENTS.md"
ck "错误分类会被准确报出" 'out validate "$T" | grep -q "advisory 分类错误"'

# 故障注入 2：删除完整 receipt，必须明确指出缺失 receipt。
cp "$AGENTS" "$T/AGENTS.md"
grep -Fv 'ci-scope: required=<checks|none>; advisory=<checks|none>; n/a=<checks|none>; reason=<why>' \
  "$T/.github/pull_request_template.md" > "$T/template.tmp" && mv "$T/template.tmp" "$T/.github/pull_request_template.md"
ck "缺失 receipt 会被准确报出" 'out validate "$T" | grep -q "PR 模板缺少完整 ci-scope receipt"'

[ "$fail" -eq 0 ] && echo "✓ CI scope 一致性测试全过（3 条）"
exit "$fail"
