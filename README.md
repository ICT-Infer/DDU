# Good Good Study; Day Day Up

Study hard and make progress every day!

## Dependencies

* CouchDB 2.0
* jq

## Installing and upgrading

### Build

```bash
./configure.py
make
```

### Create config file

```bash
cp config.json.sample config.json
$EDITOR config.json
```

### Install

```bash
make install
```

### Upgrade

```bash
git pull
make upgrade
```

NOTE: In case you wish to upgrade an install using a freshly cloned copy
or cleaned version of this repository (or in any other situation in which
you don't have the `installed` file created by the installation procedure),
create config file as noted above if necessary and then run
`./scripts/unpack_installed.py` and then run `./scripts/diffassist_verify.py`.
