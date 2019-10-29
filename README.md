Visit https://dev.classmethod.jp/cloud/aws/aws-glue-local/

# Using sample.py

## boot the localstack

```
docker-compose up
```

## init dynamodb

```
aws dynamodb create-table \
    --table-name aws-glue-local-test-table \
    --attribute-definitions \
        AttributeName=Id,AttributeType=S \
    --key-schema AttributeName=Id,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
    --endpoint-url http://localhost:4569
```

## insert sample data

```
aws dynamodb put-item \
    --table-name aws-glue-local-test-table  \
    --item \
        '{"Id": {"S": "test"}, "Column1": {"S": "test1"}, "Column2": {"S": "test2"}, "Column3": {"S": "test3"}}' \
    --endpoint-url http://localhost:4569
```

## init s3

```
aws s3api create-bucket \
    --bucket aws-glue-local-test-bucket \
    --endpoint-url http://localhost:4572
```

## run sample.py

```
docker-compose run localglue bash
./bin/gluesparksubmit sample.py --JOB_NAME='dummy'
```

## check result

```
aws s3api list-objects \
    --bucket aws-glue-local-test-bucket \
    --endpoint-url http://localhost:4572
```
