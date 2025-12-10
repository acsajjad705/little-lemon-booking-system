USE little_lemon;

-- Customers
INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES
('Ayesha','Khan','ayesha.khan@example.com','0300-0000000'),
('Omar','Ali','omar.ali@example.com','0301-1111111'),
('Hina','Shah','hina.shah@example.com','0302-2222222');

-- Staff
INSERT INTO Staff (FirstName, LastName, Role, Email)
VALUES
('Sara','Malik','Host','sara.malik@littlelemon.pk'),
('Bilal','Raza','Server','bilal.raza@littlelemon.pk'),
('Usman','Farooq','Manager','usman.farooq@littlelemon.pk');

-- Tables
INSERT INTO RestaurantTables (TableNumber, Capacity, Location)
VALUES
(1, 2, 'Window'),
(2, 4, 'Main'),
(3, 6, 'Patio'),
(4, 8, 'Garden');

-- Menu
INSERT INTO MenuItems (Name, Category, Price)
VALUES
('Lemon Chicken','Main', 1200.00),
('Mint Lemonade','Drink', 350.00),
('Hummus','Starter', 550.00),
('Grilled Fish','Main', 1450.00),
('Cheesecake','Dessert', 800.00);

-- Demo booking
SET @id := NULL; SET @msg := '';
CALL AddBooking(1, 2, '2025-12-12', '19:00:00', 4, 'Anniversary', @id, @msg);
SELECT @id AS BookingID, @msg AS Message;

-- Another booking
CALL AddBooking(2, 3, '2025-12-12', '20:00:00', 6, 'Family dinner', @id, @msg);
SELECT @id AS BookingID, @msg AS Message;

-- Update booking time
SET @umsg := '';
CALL UpdateBooking(1, '2025-12-12', '20:00:00', 4, 'Move to 8 PM', @umsg);
SELECT @umsg AS UpdateMessage;

-- Manage status
SET @smsg := '';
CALL ManageBooking(1, 'Confirmed', @smsg);
SELECT @smsg AS StatusMessage;

-- Cancel second booking
SET @cmsg := '';
CALL CancelBooking(2, @cmsg);
SELECT @cmsg AS CancelMessage;

-- Orders and items
INSERT INTO Orders (CustomerID, BookingID, Status, Total)
VALUES (1, 1, 'Preparing', 0.00);

-- Use trigger to snapshot prices
INSERT INTO OrderItems (OrderID, MenuItemID, Quantity, UnitPrice, LineTotal)
VALUES
(LAST_INSERT_ID(), 1, 2, 0, 0),
(LAST_INSERT_ID(), 2, 4, 0, 0),
(LAST_INSERT_ID(), 5, 1, 0, 0);

-- Max quantity
SET @max := 0;
CALL GetMaxQuantity(@max);
SELECT @max AS MaxQuantity;
