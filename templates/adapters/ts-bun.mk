# name: ts-bun
# desc: TypeScript + Bun + Biome（格式/lint 一体）+ bun test
# needs: bun
#
# adapter 只填命令，不定义流程。Makefile 的动词一个字都不用改。

SETUP     := bun install --frozen-lockfile
DEV       := bun run --watch src/index.ts
FMT       := bunx biome format --write .
FMT_CHECK := bunx biome format .
LINT      := bunx biome check .
TYPECHECK := bunx tsc --noEmit
TEST      := bun test
BUILD     := bun build src/index.ts --outdir dist --target bun
SHIP      :=
