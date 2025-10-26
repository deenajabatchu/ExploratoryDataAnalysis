Use world_layoffs;

select * from layoffs;


-- Remove Duplicates
-- Standardize the Data
-- Null values or Blank values
-- Remove any columns

-- one way - creating table for existing table
Create table layoffs_staging as select * from layoffs;
	select * from layoffs_staging;
		select count(company)
		from layoffs ;

-- another way - creating table for existing table
create table dummy like layoffs;
select * from dummy;
	Insert into dummy select * from layoffs;
		select count(company)
		from dummy ;
drop table dummy;  

-- 1.Removing Duplicates :

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

Insert into layoffs_staging2
select *,
row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;

set sql_safe_updates=0;  -- to came out of the safe mode

Delete from layoffs_staging2
where row_num>1;

set sql_safe_updates=1;    -- to enable the safe mode

select * from layoffs_staging2;

-- checking that one of the copy of the duplicate row would present or not after deleting the duplicates
select * from layoffs_staging2
where company like '%hibob';



-- Standardizing the Data


-- remove the left and right spaces in the company col

select distinct company,trim(company) from layoffs_staging2;

set sql_safe_updates=0;

update layoffs_staging2
set company = trim(company);

set sql_safe_updates=1;

select company from layoffs_staging2;

-- update the industry names which are under same company but different notation names
 
select distinct industry 
from layoffs_staging2
order by industry;

select industry from layoffs_staging2
where industry like 'crypto%';

set sql_safe_updates=0;

update layoffs_staging2
set industry ='Crypto'
where industry like 'crypto%';

set sql_safe_updates=1;

select industry from layoffs_staging2
where industry like 'crypto%';

--  everything good in location col
select location from layoffs_staging2;

-- update the country names which are same but different notation names

select country from layoffs_staging2;

set sql_safe_updates=0;

update layoffs_staging2
set company=trim(trailing '.' from country)
where company like 'United states%';

set sql_safe_updates=1;
 
select country from layoffs_staging2;

select * from layoffs_staging2;

-- convert the date from text format to date format

select date from layoffs_staging2;

set sql_safe_updates=0;

update layoffs_staging2
set `date`=str_to_date(`date`,'%m/%d/%Y');

-- still date having the text datatype need to change the text datatype

Alter table layoffs_staging2
modify column `date` date;


select date from layoffs_staging2;


-- Null and Blank values


-- checking the null values in the industry that having the duplicates 

select t1.industry,t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.industry=t2.industry
where (t1.industry is null or t1.industry='')
and t2.industry is not null;

-- updating the blank spaces with null values

update layoffs_staging2
set industry = 'null'
where industry ='';

-- updating the null values of duplicates with the correct values while joining 

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.industry=t2.industry
set t1.industry=t2.industry
where (t1.industry is null or t1.industry='')
and t2.industry is not null;  

-- checking

select * from layoffs_staging2
where industry = '' or industry is null;

-- only one value for slef joining,so null is still existing  

select * from layoffs_staging2
where company like 'Bally%';


-- checking

select * from layoffs_staging2
where (total_laid_off is null or total_laid_off='')
and percentage_laid_off is null;

-- deleting the null values which hvaing in both  total_laid_off and percentage_laid_off

Delete
from layoffs_staging2
where (total_laid_off is null or total_laid_off='')
and percentage_laid_off is null;

select * from layoffs_staging2;


-- Removing the unnecessary coulmn in the table

Alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;
  
  
  