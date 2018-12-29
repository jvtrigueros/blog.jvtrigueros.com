# Let's Encrypt Setup

Every few months I have to update the SSL cert provided by Let's Encrypt, but I
keep forgetting how to, so here's an attempt to capture the latest working instructions.

These instructions assume you're on WSL

```bash
python -m pip install --user boto3
source credentials.sh
export PATH=$PATH:$HOME/.local/bin # I don't remember what was in here, will augment docs when necessary
./letsencrypt.sh`
```

_NOTE: Please don't delete `work`, `logs`, and `config` directories, they're needed for this to work w/o `sudo`_.
