# Retail Data Analytics Project

## Introduction

London Gift Shop (LGS) is an online retailer that sells giftware products to both individual consumers and wholesale clients. Although the company has accumulated years of transactional data through its web application, this data has not been fully leveraged to support business decision-making. As a result, LGS lacks visibility into customer behavior, purchasing patterns, and long-term customer value.

The goal of this project is to transform raw transactional data into meaningful analytical insights that can support marketing and revenue growth initiatives. By analyzing historical purchase data, LGS can better understand seasonal trends, customer retention, purchasing frequency, and high-value customer segments. These insights can then be used to design targeted marketing campaigns, improve customer retention strategies, and allocate marketing resources more effectively.

In this project, a data analytics solution was developed using Python and Jupyter Notebook to clean, transform, analyze, and visualize retail transaction data. Key technologies include Pandas, NumPy, and Matplotlib, with data sourced from a CSV extract of LGS transactional records. The final output is an analytical notebook that answers business questions related to sales performance, customer activity, and customer segmentation.

## Implementation
### Project Architecture

At a high level, the LGS system consists of a web application that records transactional data such as invoices, products, customers, and purchase timestamps. This transactional data is periodically exported by the IT team into a structured file (CSV or database dump) for analytical purposes.

The analytics architecture for this project follows these steps:

1. **LGS Web Application**

- Generates transactional purchase data from customer orders

2. **Data Export Layer**

- Transactional data is exported into a CSV file for analysis

3. **Analytics Layer (This Project)**

- Jupyter Notebook running in VS Code

- Pandas used for data wrangling and transformation

- Matplotlib used for visualization and exploratory analysis

4. **Business Insights**

- Analytical results are used by marketing and business teams to support decision-making

This separation ensures that analytical workloads do not impact the performance of the production web application.

### Data Analytics and Wrangling

The complete data analytics workflow is implemented in the following notebook:
[retail_data_analytics_wrangling.ipynb](.python_data_wrangling/retail_data_analytics_wrangling.ipynb)

**Key data analytics tasks include:**

- Cleaning raw transactional data and standardizing column names

- Converting data types (e.g. timestamps, numeric values)

- Computing derived metrics such as invoice amount and monthly revenue

- Identifying canceled orders and adjusting business metrics accordingly

- Analyzing:

    - Monthly sales trends

    - Sales growth rates

    - Monthly active users

    - New vs existing customers

- Performing RFM (Recency, Frequency, Monetary) analysis and customer segmentation

## Business Value for LGS

The analytics produced in this project can directly support LGS revenue growth by:

- Identifying high-value customers through RFM segmentation, enabling targeted loyalty programs

- Understanding seasonality, allowing marketing teams to plan promotions during high-impact months

- Detecting customer churn risk, enabling re-engagement campaigns for at-risk users

- Distinguishing new vs existing users, helping evaluate the effectiveness of customer acquisition strategies

By acting on these insights, LGS can shift from broad marketing efforts to data-driven, customer-centric strategies.

## Improvements

If more time were available, the following improvements could be implemented:

1. **Integrate a Data Warehouse**

- Load transactional data into PostgreSQL or a cloud-based warehouse to support scalable analytics and automation

2. **Automate the Data Pipeline**

- Build an ETL workflow to regularly ingest, clean, and update data without manual intervention

3. **Advanced Analytics & Visualization**

- Add cohort analysis, lifetime value (LTV) modeling, and interactive dashboards using BI tools such as Tableau or Looker
