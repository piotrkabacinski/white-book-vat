eval "$(grep ^S3_BUCKET= .env)"
eval "$(grep ^S3_REGION= .env)"

sam package --template-file template.yaml \
--output-template-file packaged-template.yaml \
--s3-bucket $S3_BUCKET &&

sam deploy --template-file packaged-template.yaml \
--region $S3_REGION \
--stack-name WhiteBookVat \
--capabilities CAPABILITY_IAM