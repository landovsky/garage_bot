zip function.zip lambda.rb app/ -r
aws lambda update-function-code --function-name garage-bot --zip-file fileb://function.zip
rm function.zip
