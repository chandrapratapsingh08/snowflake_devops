USE ROLE ACCOUNTADMIN;

-- If the warehouse does not exist, create it
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
  WAREHOUSE_SIZE = XSMALL
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE;

-- If the warehouse exists and you need to update its properties, use ALTER
ALTER WAREHOUSE COMPUTE_WH
  SET WAREHOUSE_SIZE = XSMALL,
      AUTO_SUSPEND = 300,
      AUTO_RESUME = TRUE;


-- Separate database for git repository
CREATE OR ALTER DATABASE CP_DEMO_DATABASE;


-- API integration is needed for GitHub integration
CREATE OR REPLACE api integration git_api_integration
    api_provider = git_https_api
    api_allowed_prefixes = ('https://github.com/chandrapratapsingh08')
    enabled = true
    allowed_authentication_secrets = all;

-- Git repository object is similar to external stage
CREATE OR REPLACE GIT REPOSITORY CP_DEMO_DATABASE.PUBLIC.SNOWFLAKE_DEVOPS
  API_INTEGRATION = GIT_API_INTEGRATION
  ORIGIN = 'https://github.com/chandrapratapsingh08/snowflake_devops'; -- INSERT URL OF FORKED REPO HERE

CREATE OR ALTER DATABASE CP_DEMO_DATABASE;


-- To monitor data pipeline's completion
CREATE OR REPLACE NOTIFICATION INTEGRATION email_integration
  TYPE=EMAIL
  ENABLED=TRUE;


-- Database level objects
CREATE OR ALTER SCHEMA bronze;
CREATE OR ALTER SCHEMA silver;
CREATE OR ALTER SCHEMA gold;


-- Schema level objects
CREATE OR REPLACE FILE FORMAT bronze.json_format TYPE = 'json';
CREATE OR ALTER STAGE bronze.raw;


-- Copy file from GitHub to internal stage
copy files into @bronze.raw from @cp_demo_database.public.snowflake_devops/branches/main/data/airport_list.json;
