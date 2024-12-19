#PROJECT 1-DATA CLEANING
# TABLE WAS CREATED AS customer AND READY TO BE CLEANED
#TABLE WAS ALSO DUPLICATED FOR REFERENCE PURPOSE AND TESTING GROUND

SELECT *
FROM customer_sweepstakes ;

#CREATE TABLE customer_sweepstakes AS SELECT * FROM customer_sweepstakes_staging;
#ALTER TABLE customer_sweepstakes RENAME COLUMN ï»¿sweepstake_id TO sweepstakes_id; #THIS WAS DOONE TO RENAME FIRST COLUMN

#IDENTIFYING DUPLICATES
SELECT customer_id, count(customer_id)
FROM customer_sweepstakes
GROUP BY customer_id
HAVING count(customer_id) > 1;
#CAN ALSO USE ROW NUMBER TO IDENTIFY
SELECT *
FROM (SELECT sweepstakes_id,
ROW_NUMBER () OVER (PARTITION BY customer_id ORDER BY customer_id) AS ROW_NUM
FROM customer_sweepstakes) AS ROW_TABLE
WHERE ROW_NUM > 1
;

#REMOVING DUPLICATE
DELETE FROM customer_sweepstakes
WHERE sweepstakes_id IN 
	(SELECT sweepstakes_id
		FROM 
			(SELECT sweepstakes_id,
			ROW_NUMBER () OVER (PARTITION BY customer_id ORDER BY customer_id) AS ROW_NUM
			FROM customer_sweepstakes) AS ROW_TABLE
			WHERE ROW_NUM > 1
	)

            
 ;           


#STANDARDIZNG DATA
#CLEANING PHONE COLUMN
ALTER TABLE customer_sweepstakes RENAME COLUMN ï»¿sweepstake_id TO sweepstake_id;
SELECT *
FROM customer_sweepstakes;

SELECT PHONE, REGEXP_REPLACE (Phone, '[-+/()]','')  #THIS REPLACES OR REMOVES THE SIGNS 
FROM customer_sweepstakes;
#UPDATE TABLE
UPDATE customer_sweepstakes
SET phone = REGEXP_REPLACE (Phone, '[-+/()]','');

SELECT PHONE, concat(SUBSTRING(phone,1,3),'-', SUBSTRING(phone,4,3),'-', SUBSTRING(phone,7,4))
FROM customer_sweepstakes;

#UPDATE TABLE
UPDATE customer_sweepstakes
SET phone = concat(SUBSTRING(phone,1,3),'-', SUBSTRING(phone,4,3),'-', SUBSTRING(phone,7,4));

#BIRTH_DATE COLUMN- NOTICE BIRTH_DATE IS A TEXT AND CONCERTED TO DATE FORMAT
SELECT *
FROM customer_sweepstakes;

#DATE FORMAT ARE DIFFERENT HENCE BOTH FORMAT CHANGED TO A SINGLE DATE FORMAT AND MERGED USING IF FUNCTION
SELECT birth_date, 
IF(str_to_date(birth_date, '%m/%d/%Y') IS NOT NULL, str_to_date(birth_date, '%m/%d/%Y'), str_to_date(birth_date, '%Y/%d/%m')),
str_to_date(birth_date, '%m/%d/%Y'),
str_to_date(birth_date, '%Y/%d/%m')
FROM customer_sweepstakes;

UPDATE customer_sweepstakes #THIS DID NOT WORK
SET birth_date = IF(str_to_date(birth_date, '%m/%d/%Y') IS NOT NULL, str_to_date(birth_date, '%m/%d/%Y'), str_to_date(birth_date, '%Y/%d/%m'));

#USING A SUBSTRING TO CHANGE IDENTIFIED WRONG DATE FORMAT IN SWEEPSTAKE_ID 9 AND 11 AND MERGE 
SELECT birth_date, CONCAT(SUBSTRING(birth_date,9,2),'/', SUBSTRING(birth_date,6,2),'/', SUBSTRING(birth_date,1,4))
FROM customer_sweepstakes
;
UPDATE customer_sweepstakes
SET birth_date = CONCAT(SUBSTRING(birth_date,9,2),'/', SUBSTRING(birth_date,6,2),'/', SUBSTRING(birth_date,1,4))
WHERE sweepstake_id IN (9,11);

