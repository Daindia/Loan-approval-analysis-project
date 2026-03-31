SELECT *
FROM loan_approval_staging2;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY loan_id, no_of_dependents, education, self_employed, income_annum,
loan_term, cibil_score, residential_assets_value, commercial_assets_value,
luxury_assets_value, bank_asset_value, loan_status) AS row_num
FROM loan_approval_staging2
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

SELECT *
FROM loan_approval_staging2;

SELECT *
FROM loan_approval_staging2
WHERE residential_assets_value > 25100000;

UPDATE loan_approval_staging2
SET residential_assets_value = 100000
WHERE residential_assets_value < 0;

SELECT TRIM(loan_status), loan_status
FROM loan_approval_staging2;

UPDATE loan_approval_staging2
SET loan_status = TRIM(loan_status);

SELECT *
FROM loan_approval_staging2
WHERE loan_status = 'approved';
DESC loan_approval_staging2;