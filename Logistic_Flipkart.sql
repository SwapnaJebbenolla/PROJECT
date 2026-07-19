CREATE DATABASE FILPKART_LOGISTICS;
USE FILPKART_LOGISTICS;

CREATE TABLE FLIPKART_ORDERS (
ORDER_ID VARCHAR(100),
WAREHOUSE_ID VARCHAR(50),
ROUTE_ID VARCHAR(50),
AGENT_ID VARCHAR(50),
ORDER_DATE DATE,
EXPECTED_DELIVERY_DATE DATE,
ACTUAL_DELIVERY_DATE DATE,
STATUS VARCHAR(50),
ORDER_VALUE DECIMAL(10,2)
);
SELECT * FROM FLIPKART_ORDERS;

CREATE TABLE FLIPKART_ROUTES (
ROUTE_ID VARCHAR(50),
START_LOCATION VARCHAR(50),
END_LOCATION VARCHAR(50),
DISTANCE_KM INT,
AVERAGE_TRAVEL_TIME_MIN INT,
TRAFFIC_DELAY_MIN INT
);
SELECT * FROM FLIPKART_ROUTES;

CREATE TABLE FLIPKART_SHIPMENTTRACKING (
TRACKING_ID VARCHAR(50),
ORDER_ID VARCHAR(50),
CHECKPOINT VARCHAR(50),
CHECKPOINT_TIME DATETIME,
DELAY_REASON VARCHAR(50),
DELAY_MINUTES INT
);
SELECT * FROM FLIPKART_SHIPMENTTRACKING;

CREATE TABLE FLIPKART_WAREHOUSES (
WAREHOUSE_ID VARCHAR(50),
WAREHOUSE_NAME VARCHAR(50),
CITY VARCHAR(50),
PROCESSING_CAPACITY INT,
AVERAGE_PROCESSING_TIME_MIN INT
);
SELECT * FROM FLIPKART_WAREHOUSES;

CREATE TABLE FLIPKART_DELIVERYAGENTS (
AGENT_ID VARCHAR(50),
AGENT_NAME VARCHAR(50),
ROUTE_ID VARCHAR(50),
AVG_SPEED_KMPH DECIMAL(5,2),
ON_TIME_DELIVERY_PERCENTAGE DECIMAL(5,2),
EXPERIENCE_YEARS DECIMAL(5,2)
);
SELECT * FROM FLIPKART_DELIVERYAGENTS;


### TASK 1: DATA CLEANING & PREPARATION

# Identify and delete duplicate Order_ID records..........
SELECT
    Order_ID,
    COUNT(*) AS Duplicate_Count
FROM FLIPKART_ORDERS
GROUP BY Order_ID
HAVING COUNT(*) > 1;
#{ No rows are returned, all Order IDs are unique. }


# Replace null Traffic_Delay_Min with the average delay for that route........
SELECT *
FROM FLIPKART_ROUTES
WHERE Traffic_Delay_Min IS NULL; 
#{ No rows are returned, the Traffic_Delay_Min column contains no missing values}


# Ensure that no Actual_Delivery_Date is before Order_Date (flag such records)......
SELECT
    Order_ID,
    Order_Date,
    Actual_Delivery_Date
FROM FLIPKART_ORDERS
WHERE
STR_TO_DATE(Actual_Delivery_Date,'%d-%m-%Y')
<
STR_TO_DATE(Order_Date,'%d-%m-%Y');
#{ No rows are returned, all delivery records are logically valid }

# Convert all date columns into YYYY-MM-DD format using SQL functions.
SELECT * FROM FLIPKART_ORDERS LIMIT 1;

SELECT * FROM FLIPKART_ROUTES LIMIT 1;

SELECT * FROM FLIPKART_WAREHOUSES LIMIT 1;

SELECT * FROM FLIPKART_DELIVERYAGENTS LIMIT 1;

SELECT * FROM FLIPKART_SHIPMENTTRACKING LIMIT 1;



## Task 2: Delivery Delay Analysis 

# Calculate delivery delay (in days) for each order....
SELECT
    Order_ID,
    Warehouse_ID,
    Route_ID,
    DATEDIFF(Actual_Delivery_Date, Expected_Delivery_Date) AS Delay_Days
FROM FLIPKART_ORDERS;
#{ Shows how many days each order was delayed.Higher delay means poorer delivery performance }


# Find Top 10 delayed routes based on average delay days.
SELECT
    Route_ID,
    AVG(DATEDIFF(Actual_Delivery_Date, Expected_Delivery_Date)) AS Avg_Delay
FROM FLIPKART_ORDERS
GROUP BY Route_ID
ORDER BY Avg_Delay DESC
LIMIT 10;
#{ Identifies routes with the highest average delay.These routes need improvement and monitoring. }


# Use window functions to rank all orders by delay within each warehouse.
SELECT
    Order_ID,
    Warehouse_ID,
    DATEDIFF(Actual_Delivery_Date, Expected_Delivery_Date) AS Delay_Days,
    ROW_NUMBER() OVER(
        PARTITION BY Warehouse_ID
        ORDER BY DATEDIFF(Actual_Delivery_Date, Expected_Delivery_Date) DESC
    ) AS Delay_Rank
