#!/bin/bash

# The directory where we will create the tmp file
ROOTDIR=$HOME/aws-cli
ENV_SETUP_FILE=$ROOTDIR/tmp/env-setup.sh

echo "Account (test1, test2): " # List accounts seperated by commas ehre
read account

echo "Login:"
read login

echo "Password:"
read -s password

targetRole="testRole" # List the role that we should assume (STS)

if [[ "$account" == "test1" ]]
then
    roleToken="$account"
    accountId="00000000" # AccountId
    apiHost="aws-apihost-tst.example.com" # aws-security-services or something similar is a good name
    AWS_DEFAULT_REGION=us-east-1 # Region
    provider="OKTA" # Any provider works, I tested this with Okta
elif [[ "$account" == "test2" ]]
then
    roleToken="$account"
    accountId="00000000"
    apiHost="aws-apihost-tst.example.com" 
    AWS_DEFAULT_REGION=us-east-1
    provider="OKTA"
else
    echo "Invalid account [$account]"
    exit 1
fi


# Ensure that domain is changed to the domain of your org
output=`curl -k -X POST "https://${apiHost}/getcredential" -d username=$login -d password=$password -d "arn=arn:aws:iam::${accountId}:role/domain.saml.${roleToken}-${targetRole},arn:aws:iam::${accountId}:saml-provider/${provider}" --insecure` # Ensure that domain is changed to the domain of your org

echo "Response is [$output]"

AWS_ACCESS_KEY_ID=`echo $output | awk '{print $10}'`
AWS_SECRET_ACCESS_KEY=`echo $output | awk '{print $13}'`
AWS_SESSION_TOKEN=`echo $output | awk '{print $16}'`

echo "Done parsing ...."

echo "" > $ENV_SETUP_FILE
echo "#!/bin/bash" >> $ENV_SETUP_FILE
echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> $ENV_SETUP_FILE
echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> $ENV_SETUP_FILE
echo "export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" >> $ENV_SETUP_FILE
echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> $ENV_SETUP_FILE
echo "export AWS_ACCOUNT_ID=$accountId" >> $ENV_SETUP_FILE
echo "export AWS_ACCOUNT=$account" >> $ENV_SETUP_FILE

echo ""
echo ""
echo "Please run: . $ENV_SETUP_FILE"
echo ". $ENV_SETUP_FILE"
echo "set|grep AWS"
