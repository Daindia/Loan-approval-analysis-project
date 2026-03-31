
SELECT *
FROM loan_approval_staging2;

SELECT MAX(income_annum)
FROM loan_approval_staging2;

-- Max, Min, & Range
SELECT MAX(income_annum) AS Highest_assets_value,
MIN(income_annum) AS Lowest_assets_value,
MAX(income_annum) - MIN(income_annum) AS `Range`
FROM loan_approval_staging2;

-- Mode
SELECT income_annum, COUNT(income_annum) AS `Mode`
FROM loan_approval_staging2
GROUP BY income_annum
ORDER BY `Mode` DESC
LIMIT 10;


SELECT 
    luxury_assets_value,
    COUNT(*) AS frequency
FROM loan_approval_staging2
GROUP BY luxury_assets_value
HAVING COUNT(*) >= 10  -- Show all values that appear at least 10 times
ORDER BY frequency DESC, luxury_assets_value;



-- Median, standard deviation, and Mean
WITH quartile_cte AS
(
SELECT income_annum, 
PERCENT_RANK() OVER(ORDER BY income_annum) AS quartile
FROM loan_approval_staging2
ORDER BY income_annum
)
SELECT (MIN(CASE WHEN quartile >= 0.5 THEN income_annum END)) AS Median,
       ROUND((STDDEV_SAMP(income_annum))) AS Standard_deviation,
       ROUND(AVG(income_annum)) AS `Mean`
FROM quartile_cte;

WITH quartile_cte AS
(
SELECT income_annum,
PERCENT_RANK() OVER(ORDER BY income_annum) AS quartiles
FROM loan_approval_staging2
ORDER BY income_annum
)
SELECT (MIN(CASE WHEN quartiles >= 0.25 THEN income_annum END)),
	   (MIN(CASE WHEN quartiles >= 0.5 THEN income_annum END)),
       (MIN(CASE WHEN quartiles >= 0.75 THEN income_annum END))
FROM quartile_cte;


-- Getting the Interquartile Range
WITH quartile_cte AS
(
SELECT bank_asset_value, 
PERCENT_RANK() OVER(ORDER BY bank_asset_value) AS quartile
FROM loan_approval_staging2
ORDER BY bank_asset_value
)
SELECT (MIN(CASE WHEN quartile >= 0.75 THEN bank_asset_value END)
		- MIN(CASE WHEN quartile >= 0.25 THEN bank_asset_value END))
        AS IOR
FROM quartile_cte;


-- Looking for possible outliers
WITH quartile_cte AS
(
SELECT income_annum, bank_asset_value, 
PERCENT_RANK() OVER(ORDER BY bank_asset_value) AS quartile
FROM loan_approval_staging2
)
SELECT DISTINCT bank_asset_value
FROM quartile_cte
WHERE bank_asset_value < 
	(SELECT (MIN(CASE WHEN quartile >= 0.25 THEN bank_asset_value END) - (1.5)*(4800000))
    FROM quartile_cte)
OR bank_asset_value > 
	(SELECT (MIN(CASE WHEN quartile >= 0.75 THEN bank_asset_value END) + (1.5)*(4800000))
    FROM quartile_cte);
  
-- kurtosis
SELECT ROUND((SUM(POWER(commercial_assets_value - 15126306, 4))/
	   (COUNT(*) * POWER(9103754, 4))), 2) 
       AS Kurtosis
FROM loan_approval_staging2;


-- Covariance
SELECT (SUM((residential_assets_value - 7473928)*(income_annum - 5059124)))/
	   (COUNT(*) - 1) AS covariance
FROM loan_approval_staging2;


-- Correlation 
SELECT 
    ROUND((SUM((income_annum - mean_res) * (cibil_score - mean_inc))) / 
    (STDDEV(income_annum) * STDDEV(cibil_score) * (COUNT(*) - 1)), 2) AS correlation
FROM loan_approval_staging2
CROSS JOIN (
    SELECT 
        AVG(income_annum) AS mean_res,
        AVG(cibil_score) AS mean_inc
    FROM loan_approval_staging2
) AS means;


-- Correlation without outliers
SELECT 
    ROUND((SUM((residential_assets_value - mean_res) * (income_annum - mean_inc))) / 
    (STDDEV(residential_assets_value) * STDDEV(income_annum) * (COUNT(*) - 1)), 2) AS correlation_without_outliers
FROM loan_approval_staging2
CROSS JOIN (
    SELECT 
        AVG(residential_assets_value) AS mean_res,
        AVG(income_annum) AS mean_inc
    FROM loan_approval_staging2
    WHERE commercial_assets_value < 17200000  -- Exclude outliers for mean calculation too
) AS means
WHERE commercial_assets_value < 17200000;  -- Exclude outliers from the main data

