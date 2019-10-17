-- Write queries to return the following:
-- Make the following changes in the "world" database.

-- 1. Add Superman's hometown, Smallville, Kansas to the city table. The 
-- countrycode is 'USA', and population of 45001. (Yes, I looked it up on 
-- Wikipedia.)
Start Transaction;
Insert into city(name , countrycode, district, population)
Values ('Smalleville','USA','Kansas', 45001 );
Commit;
Rollback;
Select * From city Where name = 'Smalleville';
-- 2. Add Kryptonese to the countrylanguage table. Kryptonese is spoken by 0.0001
-- percentage of the 'USA' population.
Start Transaction;
INSERT INTO countrylanguage(countrycode, language , isofficial, percentage)
Values ('USA', 'Kryptonese' , false, 0.0001);
Commit;
Rollback;
Select * From countrylanguage Where language = 'Kryptonese';
-- 3. After heated debate, "Kryptonese" was renamed to "Krypto-babble", change 
-- the appropriate record accordingly.
Start transaction;
Update countrylanguage 
Set language = 'Krypto-babble' where language = 'Kryptonese';
Commit;
Rollback;
Select * From countrylanguage Where language = 'Krypto-babble';
-- 4. Set the US captial to Smallville, Kansas in the country table.
Select id from city where name ='Smalleville';
Start Transaction;
Update country
Set capital = 4081 where code = 'USA';
Commit;
Rollback;
Select capital from country where code = 'USA';
-- 5. Delete Smallville, Kansas from the city table. (Did it succeed? Why?)
Start transaction;
Delete From city
where name = 'Smalleville';
Commit;
Rollback;
-- wont work bescause it violates foriegn constraint key

-- 6. Return the US captial to Washington.
START TRANSACTION;
UPDATE country
SET capital = (
        SELECT id FROM city WHERE name = 'Washington'
)
WHERE code = 'USA';
COMMIT;
SELECT city.name FROM country JOIN city ON city.countrycode = country.code WHERE code = 'USA' AND capital = id;

-- 7. Delete Smallville, Kansas from the city table. (Did it succeed? Why?)
Start transaction;
Delete From city
where name = 'Smalleville';
Commit;
Rollback;
SELECT * FROM city WHERE name = 'Smallville';

-- Yes because we took the foreign key for Smallville out of the capital 

-- 8. Reverse the "is the official language" setting for all languages where the
-- country's year of independence is within the range of 1800 and 1972 
-- (exclusive). 
-- (590 rows affected)
START TRANSACTION;
UPDATE countrylanguage
SET isofficial = NOT isofficial
WHERE countrycode IN(
        SELECT code FROM country WHERE indepyear BETWEEN 1800 AND 1972
);
COMMIT;

SELECT countrylanguage.* FROM countrylanguage WHERE countrycode IN (
SELECT code FROM country WHERE indepyear BETWEEN 1800 AND 1972
);


-- 9. Convert population so it is expressed in 1,000s for all cities. (Round to
-- the nearest integer value greater than 0.)
-- (4079 rows affected)
START TRANSACTION;
UPDATE city
SET population = ROUND(population/1000);
COMMIT;


-- 10. Assuming a country's surfacearea is expressed in square miles, convert it to 
-- square meters for all countries where French is spoken by more than 20% of the 
-- population.
-- (7 rows affected)
SELECT surfacearea FROM country WHERE code IN (SELECT countrycode FROM countrylanguage WHERE language = 'French' AND percentage > 20);
START TRANSACTION;
UPDATE country
SET surfacearea = (surfacearea/0.00000038610)
WHERE code IN (
        SELECT countrycode FROM countrylanguage WHERE language = 'French' AND percentage > 20
);
COMMIT;