#!/bin/bash

remove_cid() {
    local name="$1"
    local cid_to_delete="$2"

    # Read the current catalog_hub.json
    catalog_hub_content=$(cat catalog_hub.json | jq -r .)
 
    # Get the registry CID for the given name
    registry_cid=$(echo $catalog_hub_content | jq -r ".content[\"$name\"]")

    if [ -z "$registry_cid" ] || [ "$registry_cid" == "null" ]; then
        echo "Error: Catalog '$name' not found in the hub."
        exit 1
    fi

    # Fetch the registry JSON from IPFS
    ipfs cat $registry_cid > temp_registry.json

    # Remove the specified CID from the content_cids array
    updated_registry=$(cat temp_registry.json | jq --arg cid "$cid_to_delete" '.content_cids -= [$cid]')

    # Write the updated registry back to a file
    echo $updated_registry | jq . > temp_registry.json

    # Add the updated registry file to IPFS
    new_registry_cid=$(ipfs add -Q temp_registry.json)

    # Update the catalog hub with the new registry CID
    updated_catalog_hub=$(echo $catalog_hub_content | jq --arg name "$name" --arg cid "$new_registry_cid" '.content[$name] = $cid')

    # Write the updated catalog hub back to catalog_hub.json
    echo $updated_catalog_hub | jq . > catalog_hub.json

    # Update IPFS with the new catalog hub
    catalog_hub_cid=$(ipfs add -Q catalog_hub.json)
    ipns=$(ipfs name publish --key=catalog_hub_key $catalog_hub_cid)

    echo "CID deleted from '$name' catalog."
    echo "Updated Registry CID: $new_registry_cid"
    echo "Updated Catalog Hub CID: $catalog_hub_cid"
    echo "IPNS: $ipns"

    # Update config.json with the new IPNS
    sed -i 's/"ipns_address": .*/"ipns_address": "'$ipns'"/' config.json

    # Clean up temporary file
    rm temp_registry.json
}

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <catalog_name> <content_cid_to_delete>"
    exit 1
fi

# Call the function with provided arguments
remove_cid "$1" "$2"