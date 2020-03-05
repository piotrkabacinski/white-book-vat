sam package --template-file template.yaml \
--output-template-file packaged-template.yaml \
--s3-bucket white-book-vat &&

sam deploy --template-file packaged-template.yaml \
--stack-name WhiteBookVat \
--capabilities CAPABILITY_IAM