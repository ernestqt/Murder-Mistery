/*
Link: https://mystery.knightlab.com

We start by examining the crime scene report of January 15, 2018 at SQL city.
*/

select
	*
from 
	crime_scene_report
where 
	city = 'SQL City' and date = 20180115 
	and type = 'murder'

/*
Security footage shows that there were 2 witnesses. The first witness lives at
the last house on "Northwestern Dr". The second witness, named Annabel, lives
somewhere on "Franklin Ave".

We need to find out who the witnesses really are. We try to find Annabel,
the second witness, with the 'person' table.
*/

select 
	*
from 
	person
where name like 'Annabel%' and address_street_name = 'Franklin Ave'

/*
The full name of the second witness is Annabel Miller, with id 16371, 
license 490173, ssn 318771143, and lives at 103 Franklin Ave.

Let us find the person living on the last house in "Northwestern Dr". This will be 
the first witness. 
*/

select 
	*
from 
	person
where 
	address_street_name = 'Northwestern Dr'
order by 
	address_number desc
limit 1

/*
The full name of the first witness is Morty Schapiro, with id 14887,
license 118009, ssn 111564949, and lives at 4919 Northwestern Dr. 

We can now see what each witness said in their declaration.
*/

select *
from interview
where person_id in (14887, 16371)

/*
The first witness heard a gunshot and then saw a man run out. He had a 
"Get Fit Now Gym" bag. The membership number on the bag started with "48Z".
Only gold members have those bags. The man got into a car with a plate that 
included "H42W".

The second witness saw the murder happen, and recognized the killer from the
gym when he was working out there last week on January the 9th.

Thus, let us find all the members of the gym with gold status whose id starts 
with '48Z'.
*/

select 
	*
from 
	get_fit_now_member
where 
	id like '48Z%' and membership_status = 'gold'

/*
Only two names arise. The first suspect is Joe Germuska, id 48Z7A, person_id 28819, 
and started his membership on April 3, 2016.

The second suspect is Jeremy Bowers, id 48Z55, person_id 67318, 
and started his membership on January 1, 2016.

Let us find if any of them were at the gym on January 9.
*/

select 
	*
from 
	get_fit_now_check_in
where 
	check_in_date = 20180109 
	and membership_id in ('48Z7A', '48Z55')

/*
Unfortunately, both suspects were on the given date at the gym, so we cannnot
discard any of them. Let's see if any of our suspects have a driving license. 
*/

select 
	p.id,
	p.name,
	dl.plate_number
from 
	person p left join drivers_license dl
	on p.license_id = dl.id  
where 
	name in ('Joe Germuska', 'Jeremy Bowers')

/*
We quickly notice that Joe Germuska does not have a driving license, but Jeremy Bowers does. 
Even more, his plate number is 0H42W2, containing the data 'H42W' of the car in which the killer
got after the crime. Thus, the murderer must be Jeremy Bowers.

Let us now inspect the interview of the murderer.
*/

select 
	*
from 
	interview
where 
	person_id = 67318

/*
The murderer declares that was hired by a woman with a lot of money. He doesn't know her name but knows she's around 
5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. He also knows that she attended 
the SQL Symphony Concert 3 times in December 2017.


*/

with female_description as 
(
select 
	*
from 
	drivers_license
where 
	gender = 'female'
	and 
	hair_color = 'red'
	and 
	car_make = 'Tesla'
	and
	car_model = 'Model S'
	and height between 65 and 67
),
female_suspects as
(
select
	p.name,
	p.ssn,
	i.annual_income,
  	e.event_name,
  	e.date
from 
	female_description fd left join person p
	on fd.id = p.license_id
	left join income i
	on p.ssn = i.ssn
  	left join facebook_event_checkin e
  	on p.id = e.person_id  	
)

select 
	*
from 
	female_suspects
where 
	date between 20171201 and 20171231
	and event_name = 'SQL Symphony Concert'

/*
It is then readily seen that Miranda Priestly was the only female with the given physical description that
drives a Tesla Model S and attended the SQL Symphony Concert 3 times in December 2017. Therefore, we conclude that 
Miranda Priestly is the real villain in this crime.
*/