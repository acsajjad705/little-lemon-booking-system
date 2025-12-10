USE little_lemon;

-- Snapshot UnitPrice and LineTotal on OrderItems insert
DELIMITER //
CREATE TRIGGER trg_orderitems_before_insert
BEFORE INSERT ON OrderItems
FOR EACH ROW
BEGIN
  DECLARE vPrice DECIMAL(8,2);
  SELECT Price INTO vPrice FROM MenuItems WHERE MenuItemID = NEW.MenuItemID;
  IF vPrice IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MenuItem not found for OrderItems insert';
  END IF;
  SET NEW.UnitPrice = vPrice;
  SET NEW.LineTotal = NEW.Quantity * vPrice;
END //
DELIMITER ;

-- Keep Orders.Total in sync after OrderItems changes
DELIMITER //
CREATE TRIGGER trg_orderitems_after_insert
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
  UPDATE Orders o
  SET o.Total = (SELECT IFNULL(SUM(LineTotal),0) FROM OrderItems WHERE OrderID = NEW.OrderID)
  WHERE o.OrderID = NEW.OrderID;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_orderitems_after_update
AFTER UPDATE ON OrderItems
FOR EACH ROW
BEGIN
  UPDATE Orders o
  SET o.Total = (SELECT IFNULL(SUM(LineTotal),0) FROM OrderItems WHERE OrderID = NEW.OrderID)
  WHERE o.OrderID = NEW.OrderID;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_orderitems_after_delete
AFTER DELETE ON OrderItems
FOR EACH ROW
BEGIN
  UPDATE Orders o
  SET o.Total = (SELECT IFNULL(SUM(LineTotal),0) FROM OrderItems WHERE OrderID = OLD.OrderID)
  WHERE o.OrderID = OLD.OrderID;
END //
DELIMITER ;

-- Optional trigger to audit status changes made outside procedures
DELIMITER //
CREATE TRIGGER trg_bookings_after_update_status
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
  IF OLD.Status <> NEW.Status THEN
    INSERT INTO BookingAudit (BookingID, Action, OldStatus, NewStatus)
    VALUES (NEW.BookingID, 'STATUS_CHANGE', OLD.Status, NEW.Status);
  END IF;
END //
DELIMITER ;
