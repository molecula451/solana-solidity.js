examples=$(shell find examples -maxdepth 1 -mindepth 1 -type d)

test-example:
	@if [ ! -d "examples/$(o)" ]; then \
		echo "example($o) doesn't exist"; \
		exit -1; \
    fi
	rm -rf examples/$(o)/build
	mkdir -p examples/$(o)/build
	docker run --rm -it -v $(PWD)/examples/$(o):/example --entrypoint /bin/bash ghcr.io/hyperledger-labs/solang -c "solang /example/contracts/*.sol -o /example/build --target solana -v"
	mocha examples/$(o)/tests/*.spec.ts

build-all-examples: $(examples)
	for example in $^; do\
		rm -rf $${example}/build; \
		mkdir -p $${example}/build; \
		docker run --rm -it -v $(PWD)/$${example}:/example --entrypoint /bin/bash ghcr.io/hyperledger-labs/solang -c "solang /example/contracts/*.sol -o /example/build --target solana -v"; \
	done

test-all-examples: $(examples)
	for example in $^; do\
		rm -rf $${example}/build; \
		mkdir -p $${example}/build; \
		docker run --rm -it -v $(PWD)/$${example}:/example --entrypoint /bin/bash ghcr.io/hyperledger-labs/solang -c "solang /example/contracts/*.sol -o /example/build --target solana -v"; \
	done
	mocha examples/**/tests/*.spec.ts

test-unit:
	mocha tests/unit/*.spec.ts

validator:
	docker pull solanalabs/solana:edge
	docker pull ghcr.io/hyperledger-labs/solang:latest
	docker run --rm -it -p 8899:8899 -p 8900:8900 solanalabs/solana:edge > /dev/null

deploy-docs:
	@$(MAKE) -C docs

publish:
	@npm run publish

.PHONY: test-example build-all-examples test-all-examples test-unit validator deploy-docs publish
