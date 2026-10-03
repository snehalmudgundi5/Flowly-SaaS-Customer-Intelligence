# 🔷  Flowly | SaaS Product & Customer Intelligence Analytics

<p align="center">
  <img src="assets/flowly_logo.png" width="140">
</p>


<p align="center">
  <strong>End-to-End SaaS Data Analytics & Business Intelligence Project</strong>
</p>

<p align="center">

![Python](https://img.shields.io/badge/Python-Data%20Analytics-blue?style=for-the-badge&logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Analysis-150458?style=for-the-badge&logo=pandas&logoColor=white)
![NumPy](https://img.shields.io/badge/NumPy-Numerical%20Analysis-013243?style=for-the-badge&logo=numpy&logoColor=white)
![Matplotlib](https://img.shields.io/badge/Matplotlib-Visualization-orange?style=for-the-badge)
![Seaborn](https://img.shields.io/badge/Seaborn-Statistical%20Visualization-4C72B0?style=for-the-badge)

</p>

<p align="center">

![SQL Server](https://img.shields.io/badge/SQL%20Server-Data%20Analytics-red?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-Business%20Intelligence-E97627?style=for-the-badge&logo=tableau&logoColor=white)
![Customer Analytics](https://img.shields.io/badge/Customer%20Analytics-Intelligence-796BF6?style=for-the-badge)
![Cohort Analysis](https://img.shields.io/badge/Cohort%20Analysis-Retention-0875F8?style=for-the-badge)
![Project](https://img.shields.io/badge/Project-Completed-brightgreen?style=for-the-badge)

</p>

---



# 📌 Project Overview

**Flowly** is a fictional B2B SaaS productivity and collaboration platform created specifically for this analytics project.

The project was designed to simulate a real-world SaaS analytics environment where a company wants to understand:

- 👥 Who its customers are
- 💰 Which customers and plans generate revenue
- 📊 How customers use the product
- 🧩 Which features are most adopted
- 🔄 Why customers churn
- 📈 How engagement relates to retention
- 🕒 How customer relationships evolve over their lifecycle
- 🧑‍🤝‍🧑 How customer retention changes across signup cohorts

The project follows an end-to-end analytics workflow:

**Raw Data → Python → SQL Server → Business Analysis → Tableau → Insights**

---

# 🎯 Business Problem

A SaaS business generates large amounts of customer, subscription, product usage, payment, and support data.

However, raw data alone does not answer important business questions.

Flowly needs to understand:

### 👥 Customer Intelligence
- Which customer segments are most valuable?
- Which countries contribute the most customers?
- How are customers distributed across subscription plans?

### 💰 Revenue
- Which plans generate the most revenue?
- How does revenue change month over month?
- Which customers contribute the most revenue?

### 📊 Product Engagement
- How actively are customers using Flowly?
- How much time do customers spend in the product?
- Which customer segments show stronger engagement?

### 🧩 Feature Adoption
- Which features are most widely used?
- Which features have lower adoption?
- Are customers adopting the complete Flowly product ecosystem?

### 🔄 Churn & Retention
- What is the overall churn rate?
- How does churn differ across plans?
- Is lower engagement associated with higher churn?
- How does customer activity change after signup?

### 🕒 Customer Lifecycle
- How long do customers typically remain subscribed?
- How are customers distributed across lifecycle stages?
- What does cohort activity retention look like over time?

---

# 💡 Project Objective

The objective was to build a complete analytics solution that transforms raw SaaS data into **customer intelligence and actionable business insights**.

The solution combines:

🐍 **Python** for data exploration and analytical preparation

🗄️ **SQL Server** for structured data analysis and advanced business queries

📊 **Tableau** for interactive dashboards and decision-oriented visualization

---

# 🧩 Dataset

The project uses a **synthetic SaaS dataset** designed to represent a realistic B2B SaaS environment.

The dataset contains approximately:

- 👥 **10,000 customers**
- 👤 **138K+ users**
- 🖱️ **161K+ activity records**
- 🧩 **103K+ feature usage records**
- 💳 **110K+ payment records**
- 🎫 **20K+ support tickets**

## Dataset Tables

| Table | Description |
|---|---|
| `customers.csv` | Customer/company information |
| `subscriptions.csv` | Subscription plans, seats, dates and pricing |
| `users.csv` | Users associated with customers |
| `user_activity.csv` | Product activity and session information |
| `feature_usage.csv` | Feature-level product usage |
| `payments.csv` | Customer payment transactions |
| `support_tickets.csv` | Customer support interactions |
| `data_dictionary.csv` | Definitions of dataset fields |

---

# ⚠️ Dataset Disclaimer

**Flowly is a fictional company.**

The dataset is **synthetic** and was created specifically for educational and portfolio purposes.

It does not represent real Flowly customers, revenue, product usage, or company performance.

The business scenario, schema, relationships and analytical requirements were defined for this project, while Python-based synthetic data generation was used to create a realistic analytical environment.

---

# 🏗️ Data Model

The project uses `customers` as the central customer-level entity.

```text
                         ┌──────────────────┐
                         │    CUSTOMERS     │
                         │   customer_id    │
                         └────────┬─────────┘
                                  │
             ┌────────────────────┼────────────────────┐
             │                    │                    │
             ▼                    ▼                    ▼
     ┌───────────────┐    ┌──────────────┐    ┌───────────────┐
     │ SUBSCRIPTIONS │    │    USERS     │    │   PAYMENTS    │
     └───────────────┘    └──────┬───────┘    └───────────────┘
                                  │
                         ┌────────┴────────┐
                         ▼                 ▼
                ┌────────────────┐  ┌────────────────┐
                │ USER ACTIVITY  │  │ FEATURE USAGE  │
                └────────────────┘  └────────────────┘

                         CUSTOMERS
                             │
                             ▼
                    ┌─────────────────┐
                    │ SUPPORT TICKETS │
                    └─────────────────┘
