use world_layoffs;

select * from layoffs_staging2;


-- Exploratory Data Analysis

select max(total_laid_off),max(percentage_laid_off) 
from layoffs_staging2;

-- max(percentage_laid_off) = 1,so checking how many companies having the max(percentage_laid_off) 

select * from layoffs_staging2
where percentage_laid_off =1;

select company,percentage_laid_off from layoffs_staging2
where percentage_laid_off =1;

select company,sum(total_laid_off)
from layoffs_staging2
group by company
order by sum(total_laid_off) desc;

select company,sum(percentage_laid_off)
from layoffs_staging2
group by company
order by sum(percentage_laid_off) desc;

select industry,sum(total_laid_off)
from layoffs_staging2
group by industry
order by sum(total_laid_off) desc;

select `date`,sum(total_laid_off)
from layoffs_staging2
group by `date`
order by sum(total_laid_off) desc;

select `date`,sum(total_laid_off)
from layoffs_staging2
group by `date`
order by  `date` desc;

select substring(`date`,6,2),sum(total_laid_off)
from layoffs_staging2
group by substring(`date`,6,2)
order by  1 desc;

select substring(`date`,1,7),sum(total_laid_off)
from layoffs_staging2
group by substring(`date`,1,7)
order by  1 desc;

-- rolling total

with rolling_total as
(
select substr(`date`,1,7) as `Month`,sum(total_laid_off) as total_off
from layoffs_staging2
where substr(`date`,1,7) is not null
group by `Month`
order by 1 asc
)
select `Month`,total_off,sum(total_off) over(order by `Month`)
from rolling_total;

-- Ranking 

with Company_Year(company,years,total_laid_off) as
(
	select company,year(`date`),sum(total_laid_off)
    from layoffs_staging2
    group by company,year(`date`)
) ,Company_Year_Rank as
(
select *,
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from Company_Year
where years is not null
order by ranking asc
)
select * from Company_Year_Rank;

-- selecting top 5 ranking companies having the massive layoffs according to years

with Company_Year(company,years,total_laid_off) as
(
	select company,year(`date`),sum(total_laid_off)
    from layoffs_staging2
    group by company,year(`date`)
) ,Company_Year_Rank as
(
select *,
dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from Company_Year
where years is not null
)
select * 
from Company_Year_Rank
where Ranking<=5;

















