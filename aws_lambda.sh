eval "$(grep ^S3_BUCKET= .env)"
eval "$(grep ^S3_REGION= .env)"
eval "$(grep ^AWS_PROFILE= .env)"

sam package --template-file template.yaml \
--output-template-file packaged-template.yaml \
--profile $AWS_PROFILE \
--s3-bucket $S3_BUCKET &&

sam deploy --template-file packaged-template.yaml \
--region $S3_REGION \
--profile $AWS_PROFILE \
--stack-name WhiteBookVat \
--capabilities CAPABILITY_IAM