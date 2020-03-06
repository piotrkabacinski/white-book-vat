sam package --template-file template.yaml \
--profile sandbox \
--output-template-file packaged-template.yaml \
--s3-bucket codequest-white-book-vat &&

sam deploy --template-file packaged-template.yaml \
--region eu-central-1 \
--profile sandbox \
--stack-name WhiteBookVat \
--capabilities CAPABILITY_IAM