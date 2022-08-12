statedir := .state
itest_db := $(statedir)/itest.db
itest_state := $(statedir)/itest.csv
base_pack_name := codeql/java-queries

compile: pack

$(statedir):
	mkdir "$@"

base:
	gh \
		tailor download \
		--outdir "$@" \
		"$(base_pack_name)"

download: base

pack: base customize
	rm -rf stage "$@"
	cp -r base stage
	./customize
	gh tailor create -i stage
	mv stage "$@"

$(itest_db): pack | $(statedir)
	gh \
		tailor make-min-db \
		--language \
		"$$(gh tailor get-pack-info --language pack)" \
		"$@"

$(itest_state): pack $(itest_db)
	gh tailor codeql -- \
		database analyze \
		--threads 0 \
		--additional-packs pack \
		--format csv \
		--output "$@" \
		"$(itest_db)" \
		"$$(gh tailor get-pack-info --name pack)"

integration-test: $(itest_state)

test: $(itest_state)

publish: $(itest_state)
	( \
		gh tailor \
			autoversion \
			--mode new-on-collision \
			--fail \
			pack \
		&& \
		gh tailor publish pack \
	) \
	|| (test "$$?" = 2 && echo "Nothing left to do") \

.PHONY: clean
clean:
	rm -rf \
		base stage pack \
		.state
