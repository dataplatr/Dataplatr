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
<img width="975" height="446" alt="image" src="https://github.com/user-attachments/assets/bf0f7261-65dc-4a18-846f-a8ae29fc17b3" />

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
<img width="1262" height="847" alt="image" src="https://github.com/user-attachments/assets/b4d610dc-73b4-4678-824d-156e4362c95c" />


**Figure 2:** GL Balances Data Flow Diagram  
<img width="1264" height="755" alt="image" src="https://github.com/user-attachments/assets/2d2cd3dd-d720-422d-a195-c623fd9a9603" />

**Figure 3:** GL Journals Data Flow Diagram

- Data flows from EBS and Hyperion into the GCP ecosystem.
- Source data is dropped into GCS in CSV format using Cloud Composer.
- One-to-one target tables replicate EBS data into BigQuery tables (data replication stage).
- Transformed EDW tables are then created using **Dataform**.
- The transformed data is consumed by **Looker** for insights and visualization.

---

## Data Models
          <img width="657" height="373" alt="image" src="https://github.com/user-attachments/assets/a58c3c1f-97a0-4fb0-907f-46677b691a74" />

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
 <img width="842" height="476" alt="image" src="https://github.com/user-attachments/assets/c8461e9d-1419-4f19-8445-5f66808eefa5" />

**Figure 5:** GL Balances Data Integration  
<img width="776" height="420" alt="image" src="https://github.com/user-attachments/assets/e3e1f283-e979-4d33-8dc3-3fba1172405f" />

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
<img width="840" height="459" alt="image" src="https://github.com/user-attachments/assets/48070693-72a9-4c9a-9fa9-7910530cb63d" />

**Figure 7:** GL Journal Data Integration  
<img width="898" height="458" alt="image" src="https://github.com/user-attachments/assets/c8fc7566-a398-401c-9c6a-9d5c3cd56140" />

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
<img width="947" height="250" alt="image" src="https://github.com/user-attachments/assets/939578fa-e4d8-469c-8453-5346acb1324c" />

**Figure 9:** Cloud Composer Solution Overview  
<img width="804" height="476" alt="image" src="https://github.com/user-attachments/assets/dedbdaef-5369-454f-bce1-7ac2da869e32" />

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
<img width="958" height="448" alt="image" src="https://github.com/user-attachments/assets/bf4b7ebc-9946-4ce3-827d-ceb005f4b012" />
<img width="981" height="569" alt="image" src="https://github.com/user-attachments/assets/8c9f6b17-2c71-4652-a630-b038a5fedacd" />
<img width="981" height="304" alt="image" src="https://github.com/user-attachments/assets/7a163253-ad78-4543-90d7-c6286c2ffe1c" />




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
<img width="981" height="304" alt="image" src="https://github.com/user-attachments/assets/e780b77b-0e70-4e13-9caf-04e2c426074c" />

The Integrated GL Journals Details Dashboard stands out as a powerful tool offering a nuanced exploration of journal entries, uniquely providing insights at the levels of suppliers, customers, and invoices. This dashboard goes beyond traditional GL views, integrating seamlessly with Accounts Payable (AP) and Accounts Receivable (AR) to enhance visibility and facilitate robust account reconciliation between the General Ledger (GL) and subledger modules.

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

