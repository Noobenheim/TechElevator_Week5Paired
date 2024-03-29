START TRANSACTION;

DROP TABLE IF EXISTS "procedure_pet_cost";
DROP TABLE IF EXISTS "visit_procedure";
DROP TABLE IF EXISTS "visit";
DROP TABLE IF EXISTS "procedure";
DROP TABLE IF EXISTS "pet";
DROP TABLE IF EXISTS "pet_type";
DROP TABLE IF EXISTS "invoice";
DROP TABLE IF EXISTS "owner";
DROP TABLE IF EXISTS "address";

CREATE TABLE "address" (
        "address_id" INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
        "street" VARCHAR(128) NOT NULL,
        "city" VARCHAR(64) NOT NULL,
        "state" VARCHAR(64) NOT NULL,
        "zip" VARCHAR(10) NOT NULL,
        "phone" VARCHAR(24),
        
        CONSTRAINT "pk_address_id" PRIMARY KEY("address_id")
);

CREATE TABLE "owner" (
        "owner_id" INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
        "prefix" VARCHAR(8) NOT NULL,
        "first_name" VARCHAR(64) NOT NULL,
        "last_name" VARCHAR(64) NOT NULL,
        "address_id" INT NOT NULL,
        
        CONSTRAINT "pk_owner_id" PRIMARY KEY("owner_id"),
        CONSTRAINT "chk_prefix" CHECK("prefix" IN('MR.', 'MRS.', 'MS.', 'DR.')),
        CONSTRAINT "fk_address_id" FOREIGN KEY("address_id") REFERENCES "address" ("address_id")
);

CREATE TABLE "invoice" (
        "invoice_id" INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
        "owner_id" INT NOT NULL,
        "invoice_name_id" INT NOT NULL,
        "invoice_date" DATE NOT NULL,
        "tax_percent" DECIMAL NOT NULL,
        
        CONSTRAINT "pk_invoice_id" PRIMARY KEY("invoice_id"),
        CONSTRAINT "fk_owner_id" FOREIGN KEY("owner_id") REFERENCES "owner" ("owner_id"),
        CONSTRAINT "fk_invoice_name_id" FOREIGN KEY("invoice_name_id") REFERENCES "owner" ("owner_id")
);

CREATE TABLE "pet_type" (
        "pet_type_id" INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
        "name" VARCHAR(32) NOT NULL,
        
        CONSTRAINT "pk_pet_type_id" PRIMARY KEY("pet_type_id")
);

CREATE TABLE "pet" (
        "pet_id" INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
        "first_name" VARCHAR(64) NOT NULL,
        "birth_date" DATE NOT NULL,
        "owner_id" INT NOT NULL,
        "pet_type_id" INT NOT NULL,
        
        CONSTRAINT "pk_pet_id" PRIMARY KEY("pet_id"),
        CONSTRAINT "fk_owner_id" FOREIGN KEY("owner_id") REFERENCES "owner" ("owner_id"),
        CONSTRAINT "fk_pet_type_id" FOREIGN KEY("pet_type_id") REFERENCES "pet_type" ("pet_type_id")
);

CREATE TABLE "procedure" (
        "procedure_id" INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
        "name" VARCHAR(64) NOT NULL,
        
        CONSTRAINT "pk_procedure_id" PRIMARY KEY("procedure_id")
);

CREATE TABLE "visit" (
        "visit_id" INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
        "pet_id" INT NOT NULL,
        "visit_date" DATE NOT NULL,
        
        CONSTRAINT "pk_visit_id" PRIMARY KEY("visit_id"),
        CONSTRAINT "fk_pet_id" FOREIGN KEY("pet_id") REFERENCES "pet" ("pet_id")
);

CREATE TABLE "visit_procedure" (
        "visit_id" INT NOT NULL,
        "procedure_id" INT NOT NULL,
        
        CONSTRAINT "pk_visit_id_procedure_id" PRIMARY KEY("visit_id", "procedure_id"),
        CONSTRAINT "fk_visit_id" FOREIGN KEY("visit_id") REFERENCES "visit" ("visit_id"),
        CONSTRAINT "fk_procedure_id" FOREIGN KEY("procedure_id") REFERENCES "procedure" ("procedure_id")
);

CREATE TABLE "procedure_pet_cost" (
        "procedure_id" INT NOT NULL,
        "pet_type_id" INT NOT NULL,
        "cost" MONEY NOT NULL,
        
        CONSTRAINT "pk_procedure_id_pet_type_id" PRIMARY KEY("procedure_id", "pet_type_id"),
        CONSTRAINT "fk_procedure_id" FOREIGN KEY("procedure_id") REFERENCES "procedure" ("procedure_id"),
        CONSTRAINT "fk_pet_type_id" FOREIGN KEY("pet_type_id") REFERENCES "pet_type" ("pet_type_id")
);

INSERT INTO "address" ("street",                "city",         "state",        "zip")
                VALUES('123 THIS STREET',       'MY CITY',      'ONTARIO',      'Z5Z-6G6'),
                      ('321 THAT ROAD',         'YOUR CITY',    'ONTARIO',      'Z5Z-6G6')
