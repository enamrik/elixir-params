
test:
	./scripts/restore-deps.sh
	mix test --no-start

test_one:
	mix test --only one

.PHONY:test