FROM FLIPKART_ORDERS
LIMIT 20;
#{ Shows the most delayed orders in each warehouse.Shows the most delayed orders in each warehouse. }


## Task 3: Route Optimization Insights......

#For each route, calculate:
--  Average delivery time (in days).
--  Average traffic delay.
--  Distance-to-time efficiency ratio: Distance_KM / Average_Travel_Time_Min.
SELECT
    r.Route_ID,
    ROUND(AVG(DATEDIFF(o.Actual_Delivery_Date, o.Order_Date)),2) AS Avg_Delivery_Time_Days,
    AVG(r.Traffic_Delay_Min) AS Avg_Traffic_Delay_Min,
    ROUND(r.Distance_KM / r.Average_Travel_Time_Min,2) AS Distance_Time_Efficiency
FROM FLIPKART_ORDERS o
JOIN FLIPKART_ROUTES r
ON o.Route_ID = r.Route_ID
GROUP BY r.Route_ID,
         r.Distance_KM,
         r.Average_Travel_Time_Min,
         r.Traffic_Delay_Min;
#{ Routes with higher average delivery time are slower and may require optimization-- .
-- Routes with higher traffic delays are more prone to congestion.
-- A higher distance-to-time efficiency ratio indicates a more efficient route 
-- with better travel performance. }


# Identify 3 routes with the worst efficiency ratio.
SELECT
    Route_ID,
    ROUND(Distance_KM / Average_Travel_Time_Min, 2) AS Efficiency_Ratio
FROM FLIPKART_ROUTES
ORDER BY Efficiency_Ratio
LIMIT 3;
#{ These routes are the least efficient in the network.
-- They should be reviewed for congestion, road conditions, or route planning issues. }


# Find routes with >20% delayed shipments.
SELECT
    Route_ID,
    ROUND(
        100 * SUM(Actual_Delivery_Date > Expected_Delivery_Date)
        / COUNT(*),
        2
    ) AS Delay_Percentage
FROM FLIPKART_ORDERS
GROUP BY Route_ID
HAVING Delay_Percentage > 20;
-- #{ These routes consistently miss delivery commitments.
-- They have a significant impact on customer satisfaction and service quality.}


#  Recommend potential routes for optimization
SELECT
    o.Route_ID,
    ROUND(AVG(DATEDIFF(Actual_Delivery_Date, Expected_Delivery_Date)), 2) AS Avg_Delay,
    ROUND(r.Distance_KM / r.Average_Travel_Time_Min, 2) AS Efficiency_Ratio
FROM FLIPKART_ORDERS o
JOIN FLIPKART_ROUTES r
    ON o.Route_ID = r.Route_ID
GROUP BY
    o.Route_ID,
    r.Distance_KM,
    r.Average_Travel_Time_Min
ORDER BY
    Avg_Delay DESC,
    Efficiency_Ratio ASC;
-- #{ Routes with high average delays and low efficiency ratios should be prioritized for optimization.
-- Improving these routes can reduce delivery time
-- lower operational costs, and enhance customer satisfaction. }


## Task 4: Warehouse Performance ........

# Find the top 3 warehouses with the highest average processing time.
SELECT
    Warehouse_ID,
    Warehouse_Name,
    Average_Processing_Time_Min
FROM FLIPKART_WAREHOUSES
ORDER BY Average_Processing_Time_Min DESC
LIMIT 3;
-- #{ These warehouses take the longest time to process orders.
-- They may require process improvements or additional resources. }


# Calculate total vs. delayed shipments for each warehouse.
SELECT
    Warehouse_ID,
    COUNT(*) AS Total_Shipments,
    SUM(Actual_Delivery_Date > Expected_Delivery_Date) AS Delayed_Shipments
FROM FLIPKART_ORDERS
GROUP BY Warehouse_ID;
-- #{ Helps compare shipment volume and delay performance for each warehouse.
-- Warehouses with high delayed shipments need operational attention. }


# Use CTEs to find bottleneck warehouses where processing time > global average.
WITH Avg_Time AS (
    SELECT AVG(Average_Processing_Time_Min) AS Global_Avg
    FROM FLIPKART_WAREHOUSES
)
SELECT
    Warehouse_ID,
    Warehouse_Name,
    Average_Processing_Time_Min,
    Global_Avg
FROM FLIPKART_WAREHOUSES, Avg_Time
WHERE Average_Processing_Time_Min > Global_Avg;
-- #{ These warehouses are potential bottlenecks.
-- They slow down order fulfillment and should be prioritized for optimization. }



# Rank warehouses based on on-time delivery percentage.
SELECT
    Warehouse_ID,
    ROUND(
        100 * SUM(Actual_Delivery_Date <= Expected_Delivery_Date)
        / COUNT(*), 2
    ) AS On_Time_Percentage,

    RANK() OVER(
        ORDER BY
        ROUND(
            100 * SUM(Actual_Delivery_Date <= Expected_Delivery_Date)
            / COUNT(*), 2
        ) DESC
    ) AS Warehouse_Rank

