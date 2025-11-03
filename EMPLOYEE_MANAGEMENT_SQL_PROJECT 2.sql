create view department as
SELECT 
    -- EMPLOYEES table
    e.EMPLOYEE_ID,
    e.FIRST_NAME,
    e.LAST_NAME,
    e.GENDER,
    e.DOB,
    e.HIRE_DATE,
    e.DEPARTMENT_ID,
    e.JOB_TITLE,
    e.EMAIL,
    e.PHONE_NUMBER,
    e.ADDRESS,
    e.CREATED_DATE AS EMPLOYEE_CREATED_DATE,
    e.CREATED_TIME AS EMPLOYEE_CREATED_TIME,

    -- DEPARTMENTS table
    d.DEPARTMENT_ID AS DEPT_ID,
    d.DEPARTMENT_NAME,
    d.MANAGER_ID,
    d.CREATED_DATE AS DEPT_CREATED_DATE,
    d.CREATED_TIME AS DEPT_CREATED_TIME,

    -- ATTENDANCE table
    a.ATTENDANCE_ID,
    a.EMPLOYEE_ID AS ATT_EMP_ID,
    a.DATE AS ATTENDANCE_DATE,
    a.STATUS AS ATTENDANCE_STATUS,
    a.CHECK_IN_TIME,
    a.CHECK_OUT_TIME,

    -- PERFORMANCE table
    p.PERFORMANCE_ID,
    p.EMPLOYEE_ID AS PERF_EMP_ID,
    p.REVIEW_DATE,
    p.RATING,
    p.COMENTS,

    -- PAYROLL table
    py.PAYROLL_ID,
    py.EMPLOYEE_ID AS PAY_EMP_ID,
    py.SALARY,
    py.BONUS,
    py.DEDUCTIONS,
    py.NETPAY,
    py.PAY_DATE,

    -- LEAVES table
    l.LEAVE_ID,
    l.EMPLOYEE_ID AS LEAVE_EMP_ID,
    l.START_DATE,
    l.END_DATE,
    l.LEAVE_TYPE,
    l.STATUS AS LEAVE_STATUS,
    l.REASON

FROM EMPLOYEES e
JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
JOIN ATTENDANCE a ON e.EMPLOYEE_ID = a.EMPLOYEE_ID
JOIN PERFORMANCE p ON e.EMPLOYEE_ID = p.EMPLOYEE_ID
JOIN PAYROLL py ON e.EMPLOYEE_ID = py.EMPLOYEE_ID
JOIN LEAVES l ON e.EMPLOYEE_ID = l.EMPLOYEE_ID;

--Q1.finding each employee from which department belongs too..]
select first_name , last_name , department_name , job_title , department_id
from department;

--Q2.find out from department where employee salary is high]
select DEPARTMENT_NAME , FIRST_NAME , MAX(NETPAY)
from department
GROUP BY DEPARTMENT_NAME , FIRST_NAME
ORDER BY MAX(NETPAY) DESC;

--Q3.GIVING RANKS AS PER THERE SALARY]
SELECT NETPAY , FIRST_NAME ,
DENSE_RANK() OVER(ORDER BY NETPAY DESC) AS NETPAY_RANK
FROM DEPARTMENT;

--Q4.FETCH THE DEPARTMENT HAVING HIGH RATING BASED ON THEIR PERFORMANCE]
SELECT DEPARTMENT_NAME , MAX(RATING) AS HIGH_RATING ,
RANK() OVER()
FROM DEPARTMENT
GROUP BY DEPARTMENT_NAME
ORDER BY HIGH_RATING DESC 
LIMIT 6 ; 

--Q5.UPDATING THE TIME SERIRES AND FIND OUTING THE EMPLOYEE DSCIPLINE ON WORK]
UPDATE  DEPARTMENT
SET CHECK_OUT_TIME = '15:30:00'
WHERE CHECK_OUT_TIME = '09:15:00';

UPDATE DEPARTMENT
SET CHECK_OUT_TIME = '19:00:00'
WHERE CHECK_OUT_TIME = '11:15:00';

UPDATE DEPARTMENT
SET CHECK_OUT_TIME = '13:00:00'
WHERE CHECK_OUT_TIME = '08:55:00';

