# Kubeflow on AWS - ML Infra

## Getting Started

1. Install aws cli and configure.
2. Navigate to [rds-s3 deployment with terraform](./deployments/rds-s3/terraform/) for the infra code. 
```
cd ./deployments/rds-s3/terraform/
make setup
```
3. Fetch and run the kubectl config command line.
Make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig.
```
make config-eks
```

## Connect to Kubeflow UI
1. Navigate to [rds-s3 deployment with terraform](./deployments/rds-s3/terraform/) for the infra code.
```
cd ./deployments/rds-s3/terraform/
```
2. A port alternative to 8080 can be specified by adding an argument, e.g. PORT=8088
```
make port-forward
```

## Add a Kubeflow profile with dex
This section follows https://awslabs.github.io/kubeflow-manifests/docs/deployment/create-profiles-with-iam-role/
1. Navigate to [rds-s3 deployment with terraform](./deployments/rds-s3/terraform/) for the infra code.
```
cd ./deployments/rds-s3/terraform/
```
2. Create an IAM role
In [profiles.tf](./deployments/rds-s3/terraform/profiles.tf), add your profile name in the `profiles` local variable and export it for later.
```
export PROFILE_NAMESPACE=your-namespace
```
Run apply to create a role for this profile.
```
make apply
export ROLE_ARN=$(tf output -json kf_profile_role_arns | jq -r --arg PROFILE_NAMESPACE "$PROFILE_NAMESPACE" '.[$PROFILE_NAMESPACE]')
```
3. Create a user and a password in dex
```
make get-dex-config
```
A file `dex-yaml.yaml` will be created. There will be a section which contains an example user and its password.
```
staticPasswords:
- email: user@example.com
  hash: $2y$12$4K/VkmDd1q1Orb3xAt82zu8gk7Ad6ReFR4LCP9UeYE90NLiN9Df72
  # https://github.com/dexidp/dex/pull/1601/commits
  # FIXME: Use hashFromEnv instead
  username: user
  userID: "15841185641784"
```
Create a user here by adding:
```
- email: your@email.com
  hash: you can create a password hash with an online tool, for example bcrypt.online
  username: your username
```
And apply this config.
```
make add-dex-user-from-config
```
Export the user email for later.
```
export PROFILE_USER=your@email.com
```
4. Create a profile with IAM in KF
```
cat <<EOF > profile_iam.yaml
apiVersion: kubeflow.org/v1
kind: Profile
metadata:
  name: ${PROFILE_NAMESPACE}
spec:
  owner:
    kind: User
    name: ${PROFILE_USER}
  plugins:
  - kind: AwsIamForServiceAccount
    spec:
      awsIamRole: ${ROLE_ARN}
      annotateOnly: true
EOF

make create-profile
```