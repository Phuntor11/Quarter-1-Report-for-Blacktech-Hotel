--- joining Room and Request tables 
SELECT 
R.id as Room_Id,
R.Price_day,
R.Capacity,
R.type as Room_Type,
R.Prefix,
Rq.request_id,
Rq.client_name,
Rq.request_type,
Rq.start_date,
Rq.end_date,
Rq.adults,
Rq.children
FROM Rooms R 
JOIN Requests Rq 
ON R.type = Rq.room_type

-- joining request and bookings
SELECT 
Rq.request_id,
Rq.client_name,
Rq.request_type,
Rq.start_date,
Rq.end_date,
Rq.adults,
Rq.children,
B.Id as Bookings_Id,
B.Room as Booking_Room,
B.Start_date,
B.End_date,
B.Request_Id
FROM Requests Rq 
JOIN Bookings B
ON Rq.Request_Id = B.Request_Id
ORDER BY Request_type


--joining bookings and food order
SELECT 
B.Id as Bookings_Id,
B.Room as Booking_Room,
B.Start_date,
B.End_date,
B.Request_Id,
F.dest_room as Destination_Room,
F.bill_room,
F.Date as Food_Order_Date,
F.Time as Food_Order_Time,
F.orders as No_Orders,
F.Menu_Id as Food_Menu
FROM Bookings B
JOIN Food_orders F
ON B.Room = F.Bill_Room

--joining food order and menu
SELECT
F.dest_room as Destination_Room,
F.bill_room,
F.Date as Food_Order_Date,
F.Time as Food_Order_Time,
F.orders as No_Orders,
F.Menu_Id as Food_Menu,
M.Id as Menu_Id,
M.Name as Menu_Name,
M.Price as Menu_Price,
M.Category as Menu_Category
FROM Food_Orders F
JOIN Menu M
ON F.Menu_Id = M.Id
ORDER BY M.Category; 


--Joining all five tables
SELECT 
R.id as Room_Id,
R.Price_day,
R.Capacity,
R.type as Room_Type,
R.Prefix,
Rq.request_id,
Rq.client_name,
Rq.request_type,
Rq.start_date,  
Rq.end_date,
Rq.adults,
Rq.children,
B.id AS Bookings_id,
B.Room AS Booking_Room,
B.Start_date,
B.End_date
FROM Rooms R 
LEFT JOIN Requests Rq ON R.type = Rq.room_type
LEFT JOIN Bookings B ON Rq.Request_Id = B.Request_Id
LEFT JOIN Food_orders F ON B.Room = F.Bill_Room
LEFT JOIN Menu M ON F.Menu_Id = M.Id 


--to view total requests
SELECT COUNT(*) FROM Requests

---To view total number of bookings  
SELECT COUNT(*) FROM Bookings;
SELECT COUNT(DISTINCT request_id) FROM Bookings;

SELECT COUNT(DISTINCT request_id) FROM Requests;

SELECT * FROM Bookings
WHERE request_id = 75;


(SELECT DATEDIFF(day,start_date, end_date) AS DateDiff FROM Requests)

SELECT * FROM Food_Orders
WHERE bill_room = 'L0';

---### Getting list of all Large Conference room requests
SELECT COUNT (*) FROM Bookings B
JOIN Requests R ON B.request_id = R.request_id
WHERE B.room LIKE 'L%';

---###List of all orders taken in the resturant (Dine-in)
CREATE VIEW Dine_In AS
SELECT * FROM Bookings B
JOIN Food_Orders F
ON B.room = F.bill_room
WHERE dest_room = 'restaurant';

SELECT COUNT (*) FROM Bookings B
JOIN Food_Orders F
ON B.room = F.bill_room
WHERE dest_room = 'restaurant';

---### List of all orders delivered to rooms (Take-out)
CREATE VIEW Take_Out AS
SELECT * FROM Bookings B
JOIN Food_Orders F
ON B.room = F.bill_room
WHERE dest_room != 'room';

SELECT COUNT(*) FROM Bookings B
JOIN Food_Orders F
ON B.room = F.bill_room
WHERE dest_room != 'restaurant';

SELECT * FROM [Rooms ]

-- doing a check on totoal children and total adults
SELECT start_date, SUM(adults) FROM [Requests ]
GROUP BY start_date
SELECT start_date, SUM(children) FROM [Requests ]
GROUP BY start_date