FROM FLIPKART_ORDERS
GROUP BY Warehouse_ID;
-- #{ Rank 1 warehouse has the best delivery performance.
-- Warehouses with lower ranks should focus on reducing delivery delays.


## Task 5: Delivery Agent Performance ......

# Rank agents (per route) by on-time delivery percentage
SELECT
    Agent_ID,
    Agent_Name,
    Route_ID,
    On_Time_Delivery_Percentage,
    RANK() OVER(
        PARTITION BY Route_ID
        ORDER BY On_Time_Delivery_Percentage DESC
    ) AS Agent_Rank
FROM FLIPKART_DELIVERYAGENTS;  
#{ Identifies the best-performing agent on each route.
-- Helps recognize top performers and benchmark agent performance. }


# Find agents with on-time % < 80%
SELECT
    Agent_ID,
    Agent_Name,
    Route_ID,
    On_Time_Delivery_Percentage
FROM FLIPKART_DELIVERYAGENTS
WHERE On_Time_Delivery_Percentage < 80;
#{ These agents have below-target delivery performance.
-- They may require additional training or workload review.}


# Compare average speed of top 5 vs bottom 5 agents using subqueries.
SELECT
    'Top 5 Agents' AS Category,
    AVG(Avg_Speed_KMPH) AS Avg_Speed
FROM
(
    SELECT Avg_Speed_KMPH
    FROM FLIPKART_DELIVERYAGENTS
    ORDER BY On_Time_Delivery_Percentage DESC
    LIMIT 5
) t

UNION ALL

SELECT
    'Bottom 5 Agents',
    AVG(Avg_Speed_KMPH)
FROM
(
    SELECT Avg_Speed_KMPH
    FROM FLIPKART_DELIVERYAGENTS
    ORDER BY On_Time_Delivery_Percentage ASC
    LIMIT 5
) b;
#{ Helps determine whether delivery speed influences on-time performance.
-- Significant differences may indicate efficiency gaps among agents.


# Suggest training or workload balancing strategies for low performers
-- Conclusion / Recommendation
-- Provide route-planning and time-management training to agents with on-time delivery below 80%.
-- Assign experienced agents to support low-performing routes.
-- Balance workloads by redistributing orders among agents.
-- Monitor agent performance regularly and reward high performers.
-- Review route complexity and traffic conditions before evaluating agent performance.



## Task 6: Shipment Tracking Analytics .....

# For each order, list the last checkpoint and time.
SELECT
    Order_ID,
    Checkpoint,
    Checkpoint_Time
FROM FLIPKART_SHIPMENTTRACKING
WHERE (Order_ID, Checkpoint_Time) IN
(
    SELECT
        Order_ID,
        MAX(Checkpoint_Time)
    FROM FLIPKART_SHIPMENTTRACKING
    GROUP BY Order_ID
);
#{ Shows the most recent shipment status for every order.
-- Helps track the current shipment location. }


# Find the most common delay reasons (excluding None)
SELECT
    Delay_Reason,
    COUNT(*) AS Total_Occurrences
FROM FLIPKART_SHIPMENTTRACKING
WHERE Delay_Reason <> 'None'
GROUP BY Delay_Reason
ORDER BY Total_Occurrences DESC;
#{ Identifies the most frequent causes of shipment delays.
-- Helps prioritize operational improvements. }


# Identify orders with >2 delayed checkpoints
SELECT
    Order_ID,
    COUNT(*) AS Delayed_Checkpoints
FROM FLIPKART_SHIPMENTTRACKING
WHERE Delay_Minutes > 0
GROUP BY Order_ID
HAVING COUNT(*) > 2;
#{ These orders faced repeated disruptions during transit.
-- Such shipments should be investigated to identify recurring logistics issues. }


## Task 7: Advanced KPI Reporting...

-- Calculate KPIs using SQL queries:
-- Average Delivery Delay per Region (Start_Location).
-- On-Time Delivery % = (Total On-Time Deliveries / Total Deliveries) * 100.
-- Average Traffic Delay per Route.

#Average Delivery Delay per Region (Start_Location)
SELECT
    r.Start_Location,
    ROUND(
        AVG(DATEDIFF(o.Actual_Delivery_Date, o.Expected_Delivery_Date)),
        2
    ) AS Avg_Delivery_Delay_Days
FROM FLIPKART_ORDERS o
JOIN FLIPKART_ROUTES r
    ON o.Route_ID = r.Route_ID
GROUP BY r.Start_Location
ORDER BY Avg_Delivery_Delay_Days DESC;

#On-Time Delivery Percentage
SELECT
    ROUND(
        100 * SUM(Actual_Delivery_Date <= Expected_Delivery_Date)
        / COUNT(*),
        2
    ) AS On_Time_Delivery_Percentage
FROM FLIPKART_ORDERS; 

#Average Traffic Delay per Route
SELECT
    Route_ID,
    AVG(Traffic_Delay_Min) AS Avg_Traffic_Delay_Min
FROM FLIPKART_ROUTES
GROUP BY Route_ID
ORDER BY Avg_Traffic_Delay_Min DESC;