;

INSERT INTO "owner" ("prefix",  "first_name",      "last_name",    "address_id")
             VALUES ('MR.',     'SAM',             'COOK',         (SELECT "address_id" FROM "address" WHERE "street" = '123 THIS STREET')),
                    ('MR.',     'RICHARD',         'COOK',         (SELECT "address_id" FROM "address" WHERE "street" = '123 THIS STREET')),
                    ('MR.',     'TERRY',           'KIM',          (SELECT "address_id" FROM "address" WHERE "street" = '321 THAT ROAD'))
;

INSERT INTO "invoice" ("invoice_id", "owner_id",      "invoice_name_id",      "invoice_date",         "tax_percent")
                VALUES(987,
                       (SELECT "owner_id" FROM "owner" WHERE "first_name" = 'SAM'),
                       (SELECT "owner_id" FROM "owner" WHERE "first_name" = 'RICHARD'),
                       '2002-01-13', 0.08)
;

INSERT INTO "pet_type" ("name") VALUES('DOG'), ('CAT'), ('BIRD');

INSERT INTO "pet" ("pet_id", "first_name", "birth_date", "owner_id", "pet_type_id")
            VALUES(246, 'ROVER',  '2007-01-02', (SELECT "owner_id" FROM "owner" WHERE "first_name" = 'SAM'), (SELECT "pet_type_id" FROM "pet_type" WHERE "name" = 'DOG')),
                  (298, 'SPOT',   '2017-04-16', (SELECT "owner_id" FROM "owner" WHERE "first_name" = 'TERRY'), (SELECT "pet_type_id" FROM "pet_type" WHERE "name" = 'DOG')),
                  (341, 'MORRIS', '2015-08-22', (SELECT "owner_id" FROM "owner" WHERE "first_name" = 'SAM'), (SELECT "pet_type_id" FROM "pet_type" WHERE "name" = 'CAT')),
                  (519, 'TWEEDY', '2016-11-28', (SELECT "owner_id" FROM "owner" WHERE "first_name" = 'TERRY'), (SELECT "pet_type_id" FROM "pet_type" WHERE "name" = 'BIRD'))
;

INSERT INTO "procedure" ("procedure_id", "name")
                  VALUES(1, 'RABIES VACCINATION'),
                        (5, 'HEART WORM TEST'),
                        (8, 'TETANUS VACCINATION'),
                        (10,'EXAMINE and TREAT WOUND'),
                        (12,'EYE WASH'),
                        (20,'ANNUAL CHECK UP')
;

INSERT INTO "visit" ("pet_id", "visit_date")
              VALUES((SELECT "pet_id" FROM "pet" WHERE "first_name" = 'ROVER'),  '2002-01-13'),
                    ((SELECT "pet_id" FROM "pet" WHERE "first_name" = 'ROVER'),  '2002-03-27'),
                    ((SELECT "pet_id" FROM "pet" WHERE "first_name" = 'ROVER'),  '2002-04-02'),
                    ((SELECT "pet_id" FROM "pet" WHERE "first_name" = 'SPOT'),   '2002-01-21'),
                    ((SELECT "pet_id" FROM "pet" WHERE "first_name" = 'SPOT'),   '2002-03-10'),
                    ((SELECT "pet_id" FROM "pet" WHERE "first_name" = 'MORRIS'), '2001-01-23'),
                    ((SELECT "pet_id" FROM "pet" WHERE "first_name" = 'MORRIS'), '2002-01-13'),
                    ((SELECT "pet_id" FROM "pet" WHERE "first_name" = 'TWEEDY'), '2002-04-30')
;

INSERT INTO "visit_procedure" ("visit_id", "procedure_id")
                        VALUES( (SELECT "visit_id" FROM "visit" WHERE "visit_date" = '2002-01-13' AND "pet_id" = (SELECT "pet_id" FROM "pet" WHERE "first_name" = 'ROVER')),
                                (SELECT "procedure_id" FROM "procedure" WHERE "procedure_id" = 1) ),
                              ( (SELECT "visit_id" FROM "visit" WHERE "visit_date" = '2002-03-27'),
                                (SELECT "procedure_id" FROM "procedure" WHERE "procedure_id" = 10) ),
                              ( (SELECT "visit_id" FROM "visit" WHERE "visit_date" = '2002-04-02'),
                                (SELECT "procedure_id" FROM "procedure" WHERE "procedure_id" = 05) ),
                              ( (SELECT "visit_id" FROM "visit" WHERE "visit_date" = '2002-01-21'),
                                (SELECT "procedure_id" FROM "procedure" WHERE "procedure_id" = 8) ),
                              ( (SELECT "visit_id" FROM "visit" WHERE "visit_date" = '2002-03-10'),
                                (SELECT "procedure_id" FROM "procedure" WHERE "procedure_id" = 5) ),
                              ( (SELECT "visit_id" FROM "visit" WHERE "visit_date" = '2001-01-23'),
                                (SELECT "procedure_id" FROM "procedure" WHERE "procedure_id" = 1) ),
                              ( (SELECT "visit_id" FROM "visit" WHERE "visit_date" = '2002-01-13' AND "pet_id" = (SELECT "pet_id" FROM "pet" WHERE "first_name" = 'MORRIS')),
                                (SELECT "procedure_id" FROM "procedure" WHERE "procedure_id" = 1) ),
                              ( (SELECT "visit_id" FROM "visit" WHERE "visit_date" = '2002-04-30' ORDER BY "visit_id" ASC LIMIT 1),
                                (SELECT "procedure_id" FROM "procedure" WHERE "procedure_id" = 20) ),
                              ( (SELECT "visit_id" FROM "visit" WHERE "visit_date" = '2002-04-30' ORDER BY "visit_id" DESC LIMIT 1),
                                (SELECT "procedure_id" FROM "procedure" WHERE "procedure_id" = 12) )
