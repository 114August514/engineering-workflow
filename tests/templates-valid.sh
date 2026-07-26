#!/usr/bin/env bash
# 协作模板坏了 GitHub 是**静默**忽略的——issue 模板不出现在选择列表里，
# 你要等到有人提 issue 才发现。所以这里查 YAML 合法性和必填结构。
set -uo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

command -v python3 >/dev/null || { echo "跳过（无 python3）"; exit 0; }

fail=0
n=0
for f in .github/ISSUE_TEMPLATE/*.yml .github/*.yml \
         templates/project-skeleton/.github/ISSUE_TEMPLATE/*.yml \
         templates/project-skeleton/.github/*.yml \
         templates/project-skeleton/.github/workflows/*.yml \
         .github/workflows/*.yml; do
  [ -f "$f" ] || continue
  n=$((n+1))
  python3 -c "import sys,yaml; yaml.safe_load(open(sys.argv[1]))" "$f" \
    || { echo "  ✗ YAML 不合法：$f"; fail=1; }
done
[ "$n" -gt 0 ] || { echo "✗ 一个模板都没找到 —— 路径失效了"; exit 1; }

# issue 表单必须有 name/description/body，否则 GitHub 不认
for f in .github/ISSUE_TEMPLATE/bug.yml .github/ISSUE_TEMPLATE/feature.yml \
         templates/project-skeleton/.github/ISSUE_TEMPLATE/bug.yml \
         templates/project-skeleton/.github/ISSUE_TEMPLATE/feature.yml; do
  [ -f "$f" ] || continue
  python3 - "$f" <<'PY' || fail=1
import sys, yaml
d = yaml.safe_load(open(sys.argv[1]))
missing = [k for k in ("name", "description", "body") if k not in d]
if missing:
    print(f"  ✗ {sys.argv[1]} 缺字段: {missing}"); sys.exit(1)
if not any(x.get("validations", {}).get("required") for x in d["body"]):
    print(f"  ✗ {sys.argv[1]} 没有任何必填项 —— 那它就拦不住半成品 issue"); sys.exit(1)
PY
done

[ $fail -eq 0 ] && echo "✓ 协作模板全部合法（$n 个 YAML）"
exit $fail
