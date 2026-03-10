AWS_PROFILE ?= profile
AWS_REGION ?= eu-north-1
SECRET_NAME ?= secret-society/map-service

get-secret:
	aws secretsmanager get-secret-value \
		--secret-id $(SECRET_NAME) \
		--region $(AWS_REGION) \
		--profile $(AWS_PROFILE) \
		--query SecretString \
		--output text

env:
	aws secretsmanager get-secret-value \
		--secret-id $(SECRET_NAME) \
		--region $(AWS_REGION) \
		--profile $(AWS_PROFILE) \
		--query SecretString \
		--output text | jq -r 'to_entries|map("\(.key)=\(.value)")|.[]' > .env