UPDATE DEPARTMENT
SET CHECK_OUT_TIME = '15:00:00'
WHERE CHECK_OUT_TIME = '09:10:00';

SELECT CHECK_IN_TIME,CHECK_OUT_TIME,
LEAD(CHECK_IN_TIME) OVER(ORDER BY CHECK_IN_TIME),
LEAD(CHECK_OUT_TIME) OVER(ORDER BY CHECK_OUT_TIME)
FROM DEPARTMENT;

SELECT 
  ATTENDANCE_ID,
  EMPLOYEE_ID,
  CHECK_IN_TIME,
  CHECK_OUT_TIME,
  (CHECK_OUT_TIME - CHECK_IN_TIME) AS TIME_DIFFERENCE,
  CASE 
    WHEN (CHECK_OUT_TIME - CHECK_IN_TIME) = INTERVAL '8 hours' THEN 'IN_TIME'
    WHEN (CHECK_OUT_TIME - CHECK_IN_TIME) = INTERVAL '7 hours 30 minutes' THEN 'UNDER_TIME'
    ELSE 'OVER_TIME'
  END AS TIME_STATUS
FROM  DEPARTMENT;

--Q6.FETCHING THE HIGH PAID BONUS ON THERE COMMENTS]
SELECT coments,MAX(BONUS) 
FROM DEPARTMENT
group by  coments
order by max(bonus) desc;

--Q17.HOW MANY DAYS DID EACH EMPLOYEE FETCH TO TAKE A LEAVE]
SELECT 
LEAVE_START_DATE ,
LEAVE_END_DATE,
FIRST_NAME,
(LEAVE_START_DATE - LEAVE_END_DATE)AS TOTAL_LEAVES
FROM DEPARTMENT;

--Q8.MOSTLY ON WHICH REASON THE APPROVED AS PASSED]
SELECT leave_type
FROM DEPARTMENT
WHERE LEAVE_STATUS = 'Approved';

--i create another view for adding a column ]
create view analysis as
SELECT 
    -- EMPLOYEES table
    e.EMPLOYEE_ID,
    e.FIRST_NAME,
    e.LAST_NAME,
    e.GENDER,
    e.DOB,
    e.HIRE_DATE,
    e.DEPARTMENT_ID,
    e.JOB_TITLE,
    e.EMAIL,
    e.PHONE_NUMBER,
    e.ADDRESS,
    e.CREATED_DATE AS EMPLOYEE_CREATED_DATE,
    e.CREATED_TIME AS EMPLOYEE_CREATED_TIME,

    -- DEPARTMENTS table
    d.DEPARTMENT_ID AS DEPT_ID,
    d.DEPARTMENT_NAME,
    d.MANAGER_ID,
	d.manager_name,
    d.CREATED_DATE AS DEPT_CREATED_DATE,
    d.CREATED_TIME AS DEPT_CREATED_TIME,

    -- ATTENDANCE table
    a.ATTENDANCE_ID,
    a.EMPLOYEE_ID AS ATT_EMP_ID,
    a.DATE AS ATTENDANCE_DATE,
    a.STATUS AS ATTENDANCE_STATUS,
    a.CHECK_IN_TIME,
    a.CHECK_OUT_TIME,

    -- PERFORMANCE table
    p.PERFORMANCE_ID,
    p.EMPLOYEE_ID AS PERF_EMP_ID,
    p.REVIEW_DATE,
    p.RATING,
    p.COMENTS,

    -- PAYROLL table
    py.PAYROLL_ID,
    py.EMPLOYEE_ID AS PAY_EMP_ID,
    py.SALARY,
    py.BONUS,
    py.DEDUCTIONS,
    py.NETPAY,
    py.PAY_DATE,

    -- LEAVES table
    l.LEAVE_ID,
    l.EMPLOYEE_ID AS LEAVE_EMP_ID,
    l.START_DATE,
    l.END_DATE,
    l.LEAVE_TYPE,
    l.STATUS AS LEAVE_STATUS,
    l.REASON

FROM EMPLOYEES e
JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
JOIN ATTENDANCE a ON e.EMPLOYEE_ID = a.EMPLOYEE_ID
JOIN PERFORMANCE p ON e.EMPLOYEE_ID = p.EMPLOYEE_ID
JOIN PAYROLL py ON e.EMPLOYEE_ID = py.EMPLOYEE_ID
JOIN LEAVES l ON e.EMPLOYEE_ID = l.EMPLOYEE_ID;

