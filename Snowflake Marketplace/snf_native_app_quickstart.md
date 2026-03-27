# AI-ELT Native App for Snowflake

## Overview

**AI-ELT Native App** is a Snowflake Native Application that provides a **containerized Streamlit interface** for AI-assisted data engineering and analytics workflows directly inside Snowflake.

The application runs entirely within the customer’s Snowflake account using **Snowpark Container Services**, with optional outbound access to approved external services such as GitHub, PyPI, and Google Vertex AI when explicitly authorized by the customer.

---

## Key Capabilities

- 📊 Interactive **Streamlit UI** hosted natively in Snowflake  
- 🐳 Secure **containerized execution** using Snowpark Container Services  
- 🔐 Optional, customer-approved **external access** for:
  - GitHub APIs (versioned artifacts, metadata)
  - PyPI (Python dependency resolution)
  - Google Vertex AI (LLM inference)
  - 🧩 Designed to create and manage ELT Pipelines in a no-code fashion within Snowflake includes creating **tables and views in customer-selected schemas**
  - Applicable for teams working on Finance, Supply chain, Contact center analytics.
- 🚫 No data leaves Snowflake unless explicitly initiated by the user

---

## Architecture Overview

- **Frontend:** Streamlit (containerized)
- **Runtime:** Snowpark Container Services
- **Security Model:** Snowflake Native App (consumer-controlled permissions)
- **External Connectivity:** External Access Integration (optional, approval required)

All compute, storage, and execution occur **within the consumer’s Snowflake account**.

---

## Required Setup (Consumer Account)

Before installing the application, the following objects must exist in the consumer account. These steps are required **only if external access is enabled**.

### 1. Network Rule

Create a network rule allowing outbound access to the required external services:

```sql
CREATE NETWORK RULE ai_elt_network_rule
  TYPE = HOST_PORT
  MODE = EGRESS
  VALUE_LIST = (
    'api.github.com:443',
    'raw.githubusercontent.com:443',
    'pypi.org:443',
    'files.pythonhosted.org:443',
    'aiplatform.googleapis.com:443',
    'us-central1-aiplatform.googleapis.com:443',
    'generativelanguage.googleapis.com:443',
    'oauth2.googleapis.com:443',
    'sts.googleapis.com:443',
    'iamcredentials.googleapis.com:443'
  );
```
### 2. Create an External Access Integration

Create an External Access Integration that references the network rule:
``` sql

CREATE EXTERNAL ACCESS INTEGRATION AI_ELT_ACCESS
  ALLOWED_NETWORK_RULES = (ai_elt_network_rule)
  ENABLED = TRUE;
```

⚠️ This integration must be approved by a Snowflake account administrator during or after installation.


### 3. Create Required Secrets

Create the required secrets in the consumer account:

```sql
CREATE SECRET github_pat
  TYPE = GENERIC_STRING
  SECRET_STRING = '<your_github_personal_access_token>';

CREATE SECRET vertex_sa
  TYPE = GENERIC_STRING
  SECRET_STRING = '<your_vertex_ai_service_account_json>';
```

## Installing the Application

Install the application using the following SQL command:

```sql
CREATE APPLICATION ai_elt_app
  FROM APPLICATION PACKAGE AI_ELT_NATIVE_APP
  USING
    external_access_integrations = (AI_ELT_ACCESS)
    secrets = (
      github_pat = github_pat,
      vertex_sa = vertex_sa
    )
    compute_pool = my_pool;
    ```

The compute pool must already exist and be available to the installing role.

## External Services Used

This application will integrate with the following external services **only after customer approval**:

- **Google Vertex AI** – Large Language Model inference  
- **GitHub APIs** – Versioned artifact access  
- **PyPI** – Python package resolution  



