USE ROLE ACCOUNTADMIN;

-- Create the DevOps Role
CREATE OR REPLACE ROLE CI_DEVOPS_ROLE;

-- Create the DevOps User
CREATE OR REPLACE USER CI_DEVOPS_USER
  DEFAULT_WAREHOUSE = DEVOPS_WH
  DEFAULT_ROLE = CI_DEVOPS_ROLE
  MUST_CHANGE_PASSWORD = FALSE;

-- Assign Key Pair Authentication
ALTER USER CI_DEVOPS_USER
  SET RSA_PUBLIC_KEY = '*** REDACTED ***';

-- Assign Role to User
GRANT ROLE CI_DEVOPS_ROLE TO USER CI_DEVOPS_USER;