UPDATE customer_sweepstakes
SET birth_date = str_to_date(birth_date,'%m/%d/%Y');

SELECT *
FROM customer_sweepstakes;
#BIRTHDATE FORMATED SUCCESFULLY

#FORMATTING AGE COLUMN USING THE CASE STATEMENT
SELECT `Are you over 18?`,
CASE 
	WHEN `Are you over 18?` ='Yes' THEN 'Y'
    WHEN `Are you over 18?` ='No' THEN 'N'
    ELSE `Are you over 18?`
END 
FROM customer_sweepstakes;

 UPDATE customer_sweepstakes
 SET `Are you over 18?`= CASE 
	WHEN `Are you over 18?` ='Yes' THEN 'Y'
    WHEN `Are you over 18?` ='No' THEN 'N'
    ELSE `Are you over 18?`
END ;
#BREAKING ONE COLUMN INTO MULTIPLE COLUMN
SELECT *
FROM customer_sweepstakes;
#BREAKING THE ADDRESS COLUMN TO STREET, CITY AND STATE USING SUBSRING_INDEX
SELECT address, substring_index(address, ',', 1) AS STREET,
	substring_index(substring_index(address, ',', 2),',', -1) AS CITY,
	substring_index(address, ',', -1) AS STATE
FROM customer_sweepstakes;

#CREATING STREET, CITY, STATE COLUMNS SINCE THEY DONT EXIST IN THE ORGINAL TABLE AND CAN SPECIFY POSITION OF COLUMN
ALTER TABLE customer_sweepstakes
ADD COLUMN street VARCHAR (50) AFTER address,
ADD COLUMN city VARCHAR(50) AFTER street,
ADD COLUMN state VARCHAR(50) AFTER city
;

#UPDATING TABLE
UPDATE customer_sweepstakes
SET street = substring_index(address, ',', 1);

UPDATE customer_sweepstakes
SET city= substring_index(substring_index(address, ',', 2),',', -1);

UPDATE customer_sweepstakes
SET state=	substring_index(address, ',', -1);

#NOTICE IRREGULAR CASE IN THE STATE COLUMN, CHANGING ALL TO UPPERCASE
SELECT STATE, UPPER(STATE)
FROM customer_sweepstakes;

UPDATE customer_sweepstakes
SET state = upper(STATE);

#TRIM
SELECT STATE, TRIM(STATE)
FROM customer_sweepstakes;

UPDATE customer_sweepstakes
SET STATE= TRIM(STATE);

SELECT CITY, TRIM(CITY)
FROM customer_sweepstakes;

UPDATE customer_sweepstakes
SET CITY= TRIM(CITY);

SELECT *
FROM customer_sweepstakes;

#NULL VALUES
UPDATE customer_sweepstakes
SET phone = NULL
where phone = '--'
;


UPDATE customer_sweepstakes
SET income = NULL
where income = ''
;
    
#DOUBLE CHECKING BIRTH_DATE AND OVER 18 COLUMN
SELECT BIRTH_DATE, `Are you over 18?`
FROM customer_sweepstakes
#WHERE (year(now() - 1) - 18) > YEAR(BIRTH_DATE) #THIS RETURNED 11 ROWS INSTEAD OF 12 ROWS MEANS ONE DOES NOT MEET REQUIREMENT
#WHERE (year(now()-1) - 18) < YEAR(BIRTH_DATE)
;
UPDATE customer_sweepstakes
SET `Are you over 18?` = 'Y'
WHERE (year(now() - 1) - 18) > YEAR(BIRTH_DATE);

UPDATE customer_sweepstakes
SET `Are you over 18?` = 'N'
WHERE BIRTH_DATE = '2006-07-06';

SELECT *
FROM customer_sweepstakes;

#DELETING COLUMNS; THIS IS DONE BECAUSE THE COLUMN IS NOT RELEVANT TO OBJECTIVE SUCH AS ADDRESS AND FAVORITE COLOR
ALTER TABLE customer_sweepstakes
DROP COLUMN address;

ALTER TABLE customer_sweepstakes
DROP COLUMN  favorite_color;









