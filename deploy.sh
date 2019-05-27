# To run this script please provide the ENV var to CI/CD
# This script use the CloudFlare API to update the record to newly updated script!

# CloudFlare Credentials
# EMAIL: CloudFlare Email
# AUTH_KEY: CloudFlare Auth Key
# ZONE_ID: CloudFlare Zone Id

declare -a IPFS_SCRIPTS=("/app/scripts/ceph-centos.sh" "/app/scripts/setup-linux.sh")
declare -a IPFS_DNSLINK=("_dnslink.ceph-centos.scripts.barajs.dev" "_dnslink.setup-linux.scripts.barajs.dev")

find_dns_record_id() {
	local RECORD_NAME=$1
	echo $(curl -sSL -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=TXT&name=$RECORD_NAME" \
     -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
     -H "X-Auth-Key: $AUTH_KEY" \
     -H "Content-Type: application/json")
}

purge_cache() {
	record_name=$1
	ipfs_hash=$2
	host=$(echo ${record_name} | sed 's/_dnslink.//g')
	host_url="https://$host"

	# Purge cache
	result=$(curl -sSL -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
     -H "X-Auth-Key: $AUTH_KEY" \
     -H "Content-Type: application/json" \
     --data '{"files":["'"$host_url"'"]}' | jq '.success')
	echo "Purged cache of $host_url: $result"

	while true
	do
		# Try to fetch the new hash
		echo "Fetch new content of $ipfs_hash..."
		new_content=$(curl -sSL -X GET "https://cloudflare-ipfs.com/ipfs/$ipfs_hash" | md5)

		# Refetch after purge cache
		echo "Refetching domain $host to see new content..."
		domain_content=$(curl -sSL -X GET $host_url | md5)

		echo "[Compare] New: $new_content - Domain: $domain_content"
		if [ "$new_content" == "$domain_content" ]; then
			echo "The cache of $host hash been updated successfully!"
			break;
		else
			echo "The new content of $host is not yet updated with hash $ipfs_hash. Try again in 30s..."
		fi
		sleep 30s
	done
}

verify_cache() {
	record_name=$1
	ipfs_hash=$2
	host=$(echo ${record_name} | sed 's/_dnslink.//g')
	host_url="https://$host"

	while true
	do
		echo "Try to verify the DNS of $host_url..."
		dns_hash=$(ipfs name resolve $host | sed 's/\/ipfs\///g')
		if [ "$dns_hash" == "$ipfs_hash" ]; then
			echo "DNS for $host_url has been updated!"
			break;
		else
			echo "DNS not match: DNS=$dns_hash HASH=$ipfs_hash . Try again in 60s!"
		fi
		sleep 60s
	done
}

update_dns() {
	record_name=$1
	hash=$2
	content="dnslink=/ipfs/$hash"
	record_id=$(find_dns_record_id $record_name | jq --raw-output '.result[0].id')

	result=$(curl -sSL -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id" \
     -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
     -H "X-Auth-Key: $AUTH_KEY" \
     -H "Content-Type: application/json" \
     --data '{"type":"TXT","name":"'"$record_name"'","content":"'"$content"'","ttl":1,"proxied":false}' \
		| jq '.success')
  echo "Update record $record_name ($record_id): $result"
	purge_cache $record_name $hash
	verify_cache $record_name $hash
}

add_to_ipfs() {
	hash=$(ipfs add -q $1)
	echo $hash
}

swarm_connect() {
  echo "\nConnecting swarm to the main nodes..."
  curl -sSL https://cloudflare-ipfs.com/ipns/find.vgm.tv | jq -r --raw-output '.nodes[] | .multiaddress' | xargs -n1 ipfs swarm connect
}

deploy() {
	echo "Waiting for IPFS daemon in ${WAIT_FOR_IPFS}s..."
	sleep $WAIT_FOR_IPFS
	swarm_connect
	for i in "${!IPFS_SCRIPTS[@]}"
	do
		hash=$(add_to_ipfs "${IPFS_SCRIPTS[i]}")
		echo "Added script ${IPFS_SCRIPTS[i]} to IPFS with hash: $hash"
  	update_dns "${IPFS_DNSLINK[i]}" $hash
		echo ""
	done
	ipfs shutdown
}

main() {
	echo "The process will be completed in $TIMEOUT seconds!"
	deploy;
	exit 0;
}

main
