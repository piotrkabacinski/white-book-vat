function getEnvValue() {
  eval "$(grep ^$1= .env)"
}

getEnvValue "S3_BUCKET"
getEnvValue "S3_REGION"
getEnvValue "AWS_PROFILE"

sam package --template-file template.yaml \
--output-template-file packaged-template.yaml \
--profile $AWS_PROFILE \
--s3-bucket $S3_BUCKET &&

sam deploy --template-file packaged-template.yaml \
--region $S3_REGION \
--profile $AWS_PROFILE \
--stack-name WhiteBookVat \
--capabilities CAPABILITY_IAM