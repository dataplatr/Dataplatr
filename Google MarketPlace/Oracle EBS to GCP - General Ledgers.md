# Oracle EBS to GCP: General Ledgers

## Contents
1. [Architecture](#architecture)
2. [Data Flow Diagram](#data-flow-diagram)
3. [Data Models](#data-models)
4. [GL Balances Model](#gl-balances-model)
5. [GL Journals Model](#gl-journals-model)
6. [Incremental Update using Cloud Composer](#incremental-update-using-cloud-composer)
7. [Key Looker Dashboards and Visualizations](#key-looker-dashboards-and-visualizations)
   - [GL Balances Dashboard](#gl-balances-dashboard)
   - [GL Journal Details Dashboard](#gl-journal-details-dashboard)
   - [Sales Journal Dashboard](#sales-journal-dashboard)
   - [Purchase Journal Dashboard](#purchase-journal-dashboard)
8. [Conclusion](#conclusion)

---

## Architecture

**Figure 1: Reference Architecture**

- Data from the source system (Oracle EBS) is ingested into the ODS Stage schema through Cloud Composer. Oracle EBS data first lands in a GCS bucket (CSV format) and is then inserted into the ODS Stage schema. Incremental data pulls occur after the initial load.
- The data is then merged into the ODS schema within BigQuery — this is orchestrated in Cloud Composer.
- Once merged, the original Oracle EBS file in the GCS bucket is archived.
- From ODS to EDW, data is cleansed and transformed via **Dataform** based on business rules.
- Dataform scripts execute daily to retrieve the latest data.
- These executions are automated in Cloud Composer using tag-based orchestration.
- Data is **denormalized** according to the defined data model and naming conventions.
- **Looker** connects to the EDW layer for all reporting requirements.

---

## Data Flow Diagram

**Figure 2:** GL Balances Data Flow Diagram  
**Figure 3:** GL Journals Data Flow Diagram

- Data flows from EBS and Hyperion into the GCP ecosystem.
- Source data is dropped into GCS in CSV format using Cloud Composer.
- One-to-one target tables replicate EBS data into BigQuery tables (data replication stage).
- Transformed EDW tables are then created using **Dataform**.
- The transformed data is consumed by **Looker** for insights and visualization.

---

## Data Models

**Figure 4:** Data Model Summary

- Two primary data models are developed based on business needs — **GL Balances** and **GL Journals**.
- All dimensions are shared across both models.
- **Unique features include:**
  - Dynamic currency conversion based on account type (Balance Sheet / Income Statement).
  - Integration of journal data with submodules (AP/AR) for invoice, supplier, and customer details.
  - Hierarchical integration with Hyperion for account, department, and company reporting.
  - Drill-through from general ledger to subledger.
- Dimensions include accounting, ledger, period, supplier, and customer data.
- Common dimensions are joined to facts for reporting.
- Currency conversion applied for global reporting (e.g., USD).

---

## GL Balances Model

**Figure 5:** GL Balances Data Integration  
**Figure 6:** GL Balances Data Model

- Presents a summarized and detailed view of general ledger accounting — capturing monthly activity and balance details.
- Primary source: GL Balances EBS table and related supporting tables.
- Granularity at **GL code combination** level.
- Includes **pre-calculated KPIs** such as YTD, QTD, opening, and closing balances in multiple currencies.
- Audit columns and naming standards applied at the denormalized level.
- Integrates seamlessly with **Hyperion hierarchies** to generate balance sheet and income statement reports.
- Extends integration between EBS data and Hyperion segments.

---

## GL Journals Model

**Figure 7:** GL Journal Data Integration  
**Figure 8:** GL Journal Data Model

- Extends journal reporting beyond traditional entries by integrating with **subledgers** (AP and AR).
- Primary source: EBS journal, subledger, AP, and AR tables.
- Granularity: **Journal line level**, extended to invoice distribution level for sales/purchase journals.
- Includes audit columns and standardized naming.
- Provides **supplier**, **customer**, and **invoice-level insights** for reconciliation.
- Includes **dynamic currency conversion**:
  - Income statement accounts use monthly average rates.
  - Balance sheet accounts use month-end rates.
- Pre-calculated KPIs for YTD and QTD.
- **Net Amount** calculated as (Debit – Credit) in transaction, ledger, and global currency.
- Integrated with **Hyperion hierarchies** for dimensional analysis.

---

## Incremental Update using Cloud Composer

**Figure 9:** Cloud Composer Solution Overview  
**Figure 10:** Sample Cloud Composer Data Flow

- Data is ingested into BigQuery via Cloud Composer (Airflow).
- The data pipeline flows: **Oracle EBS → GCS → ODS Stage → ODS → EDW**.
- CDC logic ensures only incremental records are processed:
  - Uses system variable for last successful execution date.
  - Fetches records where `last_update_date >= last_successful_run_date`.
- Optionally includes a **prune_days** parameter to reprocess one extra day for data accuracy.
- Configuration files store environment details (project ID, region, bucket path, extract date, etc.).

---

## Key Looker Dashboards and Visualizations

### GL Balances Dashboard

Provides a financial snapshot per fiscal period, enabling detailed balance analysis across segments and hierarchies.

**Key Features:**
- **Summary Metrics:** Opening balance, period movement, and ending balance.
- **Slicing & Dicing:** Analyze data at segment and Hyperion hierarchy level.
- **Drill-Down Analysis:** Double-click for account-level details.

**Benefits:**
- Holistic financial overview.
- Flexible, segment-based exploration.
- Faster, data-driven decision-making.
- In-depth account-level analysis.

---

### GL Journal Details Dashboard

Integrates journal-level data with AP and AR modules for supplier, customer, and invoice-level visibility.

**Key Features:**
- Journal details with complete audit trail.
- Supplier- and customer-centric metrics.
- Invoice-level breakdowns for AP/AR.
- Facilitates GL-subledger reconciliation.

**Benefits:**
- Transparent financial reporting.
- Streamlined reconciliation.
- Enhanced financial control.
- Reduced manual reconciliation effort.

---

### Sales Journal Dashboard

Focuses on **customer-level insights** for sales journal entries.

**Key Features:**
- Customer-specific sales transactions.
- Invoice-level exploration.
- Historical and top-customer analysis.
- Intuitive, user-friendly interface.

**Benefits:**
- Customer-centric performance view.
- Strategic sales insights.
- Improved customer relationship management.

---

### Purchase Journal Dashboard

Focuses on **supplier-level insights** for purchasing activities.

**Key Features:**
- Supplier-level purchasing breakdown.
- Invoice-level insights.
- Historical purchasing trends.
- Top supplier analysis with intuitive design.

**Benefits:**
- Supplier relationship management.
- Better procurement visibility.
- Enhanced strategic sourcing.

---

## Conclusion

This document outlines the **Oracle EBS → GCP General Ledger integration**, covering architecture, data flow, models, and dashboards.

Key highlights:
- Seamless integration of **GL Journals** and **GL Balances** models with subledgers (AP/AR).
- **Drill-through capability** from GL to invoice level.
- **Dynamic currency conversion** for consistent global reporting.
- Comprehensive coverage of **monthly activity and balance data**.
- Tight integration with **Hyperion hierarchies** for complete organizational reporting alignment.

By combining **GCP**, **BigQuery**, **Dataform**, and **Looker**, this architecture delivers:
- Automated data movement and validation.
- Real-time financial insights.
- Streamlined reconciliation and compliance.
- Scalable foundation for future analytical enhancements.

---

**Curious and would like to hear more?**  
📧 Contact: [info@dataplatr.com](mailto:info@dataplatr.com)  
📅 Book a free, no-obligation consultation.

---

