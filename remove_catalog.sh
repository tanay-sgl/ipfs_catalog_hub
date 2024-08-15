#!/bin/bash

remove_catalog() {
    local name="$1"

    # Read the current catalog_hub.json
    catalog_hub_content=$(cat catalog_hub.json | jq -r .)

    # Check if the catalog exists
    if ! echo "$catalog_hub_content" | jq -e ".content[\"$name\"]" > /dev/null; then
        echo "Error: Catalog '$name' not found in the hub."
        exit 1
    fi

    # Remove the catalog from the content object
    updated_catalog_hub=$(echo $catalog_hub_content | jq "del(.content[\"$name\"])")

    # Write the updated catalog hub back to catalog_hub.json
    echo $updated_catalog_hub | jq . > catalog_hub.json

    # Update IPFS with the new catalog hub
    catalog_hub_cid=$(ipfs add -Q catalog_hub.json)
    ipns=$(ipfs name publish --key=catalog_hub_key $catalog_hub_cid)

    echo "Catalog '$name' has been removed from the hub."
    echo "Updated Catalog Hub CID: $catalog_hub_cid"
    echo "IPNS: $ipns"

    # Update config.json with the new IPNS
    sed -i 's/"ipns_address": .*/"ipns_address": "'$ipns'"/' config.json
}

# Check if correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <catalog_name>"
    exit 1
fi

# Call the function with provided argument
remove_catalog "$1"