;

INSERT INTO "procedure_pet_cost" ("procedure_id", "pet_type_id", "cost")
                           VALUES( (SELECT "procedure_id" FROM "procedure" WHERE "name" = 'RABIES VACCINATION'),
                                   (SELECT "pet_type_id" FROM "pet_type" WHERE "name" = 'DOG'),
                                   30.00 ),
                                 ( (SELECT "procedure_id" FROM "procedure" WHERE "name" = 'RABIES VACCINATION'),
                                   (SELECT "pet_type_id" FROM "pet_type" WHERE "name" = 'CAT'),
                                   24.00 )
;

COMMIT;


-- HEALTH HISTORY REPORT
SELECT "pet"."pet_id" AS "PET ID",
       "pet"."first_name" AS "PET NAME",
       "pet_type"."name" AS "PET TYPE",
       CAST(EXTRACT(YEAR FROM age("pet"."birth_date")) AS INT) AS "PET AGE",
       "owner"."first_name" || ' ' || "owner"."last_name" AS "OWNER",
       to_char("visit"."visit_date", 'Mon DD/YYYY') AS "VISIT DATE",
       lpad(CAST("procedure"."procedure_id" AS VARCHAR(16)), 2, '0') || ' - ' || "procedure"."name" AS "PROCEDURE"
FROM "pet"
JOIN "pet_type" USING("pet_type_id")
JOIN "owner" USING("owner_id")
JOIN "visit" USING("pet_id")
JOIN "visit_procedure" USING("visit_id")
JOIN "procedure" USING("procedure_id")
ORDER BY "pet"."pet_id", "visit"."visit_date"
;




-- INVOICE HEADER
SELECT "invoice"."invoice_id" AS "INVOICE #:",
      to_char("invoice_date", 'Mon DD/YYYY') AS "DATE: ",
      "owner"."prefix" || ' ' || "owner"."first_name" || ' ' || "owner"."last_name" AS "name",
      "address"."street" AS "street",
      "address"."city" || ', ' || "address"."state" AS "city/state",
      "address"."zip" AS "zipcode"
FROM "invoice"
JOIN "owner" ON "invoice"."invoice_name_id" = "owner"."owner_id"
JOIN "address" USING("address_id")
WHERE "invoice"."invoice_date" = '2002-01-13'
;

-- INVOICE BODY
SELECT "pet"."first_name" AS "PET",
       "procedure"."name" AS "PROCEDURE",
       "procedure_pet_cost"."cost" AS "AMOUNT"
FROM "pet"
JOIN "owner" USING("owner_id")
JOIN "invoice" USING("owner_id")
JOIN "visit" ON "visit"."pet_id" = "pet"."pet_id" AND "visit"."visit_date" = "invoice"."invoice_date"
JOIN "visit_procedure" USING("visit_id")
JOIN "procedure" USING("procedure_id")
JOIN "pet_type" USING("pet_type_id")
JOIN "procedure_pet_cost" USING("procedure_id", "pet_type_id")
WHERE "invoice"."invoice_date" = '2002-01-13'
;

-- INVOICE FOOTER
SELECT SUM("procedure_pet_cost"."cost") AS "TOTAL",
       "invoice"."tax_percent" * 100 AS "TAX PERCENT",
       SUM("procedure_pet_cost"."cost") * "invoice"."tax_percent" AS "TAX",
       SUM("procedure_pet_cost"."cost") + SUM("procedure_pet_cost"."cost") * "invoice"."tax_percent" AS "AMOUNT OWED"
FROM "pet"
JOIN "owner" USING("owner_id")
JOIN "invoice" USING("owner_id")
JOIN "visit" ON "visit"."pet_id" = "pet"."pet_id" AND "visit"."visit_date" = "invoice"."invoice_date"
JOIN "visit_procedure" USING("visit_id")
JOIN "procedure" USING("procedure_id")
JOIN "pet_type" USING("pet_type_id")
JOIN "procedure_pet_cost" USING("procedure_id", "pet_type_id")
WHERE "invoice"."invoice_date" = '2002-01-13'
GROUP BY "invoice"."tax_percent"
;