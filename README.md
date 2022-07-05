# Doppler PHP Sample Application

![Doppler Environment Variables Secrets Management for Laravel with PHP-FPM and NGINX on Ubuntu](https://repository-images.githubusercontent.com/399783760/98fbf2ed-eab2-48cf-8be5-85672c2edcfa)

This repository is a reference solution for using Doppler to manage secrets for PHP applications. It currently focusses on Laravel but the techniques shown here can be applied to any framework.

## What is Doppler?

[Doppler](https://www.doppler.com) is a SecretOps platform that keeps secrets and app configuration in sync sync across devices, environments, and team members.

## Requirements

- [Doppler account](https://dashboard.doppler.com/register)
- [Doppler CLI](https://docs.doppler.com/docs/install-cli)
- Docker and Docker Compose
- make

> NOTE: Docker Compose is used for simulating a production environment on your local machine and is not a requirement for using Doppler with PHP.

## Setup

If haven't already, authenticate the Doppler CLI locally by running:

```sh
doppler login
```

Clone this repository and open a terminal in the root directory. Then create the sample Doppler project and build the required Docker containers:

```sh
make doppler-project
make docker-build
```

## Production

Navigate to the [laravel-sample-app](https://dashboard.doppler.com/workplace/projects/laravel-sample-app/configs/prd) in the Doppler dashboard, then click on the **Access** tab.

Select the **Access** tab and click the **+ Generate** button to create a read-only [Service Token](https://docs.doppler.com/docs/service-tokens) and copy its value.

Then to simulate a production environment, expose the Service Token value using the `DOPPLER_TOKEN` environment variable. The Service Token is typically injected into your deployment via CI/CD job.

```sh
export DOPPLER_TOKEN="dp.st.prd.xxxx"
```

You can verify access to Production secrets by running:

```sh
doppler secrets
```

Then start the application by running:

```sh
make run
```

The application will then be served through NGINX at http://localhost/.

Leave the server running as we'll using it next to demonstrate automatic secrets syncing.

## Secrets Sync

Incorporating automatic secrets syncing just needs a scheduler (e.g. cron) and a [secrets sync script](./laravel/bin/doppler-sync.sh):

```
* * * * * /usr/src/app/bin/doppler-sync.sh
```

To simulate scheduled updates, open a new terminal window and run:

```sh
make doppler-sync
```

Navigate to the [Doppler dashboard](https://dashboard.doppler.com/workplace/projects/laravel-sample-app/configs/prd), change the **APP_NAME** secret, then refresh the application page to confirm the secrets change has come through.

## Database Migrations

While each team will have their own process for applying database migrations in live environments, a simple mechanism is demonstrated in the [php-fpm-start.sh](./laravel/bin/php-fpm-start.sh) script by checking if the `DB_FORCE_MIGRATE` environment variable has a value of `yes` and force-running the migration command accordingly.

## Local Development

We'll simulate a development environment also using Docker Compose.

```sh
make dev
```

Then in a new terminal attach to the shell in the Laravel container by running:

```sh
docker attach laravel-app
```

Then authenticate the CLI by running:

```sh
doppler login

Then start the development server using the Doppler CLI to mount an ephemeral .env file:

```sh
doppler run --mount .env -- php artisan serve --host 0.0.0.0 --port 9000
```

## Cleanup

To cleanup the resources used for this sample app:

```sh
make cleanup
```
