SET SQL_SAFE_UPDATES = 0;
update circuits
set country = 'USA'
where country = 'United States';
SET SQL_SAFE_UPDATES = 1;

# Country that hosted most races
create or replace view  most_races_hosted_country as
	select c.country,count(*) as total_races from circuits c
	join races r on
	c.circuit_id = r.circuit_id
	group by country
	order by total_races desc;
    
select constructor_name as team_name, sum(points) as points from constructors
group by constructor_name
order by points desc ;

    
# Most team wins
select name, count(position) as wins from race_results r
join constructors c on
c.constructor_id = r.constructor_id and c.race_id = r.race_id
where r.position = 1
group by r.constructor_id
order by wins desc;

# Points scored by each team
with cte as 
(
select name, sum(r.points) as points_scored from race_results r
join constructors c on
c.constructor_id = r.constructor_id and c.race_id = r.race_id
group by r.constructor_id
order by points_scored desc
)
select *, dense_rank() over(order by points_scored desc) as ranking from cte;

# total points scored by driver

create or replace view driver_results as
	select r.race_id, r.driver_id,constructor_id, driver_name,dob, nationality, position,points,
	laps,laptime_milsec,fastest_lap,fastest_lap_time,fastest_lap_speed,status from race_results r
	join drivers d on 
	d.driver_id = r.driver_id;
    
select *, dense_rank() over(order by points desc) as ranking from
(select driver_name,sum(points) as points from driver_results
group by driver_id) as ranked;

# current youngest driver
SELECT distinct driver_name, dob, TIMESTAMPDIFF(YEAR, dob, CURDATE()) AS age FROM driver_results
order by age
limit 1;

# Driver and corresponding team wins
select driver_name, name as team_name, count(dr.position) as wins from driver_results dr
join constructors c on
c.constructor_id = dr.constructor_id and c.race_id = dr.race_id
where dr.position = 1
group by name,driver_name
order by wins desc;

# Fastest pitstop by each team

select name, min(milliseconds) as least_pitstop_time from
(select c.name, p.milliseconds from driver_results dr
join pit_stops p on
dr.race_id = p.race_id and dr.driver_id = p.driver_id
join constructors c on
c.race_id = dr.race_id  and c.constructor_id = dr.constructor_id) as pitstop
group by name
order by least_pitstop_time;

# nation that produced highest number of drivers
select nationality, count(distinct driver_id) as drivers_count from driver_results
group by nationality
order by drivers_count desc;

# fastest lapspeed and driver
select driver_name, max(fastest_lap_speed) from driver_results;

# races each season
select year,count(race_id) as count from races
group by year
order by count desc;

# Youngest driver to ever race
select distinct dr.driver_name,min(TIMESTAMPDIFF(year, dob, date)) AS age from circuits c
join races r on
c.circuit_id = r.circuit_id
join driver_results dr on
r.race_id = dr.race_id
group by driver_name
order by age
limit 1;

#fastest drivers 
select driver_name,count(driver_name) as total from (
select year,driver_name,min(milliseconds)as time from(
	select driver_name,milliseconds, year from lap_times l
	join driver_results dr on
	l.race_id = dr.race_id and l.driver_id = dr.driver_id
	join races r on
	r.race_id = dr.race_id
) as fast_driver
group by year,driver_name) as ff
group by driver_name
order by total desc;