SELECT *
FROM loan_approval_staging2;

SELECT education, COUNT(education)
FROM loan_approval_staging2
GROUP BY education;

SELECT education, cibil_score
FROM loan_approval_staging2
ORDER BY cibil_score DESC
;

SELECT *
FROM loan_approval_staging2
WHERE self_employed LIKE 'yes';

SELECT 
    CASE 
        WHEN cibil_score < 550 THEN 'Poor (below 550)'
        WHEN cibil_score BETWEEN 550 AND 649 THEN 'Fair (550-649)'
        WHEN cibil_score BETWEEN 650 AND 749 THEN 'Good (650-749)'
        WHEN cibil_score BETWEEN 750 AND 799 THEN 'Very Good (750-799)'
        WHEN cibil_score >= 800 THEN 'Excellent (800+)'
    END AS cibil_range,
    COUNT(*) AS total_applicants,
    SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) AS approved_count,
    ROUND(100.0 * SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*), 2) AS approval_rate
FROM loan_approval_staging2
WHERE self_employed = 'no'
GROUP BY cibil_range
ORDER BY MIN(cibil_score);

SELECT 
    CASE 
        WHEN cibil_score < 550 THEN 'Poor (below 550)'
        WHEN cibil_score BETWEEN 550 AND 900 THEN 'Rest'
    END AS cibil_range,
    COUNT(*) AS total_applicants,
    SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) AS approved_count,
    ROUND(100.0 * SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*), 2) AS approval_rate
FROM loan_approval_staging2
GROUP BY cibil_range
ORDER BY MIN(cibil_score);

SELECT 
    CASE 
        WHEN self_employed = 'yes' THEN 'Self Employed'
        WHEN self_employed = 'no' THEN 'Not Self Employed'
        WHEN education = 'graduate' THEN 'Graduate'
        WHEN education = 'not graduate' THEN 'Not Graduate'
    END AS education,
    COUNT(*) AS total_applicants,
    SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) AS approved_count,
    ROUND(100.0 * SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(*), 2) AS approval_rate
FROM loan_approval_staging2
GROUP BY self_employed, education
ORDER BY MIN(education), MIN(self_employed);

SELECT 
	CASE 
		WHEN income_annum < 1000000 THEN '>1M'
		WHEN income_annum BETWEEN 1000000 AND 1999999 THEN '>2M'
		WHEN income_annum BETWEEN 2000000 AND 2999999 THEN '>3M'
		WHEN income_annum BETWEEN 3000000 AND 3999999 THEN '>4M'
		WHEN income_annum BETWEEN 4000000 AND 4999999 THEN '>5M'
        WHEN income_annum BETWEEN 5000000 AND 5999999 THEN '>6M'
        WHEN income_annum BETWEEN 6000000 AND 6999999 THEN '>7M'
        WHEN income_annum BETWEEN 7000000 AND 7999999 THEN '>8M'
        WHEN income_annum BETWEEN 8000000 AND 8999999 THEN '>9M'
        WHEN income_annum BETWEEN 9000000 AND 9999999 THEN '>10M'
	END AS quarters,
	COUNT(*) AS total_applicants,
	SUM(CASE WHEN loan_status = 'approved' THEN 1 ELSE 0 END) approved_count,
	ROUND(100 * SUM(CASE WHEN loan_status = 'approved' THEN 1 ELSE 0 END)/COUNT(*), 2) AS approval_percentage
FROM loan_approval_staging2
WHERE education = 'graduate'
GROUP BY quarters
ORDER BY MIN(income_annum);

 
 WITH table_cte AS
 (
 SELECT 
	CASE 
		WHEN income_annum < 1000000 THEN '>1M'
		WHEN income_annum BETWEEN 1000000 AND 1999999 THEN '>2M'
		WHEN income_annum BETWEEN 2000000 AND 2999999 THEN '>3M'
		WHEN income_annum BETWEEN 3000000 AND 3999999 THEN '>4M'
		WHEN income_annum BETWEEN 4000000 AND 4999999 THEN '>5M'
        WHEN income_annum BETWEEN 5000000 AND 5999999 THEN '>6M'
        WHEN income_annum BETWEEN 6000000 AND 6999999 THEN '>7M'
        WHEN income_annum BETWEEN 7000000 AND 7999999 THEN '>8M'
        WHEN income_annum BETWEEN 8000000 AND 8999999 THEN '>9M'
        WHEN income_annum BETWEEN 9000000 AND 9999999 THEN '>10M'
	END AS quarters,
	COUNT(*) AS total_applicants,
	SUM(CASE WHEN loan_status = 'approved' THEN 1 ELSE 0 END) approved_count,
	ROUND(100 * SUM(CASE WHEN loan_status = 'approved' THEN 1 ELSE 0 END)/COUNT(*), 2) AS approval_percentage
FROM loan_approval_staging2
WHERE self_employed = 'no'
GROUP BY quarters
ORDER BY MIN(income_annum)
 )
