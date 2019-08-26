default: all

all: latest

latest:
	docker build -f Dockerfile \
	--cache-from illinoismla/damla-env:latest \
	-t illinoismla/damla-env:latest \
	-t illinoismla/damla-env:2019-fall \
	--compress .
