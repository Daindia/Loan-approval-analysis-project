# Loan-approval-analysis-project

### Table of contents

1. [Project Overview](#project-overview)
2. [Data Sources](#data-sources)
3. [Tools](#tools)
4. [Data Cleaning](#data-cleaning)
5. [Understand the data](#understanding-the-data)
6. [Data Analysis](#data-analysis)
7. [Findings](#findings)
8. [Limitations](#limitations)
9. [References](#references)

### Project Overview

This data analysis project aims to try to understand how much of an influence education and self-employment status have on loan approval rates. We investigate the categories of both education and self-employment to compare their loan approval rates in order to uncover any bias. We are controlling for both CIBIL score and annual income.

### Data Sources

'loan_approval_dataset.csv' sourced from Kaggle.com

### Tools

- MySQL(Data Cleaning, EDA and Descriptive analysis)
- Tableau (EDA and Dashboarding)
- Microsoft PowerPoint (Insight presentation)
- Microsoft Word (Executive Summary preparation)

### Data Cleaning

The cleaning phase included the following:
1. Loading data into MySQL and inspection
2. Trimming the string values and correcting negative values
3. Categorizing columns as either a dimension or a measure

### Understanding the data

The exploratory data analysis phase included the following:
1. Calculating range, mean, mode and median for measure
2. Studied the distribution of each measure using the mean, mode, median method and a histogram
3. Studied the correlation of measures to see how they relate with each other
4. Calculated the interquartile range and Kurtosis to look for statistical outliers

### Data analysis

> Getting the overall approval rates of both categories of education and self-employed
```slq
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
```

> The distribution of approval rate by loan terms for applicants with CIBIL scores lower than 550
```slq
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
```

### Findings

- After controlling for CIBIL score and income, approval rates were nearly identical across groups: graduates (62.45%) vs. non-graduates (61.98%), and self-employed (62.23%) vs. non-self-employed (62.20%). These marginal differences indicate no meaningful bias in loan approvals based on education or employment status.
- Further analysis indicated that applicants with a CIBIL score of less than 550 (about 42% of applicants) have shown a loan approval rate of only 10.36%. While applicants with a higher CIBIL score have shown an above-average (more than 50%) loan approval rate. This simply tells us that creditworthiness is a much better predictor of loan approvals than education and employment status.
- Among applicants with low CIBIL scores (under 550), short-term loans (≤4 years) had a 52.41% approval rate. Longer-term loans received zero approvals.

### Limitations

- The database didn't include the loan amounts. Because of that we can't fully evaluate how much loan amounts affect approval rates, especially for applicants with low CIBIL scores.
- Education has only 'graduate' and 'not graduate'; because of this, we cannot drill down to see approval rates based on education levels.

### References

- CTE IN SQL by GeeksforGeeks.com

