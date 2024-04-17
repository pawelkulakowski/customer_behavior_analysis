# Analyzing customer data

The following project concentrates on customer data analysis:

- analyzing customer registration,
- analyzing conversion rates,
- analyzing customer activity,
- analyzing customer churn

Conversion rate is the count of customers that performed a specific desired action divided by the count of all customers

Active customers for the purpose of this project are the ones who've placed an order within the last 30 days; good customer" as a customer whose average order value 
is above the general average order value for all customers.

Inevitably, customers will stop using our services at some point. There can be many reasons for this: they may want to go to our competitors, or they may simply no longer need our services. This phenomenon is called "customer churn." On the other hand, "customer retention" is when we've succeeded in keeping a customer active during a given period.
For each weekly registration cohort, the chart shows the percentage of customers still active 30, 60, and 90 days after the registration date. 
Customer retention figures will inevitably decrease over time. Comparing these values can help us determine if our customers are leaving us too quickly

Churned clients for the purpose of this project are the ones who've not placed an order in more than 30 days

Data comes from Northwind Database: https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs


SQL:
- using DATE_TRUNC, EXTRACT with date type columns
- using aggregations like AVG, SUM
- using CTE (common table expressions) to calculate overall aggragated values
- using CASE and COUNT(CASE WHEN...) to segement clients
- JOINS to combine date from seperate tables based on the key
