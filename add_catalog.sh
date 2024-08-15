#!/bin/bash

# Function to add new content
add_catalog() {
    local name="$1"
    local description="$2"
    local content_cid="$3"

    # Create a new JSON file for the registry with content_cids as an array
    cat > "${name}_registry.json" <<EOF
{
    "name": "$name",
    "description": "$description",
    "content_cids": ["$content_cid"]
}
EOF

    # Add the registry file to IPFS
    registry_cid=$(ipfs add -Q "${name}_registry.json")

    # Read the current catalog_hub.json
    catalog_hub_content=$(cat catalog_hub.json | jq .)

    # Add the new entry to the catalog hub
    updated_content=$(echo $catalog_hub_content | jq --arg name "$name" --arg cid "$registry_cid" '.content += {($name): $cid}')

    # Write the updated content back to catalog_hub.json
    echo $updated_content | jq . > catalog_hub.json

    # Update IPFS with the new catalog hub
    catalog_hub_cid=$(ipfs add -Q catalog_hub.json)
    ipns=$(ipfs name publish --key=catalog_hub_key $catalog_hub_cid)

    echo "New content added to catalog hub."
    echo "Registry CID: $registry_cid"
    echo "Updated Catalog Hub CID: $catalog_hub_cid"
    echo "IPNS: $ipns"

    # Update config.json with the new IPNS
    sed -i 's/"ipns_address": .*/"ipns_address": "'$ipns'"/' config.json
}

# Check if correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <name> <description> <initial_content_cid>"
    exit 1
fi

# Call the function with provided arguments
add_catalog "$1" "$2" "$3"