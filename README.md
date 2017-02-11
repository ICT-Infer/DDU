# Good Good Study; Day Day Up

Study hard and make progress every day!

## Dependencies

* CouchDB 2.0
* jq

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

### Update

```bash
git pull
make update
```

NOTE: In case you wish to update an install using a freshly cloned
copy (or in any other situation in which you don't have the `installed`
file created by the installation procedure), run
`./scripts/unpack_installed.py` and then `./scripts/autodiff.py`.
