select * from census.dataset1;
select * from census.dataset2;

-- Number of rows into our dataset

select count(*) from census.dataset1;
select count(*) from census.dataset2;

-- Dataset for Andhra Pradesh and Karnataka

select * from census.dataset1 where State in ('Andhra Pradesh', 'Karnataka');

-- Population of India
-- Update query to update population column

update census.dataset2 
set Population = replace(Population, ',', '') 
where Population like '%,%';

select sum(Population) as Population from census.dataset2;

-- Avg population growth

select state,avg(growth) as Avg_pop_growth 
from census.dataset1 
group by state;

-- Avg sex ratio

select state,round(avg(Sex_Ratio),2)  as Avg_sex_ratio 
from census.dataset1 
group by state 
order by Avg_sex_ratio desc;

-- Average Literacy rate

select state,round(avg(Literacy),2)  as avg_literacy 
	from census.dataset1 
    group by state 
    having avg_literacy >90
    order by avg_literacy desc;
    
-- Top 3 highest growth ratio states

select state,avg(growth)  as Avg_pop_growth 
from census.dataset1 
group by state 
order by Avg_pop_growth desc 
limit 3;

-- Bottom 3 sates showing lowest sex ratio

select state,round(avg(Sex_Ratio),2)  as Avg_sex_ratio 
from census.dataset1 
group by state 
order by Avg_sex_ratio asc limit 3;

-- Top and bottom 3 states in literacy rate

drop table if exists top_lit_states;
create table top_lit_states
( state char(255),
  lit_rate float

  );

insert into top_lit_states
select state,round(avg(literacy),2) avg_literacy_ratio 
from census.dataset1
group by state 
order by avg_literacy_ratio 
desc;

select * from top_lit_states 
order by top_lit_states.lit_rate 
desc limit 3;

drop table if exists bottom_lit_states;
create table bottom_lit_states
( state char(255),
  lit_rate float

  );

insert into bottom_lit_states
select state,round(avg(literacy),2) avg_literacy_ratio
from census.dataset1 
group by state 
order by avg_literacy_ratio 
desc;

select * from bottom_lit_states 
order by bottom_lit_states.lit_rate 
asc limit 3;

-- Union Operator

select * from 
(select * from top_lit_states 
order by top_lit_states.lit_rate 
desc limit 3 ) as top_list 
union 
select * from
(select * from bottom_lit_states 
order by bottom_lit_states.lit_rate 
asc limit 3) as bottom_list;

-- States starting with letter a

select distinct(state) from census.dataset1 where lower(state) like 'a%' or lower(state) like 'k%';

-- Joining two tables

-- Total males and females

select d.state,sum(d.males) total_males,sum(d.females) as total_females
from (select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as females 
from (select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from census.dataset1 a inner join census.dataset2 b on a.district=b.district) as c) as d
group by d.state;

-- Window functions
-- Output top 3 districts from each state with highest literacy rate

select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from census.dataset1) a

where a.rnk<=3  order by state