-- total number of adults and children
SELECT start_date, SUM(adults) FROM 
(SELECT start_date, adults FROM Requests
UNION ALL 
SELECT start_date, children FROM Requests) AS PERSONS
GROUP BY start_date

-- total number of persons

SELECT SUM(adults) FROM 
(SELECT adults FROM Requests
UNION ALL 
SELECT children FROM Requests) AS PERSONS

-- total number of guests lodged in the hotel for a certain period
CREATE VIEW Total_Guest AS
SELECT SUM (adults) AS Total_Guest FROM 
(SELECT adults FROM Requests
UNION ALL
SELECT children FROM Requests) AS PERSONS


-- menu order table, without room bookings
SELECT
F.dest_room as Destination_Room,
F.bill_room,
F.Date as Food_Order_Date,
F.Time as Food_Order_Time,
F.orders as No_Orders,
F.Menu_Id as Food_Menu,
M.Id as Menu_Id,
M.Name as Menu_Name,
M.Price as Menu_Price,
M.Category as Menu_Category,
M.price * F.orders AS Food_Cost
FROM Food_Orders F
JOIN Menu M
ON F.Menu_Id = M.Id
ORDER BY F.orders; 

SELECT * FROM [Requests ]
WHERE request_id = 4485

SELECT * FROM [Bookings ]
WHERE request_id = 4485

-- Booking request table
SELECT DISTINCT
        sub.Booking_id,
        sub.request_id,
        sub.Room_id,
        sub.Room_Number,
        sub.Room_Prefix,
        sub.Room_Type,
        sub.request_type,
        sub.client_Name,
        sub.capacity,
        sub.Start_Date,
        sub.End_Date,
        sub.Occupants/IIF(sub.No_Bookings <> 0, sub.No_Bookings,1) AS Occupants,
        sub.Days  * sub.Room_Rate AS Hotel_Cost
-- INTO Booking_Request_Room
FROM (SELECT  bk.id AS Booking_ID,
            bk.Request_ID,
            rm.id AS Room_id,
            bk.room AS Room_Number,
            rm.capacity,
            rq.Adults + rq.Children AS Occupants,
            (SELECT count(b.id)
            FROM bookings b
            WHERE rq.request_ID = b.request_ID) AS No_Bookings,
            rm.[type] AS Room_Type,
            rm.prefix AS Room_Prefix,           
            rm.Price_Day AS Room_Rate,
            DATEDIFF(DAY,rq.start_date,rq.end_date) AS Days,
            rq.start_date,
            rq.end_date,
            rq.client_name,
            rq.request_type
        --     SUM(rm.capacity) OVER (Partition by bk.request_id) AS Capacity,
    FROM bookings AS bk
    LEFT JOIN rooms AS rm
    ON rm.prefix = SUBSTRING(bk.room,1,1)
    LEFT JOIN requests AS rq 
    ON bk.request_id = rq.request_id) AS sub




/*          Request/Booking           */
SELECT    
       Bk.id AS Booking_ID,
       Rq.Request_ID,
       Rq.request_type,
       Bk.Room,
       Substring(Bk.Room,1,1) AS Room_Prefix,
       Rq.room_type,
       Rq.Start_Date,
       Rq.End_Date,
       Rq.Adults + Rq.Children AS Occupants
-- INTO Request_Booking
FROM Requests Rq 
LEFT JOIN Bookings Bk 
ON Rq.Request_ID = Bk.Request_ID


SELECT 
        mn.id AS Menu_ID,
        mn.Category,
        mn.name AS Menu_Name,
        fo.bill_room AS Room,
        Rm.[type] AS Room_Type,
        SUBSTRING(fo.bill_room,1,1) AS Room_Prefix,
        fo.dest_room AS Destination,
        fo.Orders,
        mn.price * fo.orders AS Food_Cost,
        fo.[Date],
        fo.[Time]
-- INTO Food_Order_Menu
FROM food_orders AS fo
LEFT JOIN menu AS mn
ON fo.menu_id = mn.id
LEFT JOIN rooms AS Rm 
ON SUBSTRING(fo.bill_room,1,1) = Rm.prefix


SELECT COUNT(*) 
FROM [Requests ]
WHERE [Bookings ] <>

