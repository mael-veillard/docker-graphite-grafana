# Graphite & Grafana

Docker container presenting Graphite and Grafana 2.6. Both applications are configured to store dashboards and similar data into Postgres DB. Postgres DB is not present in the container - it is supposed that additional container with Postgres DB runs aside.

In order to use Grafana you must first log in as an admin and configure the connection to Graphite. Credentials for Grafana are *"admin/admin"*. However any anonymous user is allowed to view Dashboards.

## Run container

Postgres must be already running. *postgres:9.5* container can be used for this purpose.

### docker-compose
docker-compose will create entire environment - one container with postgres and another with Graphite&Grafana
If you have *docker-compose* installed, you can clone this repository or download only the *docker-composer.yml* file and then run:

```
docker-compose up -d
```

### Regular Docker

```
docker run -d -v /some/location:/var/lib/graphite/whisper -p 80:80 -p 8080:8080 -p 2003:2003 -p 2004:2004 -p 7002:7002 --links db:postgres -e PGHOST=postgres -e PGUSER=pgadmin -e PGPASSWORD=pgadmin ohamada/graphite-grafana
```

For more information about used environment variables look at section 'Configuration of connection to Postgres'

*/some/location* - storage of Graphite's RRD data
*--links db:postgres* - optional part, links container 'db' with alias 'postgres' to this container

| Port | Purpose |
| ---- | ------- |
| 80 | Grafana web gui |
| 8080 | Graphite web gui |
| 2003 | Graphite UDP receiver |
| 2004 | Graphite picker receiver |
| 7002 | Graphite cache query |

### Configuration of connection to Postgres
We suppose that there is a instance of Postgres already running somewhere. In order to configure the container properly you must use environment variables.

| Variable | Mandatory | Default value | Purpose |
| -------- | --------- | ------------- | ------- |
| PGHOST   |  YES      | | Hostname of postgres host |
| PGUSER   |  YES | | Username of user with admin rights (in order to create user role and databases) |
| PGPASSWORD | YES | | Password for admin user |
| PGPORT | NO | 5432 | Define Postgres port |
| DB_USER | NO | graphite | User for both apps to access Postgres (account will be created in postgres) |
| DB_PASSWORD | NO | graphite | User password |
| DB_GRAPHITE_NAME | NO | graphite | Name of the database to be used by Graphite |
| DB_GRAFANA_NAME | NO | grafana | Name of the database to be used by Grafana | 
