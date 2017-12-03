spool .\FIT9132A2_output.txt;
set echo on;

-- Assignment 2
-- Student Name: Jayesh Parab 
-- Student ID: 27148572


-- Write your SQL statement below each question.



/* Q1. How many animals have been born in the wild belongs to the EQUIDAE
family. Name the output column "Number of animals" */

Select 
  count(a.animal_id) as "Number of Animals"
from 
  as2.animal a, 
  as2.species s
where 
  s.spec_genus = a.spec_genus
  and 
  s.spec_name = a.spec_name
  and 
  s.spec_family = 'EQUIDAE'
  and 
  brevent_id is null;
  
/* Q2. In a single list show all animals indicating if the animal has been
exchanged or not -
the list should show animal id, centre name, popular name, and an exchange
status message.
The list should be in animal id order within popular name order.
Your output should have the general form (sample rows only shown): */

Select 
  distinct(a.animal_id) as "Animal ID", 
  c.centre_name as "Centre Name", 
  s.spec_popular_name as "Popular Name", 
  nvl2(e.exchange_no, 'This animal has been Exchanged', 'This animal has NOT been Exchanged') as "Exchange Status"
from 
  animal a, 
  centre c, 
  species s, 
  exchange e
where 
  a.centre_id = c.centre_id
  and 
  a.spec_genus = s.spec_genus
  and 
  a.spec_name = s.spec_name
  and 
  a.animal_id = e.animal_id (+)
order by 
  s.spec_popular_name, 
  a.animal_id;

/* Q3. List the animal id, genus, species, sex and number of exchanges for
those animals which have been involved in more than the average number of exchanges per animal
(for those animals which have been exchanged).
The animal sex should be displayed as 'Male" or 'Female'.
Your output should have the general form (sample row only shown) */

select 
  a.animal_id as "Animal ID", 
  a.spec_genus as "Genus", 
  a.spec_name as "Species", 
  decode(animal_sex, 'M', 'Male', 'F', 'Female') as "Sex", 
  count(e.animal_id) as "Number of Exchanges"
from 
  as2.animal a, 
  as2.exchange e
where 
  a.animal_id = e.animal_id
group by 
  a.animal_id, 
  a.spec_genus, 
  a.spec_name, 
  a.animal_sex
having 
  count(e.animal_id) > 
  (
  select 
    avg(count(animal_id))
  from 
    as2.exchange 
  group by 
    animal_id); 
    
/* Q4 Which is the most popular centre for exchange to or from?
Your output should list the centre name and the number of times the centre is
used for an exchange from or an exchange to. The exchange from and the exchange to 
will be calculated as a single figure. For example, if a centre is involved in an exchange
as a recipient (exchange to) and in another exchange as a provider (exchange_from) then 
this centre will be counted to have 2 exchange events.
The list should be display in the order of the centre name.
Your output should have the general form (sample rows only shown): */

Select 
  c.centre_name as "Centre Name", 
  count(e.exchange_from_centre_id) as "Number of exchanges (To/From)"
from 
  as2.centre c, 
  as2.exchange e
where 
  c.centre_id = e.exchange_from_centre_id
  or 
  c.centre_id = e.exchange_to_centre_id
group by 
  c.centre_name
having 
  count(e.exchange_from_centre_id) = 
  (
  Select 
    max(count(e.exchange_from_centre_id))
  from 
    as2.centre c, 
    as2.exchange e
  where 
    c.centre_id = e.exchange_from_centre_id
    or 
    c.centre_id = e.exchange_to_centre_id
  group by 
    c.centre_name);
    
/* Q5 List the genus name and the ratio of the animal born in the wild to the
total animal of the genus. Write the ratio as a percentage, round it to one decimal point. Order the list according to the genus name.*/

select 
  spec_genus as "SPEC_GENUS", 
  to_char(round(((count(animal_id)/
    (
    select 
      count(animal_id) 
    from 
      as2.animal a 
    where 
      a.spec_genus = a1.spec_genus
    group by spec_genus
    )) * 100),1),990.9) as Percentage
from 
  as2.animal a1
where 
  brevent_id is null
group by 
  spec_genus
order by
  spec_genus;

/* Q6 List all centres that do not receive any grant. 
Order the list according to the centre name */

Select 
  centre_id as "Centre Id", 
  centre_name as "Centre Name"
from 
  as2.centre c
where 
  centre_id not in 
  (
  select 
    distinct centre_id 
  from 
    as2.grants)
order by 
  centre_name;

/* Q7 List all offsprings that have been born as a result of the breeding
program.
In the list you will list the animal id of the offspring, the animal id of the
mother, the animal id of the father and the popular name of the animal.
Order the list according to the popular name. */

Select 
  a.animal_id as "Animal ID", 
  b.brevent_mother_id as "Mother ID", 
  b.brevent_father_id as "Father ID", 
  s.spec_popular_name as "Popular Name" 
from 
  as2.animal a, 
  as2.breeding_event b, 
  as2.species s
where 
  a.brevent_id = b.brevent_id
  and 
  s.spec_genus = a.spec_genus
  and 
  s.spec_name = a.spec_name
order by 
  s.spec_popular_name;
  
/* Q8 List the centre name and the number of times the centre has been involved
in an exchange for breeding program in the last two years.
The centre involvement in the exchange can be as a recipient or a provider of
the animal exchange.
The 2 years should be counted from the current date when the query is executed.
The list should be ordered from the highest to the lowest number of exchanges. */

Select 
  c.centre_name, 
  count(e.exchange_from_centre_id) as "Number of exchanges (To/From)"
from 
  as2.centre c, 
  as2.exchange e,
  as2.exchange_type e1
where 
  (c.centre_id = e.exchange_from_centre_id or c.centre_id = e.exchange_to_centre_id)
  and 
  round(sysdate-exchange_date,0) < 730
  and 
  upper(e1.et_description) = 'BREEDING'
group by 
  centre_name
order by
  count(e.exchange_from_centre_id) desc;

set echo off;
spool off;