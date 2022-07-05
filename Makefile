SHELL=/usr/bin/env bash

doppler-project:
	doppler import
	open https://dashboard.doppler.com/workplace/projects/laravel-sample-app/configs/prd

docker-build:
	docker image build -t doppler/laravel-app -f laravel/Dockerfile .
	docker image build -t doppler/laravel-nginx -f nginx/Dockerfile .

# Requires DOPPLER_TOKEN environment variable
run:
	@MARIADB_DATABASE="$$(doppler secrets get DB_NAME --plain)" \
	MARIADB_USER="$$(doppler secrets get DB_USERNAME --plain)" \
	MARIADB_PASSWORD="$$(doppler secrets get DB_PASSWORD --plain)" \
	docker-compose up; docker-compose down;

# Requires DOPPLER_TOKEN environment variable or authenticating the CLI in the laravel-app container
dev:
	@MARIADB_DATABASE="$$(doppler secrets get DB_NAME --plain)" \
	MARIADB_USER="$$(doppler secrets get DB_USERNAME --plain)" \
	MARIADB_PASSWORD="$$(doppler secrets get DB_PASSWORD --plain)" \
	docker-compose -f docker-compose.yml -f docker-compose-dev.yml up;

doppler-sync:
	@watch -n 5 docker exec laravel-app ./bin/doppler-sync.sh

shell:
	docker exec -it laravel-app bash

attach:
	docker attach laravel-app

cleanup:
	@$(MAKE) mysql-stop
	@unset DOPPLER_TOKEN;
	@doppler projects delete laravel-sample-app -y --silent;
	@docker image rm doppler/laravel-app doppler/laravel-nginx
