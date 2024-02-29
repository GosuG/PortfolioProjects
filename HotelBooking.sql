Select *
from hotel_booking$
order by Person_ID


-- First clear the data in order to analyze it easier
ALTER TABLE hotel_booking$
DROP COLUMN Person_ID

-- Creating new column for normal ID-s
ALTER TABLE hotel_booking$
Add Person_ID int identity(1,1)

-- Determine people how many car parking spaces needed for the travel in numbers:
Select required_car_parking_spaces, COUNT(required_car_parking_spaces) as Number_Of_Car_Parking_Spaces
from hotel_booking$
group by required_car_parking_spaces
order by Number_Of_Car_Parking_Spaces desc

-- Make a query of how the care is distributed in the reservations:
Select Reservation_Type, COUNT(Reservation_Type) as Reservation_Type_Counts
from hotel_booking$
group by Reservation_Type
order by Reservation_Type_Counts desc

Select Reservation_Type
, CASE When Reservation_Type = 'Undefined' THEN 'Room in House'
	ELSE Reservation_Type
	END
from hotel_booking$

-- Change column data Undefined to Room in House for more readable data:
Update hotel_booking$
SET Reservation_Type = CASE When Reservation_Type = 'Undefined' THEN 'Room in House'
	ELSE Reservation_Type
	END
from hotel_booking$

-- Change the name of a column: 
-- NEXT TIME THIS SHOULD BE THE IN THE FIRST PRIOS!
EXEC sp_rename 'hotel_booking$.meal', 'Reservation_Type', 'COLUMN';

select DISTINCT Reservation_Type
from hotel_booking$

--Make a query about destination preferences
Select country, COUNT(country) as CountriesInNumbers
from hotel_booking$
group by country
order by CountriesInNumbers desc


ALTER TABLE hotel_booking$
Add NumbersInReservationTypes Nvarchar(255);

Select *
From hotel_booking$

-- Average night stays in the hotels where people atleast sleep 1 time
SELECT ROUND(AVG(stays_in_weekend_nights), 2) AS avg_stays_in_weekend_nights_gt_0
FROM hotel_booking$
WHERE stays_in_weekend_nights > 0;

-- Calculate the percentage of the upgraded rooms
Select COUNT(Person_ID) as SumOfUpgradedRooms,
ROUND(COUNT(Person_ID) * 100.0 / (SELECT COUNT(*) FROM hotel_booking$), 2) AS Upgrade_In_Percentage
FROM hotel_booking$
WHERE reserved_room_type <> assigned_room_type

-- What is the proportion of guests with families?
Select COUNT(Person_ID) as Families,
ROUND(COUNT(Person_ID) * 100.0 / (SELECT COUNT(*) FROM hotel_booking$), 2) AS Families_In_Percentage
FROM hotel_booking$
WHERE children > 0
OR babies > 0;


-- Families with upgraded rooms with CTE ( Common Table Expression )
WITH Families_In_Number AS (
    SELECT COUNT(*) AS total_count
    FROM hotel_booking$
    WHERE children > 0 OR babies > 0
)

SELECT 
    COUNT(Person_ID) AS FamiliesWithUpgrades_In_Numbers,
    ROUND(COUNT(Person_ID) * 100.0 / (SELECT total_count FROM Families_In_Number), 2) AS FamiliesWithUpgrades_In_Percentage
FROM hotel_booking$
WHERE reserved_room_type <> assigned_room_type
    AND children > 0
    OR babies > 0;


-- Proportion of reserved room types:
Select reserved_room_type,COUNT(reserved_room_type) as NumbersInRoomTypes
from hotel_booking$
group by reserved_room_type
order by NumbersInRoomTypes desc

Select *
From hotel_booking$

-- What months should we promote more with better ads?
Select arrival_date_month, COUNT(arrival_date_month) as People_In_Months
from hotel_booking$
group by arrival_date_month
order by People_In_Months desc


