CREATE OR REPLACE PROCEDURE update_manager_name(
    p_manager_name varchar(50),
    p_department_id int
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE departments
    SET manager_name = p_manager_name
    WHERE department_id = p_department_id;
END;
$$;

CALL update_manager_name('liam', 3);
CALL update_manager_name('olivia', 4);
CALL update_manager_name('noah', 5);
CALL update_manager_name('emma', 6);
CALL update_manager_name('ethan', 7);
CALL update_manager_name('ava', 8);
CALL update_manager_name('mason', 9);
CALL update_manager_name('isabella', 10);
CALL update_manager_name('logan', 11);
CALL update_manager_name('mia', 12);
CALL update_manager_name('lucas', 13);
CALL update_manager_name('amelia', 14);
CALL update_manager_name('elijah', 15);
CALL update_manager_name('harper', 16);
CALL update_manager_name('james', 17);
CALL update_manager_name('evelyn', 18);
CALL update_manager_name('alexander', 19);
CALL update_manager_name('abigail', 20);

--Q9.fetching each employees manager
select d.manager_name , de.first_name ,d.manager_id,de.employee_id
from analysis d
join analysis de
on d.employee_id = de.manager_id;

--Q10.write a query to find the second highest salary in an employee ?]
select salary , first_name , 
dense_rank() over(order by salary desc)
from analysis;

--Q11.fetch all employee whose name contain the letter 'a' exactly twice]
select first_name
from analysis
where length(lower(first_name))-length(replace(lower(first_name),'a',' '))=2;

--Q12.how to retrieve only duplicate records from a table]
SELECT 
       EMPLOYEE_ID, FIRST_NAME, LAST_NAME, GENDER, DOB, HIRE_DATE, DEPARTMENT_ID,
       JOB_TITLE, EMAIL, PHONE_NUMBER, ADDRESS, EMPLOYEE_CREATED_DATE, EMPLOYEE_CREATED_TIME,
       DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, DEPARTMENT_CREATED_DATE, DEPARTMENT_CREATED_TIME,
       ATTENDANCE_ID,  ATTENDANCE_DATE, ATTENDANCE_STATUS, CHECK_IN_TIME, CHECK_OUT_TIME,
       PERFORMANCE_ID,  REVIEW_DATE, RATING, COMENTS,
       PAYROLL_ID,SALARY, BONUS, DEDUCTIONS, NETPAY, PAY_DATE,
       LEAVE_ID,  LEAVE_START_DATE, LEAVE_END_DATE, LEAVE_TYPE, LEAVE_STATUS, LEAVE_REASON , count(*)
    FROM department
    GROUP BY 
       EMPLOYEE_ID, FIRST_NAME, LAST_NAME, GENDER, DOB, HIRE_DATE, DEPARTMENT_ID,
       JOB_TITLE, EMAIL, PHONE_NUMBER, ADDRESS, EMPLOYEE_CREATED_DATE, EMPLOYEE_CREATED_TIME,
       DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, DEPARTMENT_CREATED_DATE, DEPARTMENT_CREATED_TIME,
       ATTENDANCE_ID,  ATTENDANCE_DATE, ATTENDANCE_STATUS, CHECK_IN_TIME, CHECK_OUT_TIME,
       PERFORMANCE_ID, REVIEW_DATE, RATING, COMENTS,
       PAYROLL_ID,  SALARY, BONUS, DEDUCTIONS, NETPAY, PAY_DATE,
       LEAVE_ID,  LEAVE_START_DATE, LEAVE_END_DATE, LEAVE_TYPE, LEAVE_STATUS, LEAVE_REASON
    HAVING COUNT(*) > 1;


--Q13.FIND EMPLOYEE WHO EARN MORE THAN AVERAGE SALARY]
SELECT AVG(SALARY)
FROM ANALYSIS;
SELECT SALARY,FIRST_NAME
FROM ANALYSIS
WHERE SALARY >(SELECT AVG(SALARY)
FROM ANALYSIS);

---Q14.write the query to count how many employee share the same salary]
SELECT salary, COUNT(salary) AS employee_count
FROM analysis
GROUP BY salary
HAVING COUNT(*) > 1;