SELECT ROUND(
	   (SUM(approved_count)/SUM(total_applicants))*100, 2) AS Average_approval_rate
FROM table_cte;


SELECT loan_id,
((residential_assets_value + commercial_assets_value + luxury_assets_value + bank_asset_value)/4)
AS avg_asset_value,
loan_status
FROM loan_approval_staging2;

WITH assets_cte AS
(
SELECT loan_id,
((residential_assets_value + commercial_assets_value + luxury_assets_value + bank_asset_value)/4)
AS avg_asset_value,
loan_status,
cibil_score
FROM loan_approval_staging2
)
SELECT
	CASE
		WHEN avg_asset_value < 1133750 THEN 'row 1'
        WHEN avg_asset_value BETWEEN 1133750 AND 2267500 THEN 'row 2'
        WHEN avg_asset_value BETWEEN 2267501 AND 3401251 THEN 'row 3'
        WHEN avg_asset_value BETWEEN 3401252 AND 4535002 THEN 'row 4'
        WHEN avg_asset_value BETWEEN 4535003 AND 5668753 THEN 'row 5'
        WHEN avg_asset_value BETWEEN 5668754 AND 6802504 THEN 'row 6'
        WHEN avg_asset_value BETWEEN 6802505 AND 7936255 THEN 'row 7'
        WHEN avg_asset_value BETWEEN 7936255 AND 9070006 THEN 'row 8'
        WHEN avg_asset_value BETWEEN 9070007 AND 10203757 THEN 'row 9'
        WHEN avg_asset_value BETWEEN 10203758 AND 11337508 THEN 'row 10'
        WHEN avg_asset_value BETWEEN 11337509 AND 12471259 THEN 'row 11'
        WHEN avg_asset_value BETWEEN 12471260 AND 13605010 THEN 'row 12'
        WHEN avg_asset_value BETWEEN 13605011 AND 14738761 THEN 'row 13'
        WHEN avg_asset_value BETWEEN 14738762 AND 15872512 THEN 'row 14'
        WHEN avg_asset_value BETWEEN 15872513 AND 17006263 THEN 'row 15'
        WHEN avg_asset_value BETWEEN 17006264 AND 18140015 THEN 'row 16'
        WHEN avg_asset_value BETWEEN 18140016 AND 19273766 THEN 'row 17'
        WHEN avg_asset_value BETWEEN 19273767 AND 20407517 THEN 'row 18'
        WHEN avg_asset_value BETWEEN 20407518 AND 21541268 THEN 'row 19'
        WHEN avg_asset_value BETWEEN 21541269 AND 22675000 THEN 'row 20'
	END AS asset_range,
    COUNT(*) AS nr_of_applicants,
    SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) AS nr_of_approvals,
    ROUND((SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END)/COUNT(*))*100, 2) AS approval_rate
FROM assets_cte
WHERE cibil_score < 550
GROUP BY asset_range
ORDER BY MIN(avg_asset_value);

WITH assets_cte AS
(
SELECT loan_id,
((residential_assets_value + commercial_assets_value + luxury_assets_value + bank_asset_value)/4)
AS avg_asset_value,
loan_status,
education,
self_employed,
cibil_score
FROM loan_approval_staging2
)
SELECT * 
FROM assets_cte
WHERE avg_asset_value BETWEEN 20407518 AND 21541268;

SELECT MAX(loan_term) , MIN(loan_term)
FROM loan_approval_staging2
WHERE cibil_score < 550;

SELECT 
	CASE
		WHEN loan_term <= 4 THEN '< 4 yrs'
        WHEN loan_term BETWEEN 5 AND 8 THEN '5 - 8 yrs'
        WHEN loan_term BETWEEN 9 AND 12 THEN '9 - 12 yrs'
        WHEN loan_term BETWEEN 13 AND 16 THEN '13 - 16 yrs'
        WHEN loan_term BETWEEN 17 AND 20 THEN '17 - 20 yrs'
	END AS loan_terms,
	COUNT(*) AS all_applicants,
	SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END) AS nr_of_approvals,
	ROUND(100 * SUM(CASE WHEN loan_status = 'Approved' THEN 1 ELSE 0 END)/COUNT(*), 2) AS approval_rate
FROM loan_approval_staging2
WHERE cibil_score < 550
GROUP BY loan_terms
ORDER BY MIN(loan_term);
	