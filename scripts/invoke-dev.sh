aws lambda invoke --function-name garage-bot \
  --payload file://aws-challenge.json \
  --log Tail response.json
