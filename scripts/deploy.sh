zip function.zip lambda.rb app/ -r
aws lambda update-function-code --function-name garage-bot --zip-file fileb://function.zip --profile a-garage
rm function.zip