SELECT COUNT(*)
FROM [Bookings ]



--- number of clients who requested but did not book
SELECT COUNT(*)
FROM [Requests ] AS rq
LEFT JOIN [Bookings ] as b
ON rq.request_id = b.request_id
LEFT JOIN Rooms as R
ON r.type = rq.room_type
WHERE B.id is NULL



SELECT *
FROM [Requests ] AS rq
LEFT JOIN [Bookings ] as b
ON rq.request_id = b.request_id
LEFT JOIN Rooms as R
ON r.type = rq.room_type




SELECT SUM(price_day) as Price_per_day
FROM [Requests ] AS rq
LEFT JOIN [Bookings ] as b
ON rq.request_id = b.request_id
LEFT JOIN Rooms as R
ON r.type = rq.room_type
WHERE B.id is NULL



--- to find out loyal clients
SELECT rq.client_name, 
COUNT (b.id),
RANK () OVER (ORDER BY COUNT(b.id) DESC) 
FROM [Requests ] as rq
LEFT JOIN [Bookings ] as b
ON rq.request_id = b.request_id
GROUP BY rq.client_name




WITH s AS (
    SELECT r.request_id,
            r.client_name,
            r.room_type,
            r.request_type,
            r.start_date,
            r.end_date,
            r.Adults + r.children AS Occupants,
            rm.id,
            rm.price_day,
            rm.capacity,
            rm.[type],
            rm.prefix,
            IIF(CEILING((r.Adults + r.children)/rm.capacity) = 0, 1,CEILING((r.Adults + r.children)/rm.capacity)) AS No_Potential_Bookings
    FROM requests r
    LEFT JOIN bookings b
    ON r.request_id = b.request_id
    LEFT JOIN rooms rm
    ON r.room_type = rm.[type]
    WHERE b.id IS NULL
) -- CTE

-- Amount lost on unbooked requests: Run line 1 - 37 together
SELECT request_id, 
       Client_name,
       room_type,
       Occupants,
       capacity,
       No_Potential_Bookings,
       price_day, 
       No_Potential_Bookings * price_day AS Revenue_Lost,
       (SELECT SUM(No_Potential_Bookings * price_day) FROM s) AS [Total Revenue Lost]
       -- (SELECT SUM(No_Potential_Bookings * price_day) OVER(PARTITION BY room_type) FROM s) 
FROM s
ORDER BY room_type


-- Revenue Lost Per Room Type
SELECT DISTINCT
       room_type,
       SUM(No_Potential_Bookings * price_day) OVER(PARTITION BY room_type) AS Revenue_Lost
FROM 
    (SELECT r.request_id,
            r.client_name,
            r.room_type,
            r.request_type,
            r.start_date,
            r.end_date,
            r.Adults + r.children AS Occupants,
            rm.id,
            rm.price_day,
            rm.capacity,
            rm.[type],
            rm.prefix,
            IIF(CEILING((r.Adults + r.children)/rm.capacity) = 0, 1,CEILING((r.Adults + r.children)/rm.capacity)) AS No_Potential_Bookings
    FROM requests r
    LEFT JOIN bookings b
    ON r.request_id = b.request_id
    LEFT JOIN rooms rm
    ON r.room_type = rm.[type]
    WHERE b.id IS NULL) AS s;

-- -- END

-- /*            Observation          */
-- -- The normal room lost the highest amount of revenue
-- -- This is could be due to the limited capacity of the rooms and...
-- --...the fact that customers would have had to book multiple rooms to meet the capacity requirement (as in No_Potential_Bookings)


-- Multiple Bookings
SELECT rq.client_name,
       count(b.id) as [Number of bookings],
       RANK() OVER(ORDER BY count(b.id) DESC) AS [Ranking]
FROM requests Rq
LEFT JOIN bookings B
ON rq.request_id = b.request_id
GROUP BY rq.client_name

-- -- Frequent Requests
SELECT rq.client_name,
       count(rq.request_id) as [Number of requests],
       RANK() OVER(ORDER BY count(rq.request_id) DESC) AS [Ranking]
FROM requests Rq
GROUP BY rq.client_name

/*            Suggestion          */
-- Discounts for frequent customers
-- Points accummulated could be spent in the restaurant


