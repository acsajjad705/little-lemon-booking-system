USE little_lemon;

CREATE OR REPLACE VIEW vw_booking_overview AS
SELECT
  b.BookingID,
  b.BookingDate,
  b.BookingTime,
  b.Status,
  b.Guests,
  t.TableNumber,
  t.Capacity,
  CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
  c.Email AS CustomerEmail,
  s.StaffID,
  CONCAT(s.FirstName, ' ', s.LastName) AS StaffName,
  s.Role AS StaffRole
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN RestaurantTables t ON b.TableID = t.TableID
LEFT JOIN Staff s ON b.StaffID = s.StaffID;

CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
  o.OrderID,
  o.OrderDate,
  o.Status,
  o.Total,
  o.CustomerID,
  CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
  b.BookingID,
  b.BookingDate,
  b.BookingTime,
  t.TableNumber
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
LEFT JOIN Bookings b ON o.BookingID = b.BookingID
LEFT JOIN RestaurantTables t ON b.TableID = t.TableID;

CREATE OR REPLACE VIEW vw_menu_sales AS
SELECT
  mi.MenuItemID,
  mi.Name,
  mi.Category,
  SUM(oi.Quantity) AS TotalQty,
  SUM(oi.LineTotal) AS Revenue
FROM OrderItems oi
JOIN MenuItems mi ON oi.MenuItemID = mi.MenuItemID
GROUP BY mi.MenuItemID, mi.Name, mi.Category;
