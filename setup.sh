ipfs key gen --type=ed25519 catalog_hub_key

CID=$(ipfs add -Q catalog_hub.json)

IPNS=$(ipfs name publish --key=catalog_hub_key $CID)

echo "Setup complete. IPNS: $IPNS"

sed -i 's/"ipns_address": .*/"ipns_address": "'$IPNS'"/' config.json