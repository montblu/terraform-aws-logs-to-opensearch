#!/bin/bash
latest_tag=$(curl -s "https://api.github.com/repos/montblu/aws-logs-to-opensearch/releases/latest" | jq -r '.tag_name')
echo "{\"tag\": \"$latest_tag\"}"