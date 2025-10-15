# Salt Guide

## Salt docker compose
1. run master node:
```bash
docker compose -f master.yaml up -d
```
2. run minion node:
for that you need this `minion-entrypoint.sh` script too:
```bash
docker compose -f minion.yaml up -d
```

3. accept the authentication of minion in master.
for that run this command on master:
```bash
salt-key -a <SALT_MINION_ID>
```
done.

4. run this to varify nodes:
```bash
salt-run manage.up
```

## common commands
```bash
# statuc of minions
salt-run manage.status

# ping all minions
salt '*' test.ping

# to show minions considered up
salt-run manage.up

# to get detailed information on all minions and their statuses
salt-run manage.status

# to run a sls
salt '<target-minion>' state.apply <path.to.sample.sls>

# to see status of all keys
salt-key -L
```
