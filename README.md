# data-platform-warehouse
CloudBolt data warehouse infrastructure including Snowflake configuration management

## Description

This repository contains infrastructure-as-code for provisioning Snowflake
DevOps resources, including users, roles, permissions, key pairs, and
pipeline automation via GitHub Actions.


The design of the repository follows this [developer guide](https://docs.snowflake.com/en/developer-guide/builders/devops)
published by Snowflake.


```
.
├── .github/
│   └── workflows/               # GitHub Actions workflow files
│       └── deploy_pipeline.yml  # Automates Snowflake provisioning
├── .gitignore                   # Defines ignored files (logs, keys, etc.)
├── .snowflake/
│   └── config.toml.j2           # Jinja2 template for Snowflake CLI configuration
├── README.md                    # Repository documentation
├── data/                         # Placeholder for data files (if needed)
├── scripts/                      # Utility scripts for the repository
│   └── generate_keypair.sh       # Script to generate RSA key pairs for authentication
├── steps/                        # SQL provisioning steps
│   └── 01_setup_devops_stage.sql.j2 # Jinja2 SQL template to set up DevOps stage
└── workbooks/
    └── provision_devops_user.sql   # SQL script to manually create DevOps user
```

## Sequence

The configuration of the CloudBolt Snowflake warehouse is proposed to happen in
**THREE** steps.

 1. Use the workbook provided to create the **CI_DEVOPS_ROLE** and **CI_DEVOPS_USER**
 1.1 The workbook refers to an ssh keypair that can be generated using the
*generate_keypair.sh* script in the scripts directory.
 1.2 The private key should be encoded using base64 and stored as a GitHub secret
called *SNOWFLAKE_PRIVATE_KEY*.

 2. The GitHub actions provided in this repository will perform the next level
of IAC provisioning creating DevOps staging, network access rules and policies,
user access roles and other resources pertaining to each environment *Development*,
*Testing*, *Staging* and *Production*.
 2.1 The Github repository should have specific variables created:
```
SNOWFLAKE_ACCOUNT="xobtrhg-tfb57004"
SNOWFLAKE_USER="tf-snow"
SNOWFLAKE_ROLE="ACCOUNTADMIN"
SNOWFLAKE_AUTHENTICATOR="SNOWFLAKE_JWT"
SNOWFLAKE_WAREHOUSE="CLOUDBOLT_DEVOPS_WH"
SNOWFLAKE_DATABASE="CLOUDBOLT_DEVOPS_DB"
SNOWFLAKE_SCHEMA="INTEGRATIONS"
SNOWFLAKE_TABLE="REPO"
SNOWFLAKE_GITHUB_USERNAME="cb-mdoherty"
SNOWFLAKE_GITHUB_REPONAME="CloudBoltSoftware/data-platform-warehouse"
```
 2.2 The GitHub repository should have specific secrets created:
```
SNOWFLAKE_PRIVATE_KEY="**REDACTED**"
SNOWFLAKE_GITHUB_PASSWORD="**REDACTED**"
```

 3. The creation of CloudBolt tenants using self-service means *may* not be
suitable for *Infrastructure-as-Code* and it is envisaged that a dynamic
API be developed which leverages SQL templates contained within this repository
to orchestrate the resources and hierarchies required for each tenant.


## Development

Debugging GitHub Actions workflows without pushing to GitHub can be done using local testing
tools like **act**.

### Use act to Run GitHub Actions Locally ###

[act](https://github.com/nektos/act) is a CLI tool that allows you to run GitHub Actions locally
using Docker.

### Installation

```
brew install act  # macOS (Homebrew)
choco install act-cli  # Windows (Chocolatey)
scoop install act  # Windows (Scoop)
curl -sSL https://raw.githubusercontent.com/nektos/act/main/install.sh | sudo bash  # Linux
```

### Run Your Workflow Locally

To test your workflow:
```
act -j deploy  # Runs only the 'deploy' job
```

If you need to simulate a push to a branch:
```
act push -e event.json
```
where event.json contains a sample GitHub event payload.


### Limitations of act

  * Uses Docker to simulate workflows, so it doesn’t fully support all GitHub-hosted runners.
  * Some actions might not work due to GitHub API calls that require authentication.
  * Variables and Secrets must be set manually using .vars and .secrets file:

```
echo "SNOWFLAKE_ACCOUNT=my_account" >> .secrets
echo "SNOWFLAKE_REPO=my_repo" >> .vars
```

Pass these files to *act* as follows:
```
act -j deploy --secret-file .secrets --var-file .vars
```
