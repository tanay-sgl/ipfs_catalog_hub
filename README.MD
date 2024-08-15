# IPFS Catalog Hub

This project provides a set of scripts to manage a catalog hub on IPFS. The catalog hub maintains a list of catalogs, each containing references to content on IPFS.

## Scripts

1. `setup.sh`: Initialize the catalog hub.

./setup.sh

2. `add_catalog.sh`: Add a new catalog entry.:

./add_catalog.sh <name> <description> <initial_content_cid>

3. `add_cid.sh`: Append a new CID to an existing catalog entry.

./add_cid.sh <catalog_name> <new_content_cid>

4. `remove_cid.sh`: Delete a CID from an existing catalog entry.

./remove_cid.sh <catalog_name> <content_cid_to_delete>

5. `remove_catalog.sh`: Remove an entire catalog from the hub.


./remove_catalog.sh <catalog_name>

## Prerequisites

- IPFS daemon running
- `jq` command-line JSON processor installed

## Usage

### Initial Setup

```bash
./setup.sh