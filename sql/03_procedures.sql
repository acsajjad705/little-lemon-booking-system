USE little_lemon;

-- 1) GetMaxQuantity
DELIMITER //
CREATE PROCEDURE GetMaxQuantity(OUT max_qty INT)
BEGIN
  SELECT IFNULL(MAX(Quantity), 0) INTO max_qty FROM OrderItems;
END //
DELIMITER ;

-- 2) AddBooking
DELIMITER //
CREATE PROCEDURE AddBooking(
  IN pCustomerID INT,
  IN pTableID INT,
  IN pBookingDate DATE,
  IN pBookingTime TIME,
  IN pGuests INT,
  IN pNotes VARCHAR(255),
  OUT pBookingID INT,
  OUT pMessage VARCHAR(255)
)
BEGIN
  DECLARE vCapacity INT;
  DECLARE vExists INT DEFAULT 0;

  IF pGuests <= 0 THEN
    SET pBookingID = NULL;
    SET pMessage = 'Guests must be greater than zero.';
    LEAVE proc;
  END IF;

  SELECT Capacity INTO vCapacity FROM RestaurantTables WHERE TableID = pTableID;
  IF vCapacity IS NULL THEN
    SET pBookingID = NULL;
    SET pMessage = 'Table does not exist.';
    LEAVE proc;
  END IF;

  IF pGuests > vCapacity THEN
    SET pBookingID = NULL;
    SET pMessage = CONCAT('Guest count exceeds table capacity (', vCapacity, ').');
    LEAVE proc;
  END IF;

  SELECT COUNT(*) INTO vExists
  FROM Bookings
  WHERE TableID = pTableID
    AND BookingDate = pBookingDate
    AND BookingTime = pBookingTime
    AND Status NOT IN ('Cancelled','Completed');

  IF vExists > 0 THEN
    SET pBookingID = NULL;
    SET pMessage = 'Table is not available at the requested date and time.';
    LEAVE proc;
  END IF;

  INSERT INTO Bookings (CustomerID, TableID, BookingDate, BookingTime, Guests, Status, Notes)
  VALUES (pCustomerID, pTableID, pBookingDate, pBookingTime, pGuests, 'Pending', pNotes);

  SET pBookingID = LAST_INSERT_ID();
  SET pMessage = 'Booking added successfully.';

  INSERT INTO BookingAudit (BookingID, Action, OldStatus, NewStatus)
  VALUES (pBookingID, 'ADD', NULL, 'Pending');
END //
DELIMITER ;

-- 3) UpdateBooking
DELIMITER //
CREATE PROCEDURE UpdateBooking(
  IN pBookingID INT,
  IN pBookingDate DATE,
  IN pBookingTime TIME,
  IN pGuests INT,
  IN pNotes VARCHAR(255),
  OUT pMessage VARCHAR(255)
)
BEGIN
  DECLARE vTableID INT;
  DECLARE vCapacity INT;
  DECLARE vExists INT;

  SELECT TableID INTO vTableID FROM Bookings WHERE BookingID = pBookingID;
  IF vTableID IS NULL THEN
    SET pMessage = 'Booking not found.';
    LEAVE proc;
  END IF;

  SELECT Capacity INTO vCapacity FROM RestaurantTables WHERE TableID = vTableID;

  IF pGuests <= 0 THEN
    SET pMessage = 'Guests must be greater than zero.';
    LEAVE proc;
  END IF;

  IF pGuests > vCapacity THEN
    SET pMessage = CONCAT('Guest count exceeds table capacity (', vCapacity, ').');
    LEAVE proc;
  END IF;

  SELECT COUNT(*) INTO vExists
  FROM Bookings
  WHERE TableID = vTableID
    AND BookingDate = pBookingDate
    AND BookingTime = pBookingTime
    AND Status NOT IN ('Cancelled','Completed')
    AND BookingID <> pBookingID;

  IF vExists > 0 THEN
    SET pMessage = 'Requested new slot is unavailable for this table.';
    LEAVE proc;
  END IF;

  UPDATE Bookings
  SET BookingDate = pBookingDate,
      BookingTime = pBookingTime,
      Guests = pGuests,
      Notes = pNotes
  WHERE BookingID = pBookingID;

  SET pMessage = 'Booking updated successfully.';

  INSERT INTO BookingAudit (BookingID, Action)
  VALUES (pBookingID, 'UPDATE');
END //
DELIMITER ;

-- 4) ManageBooking
DELIMITER //
CREATE PROCEDURE ManageBooking(
  IN pBookingID INT,
  IN pNewStatus ENUM('Pending','Confirmed','Seated','Completed','Cancelled'),
  OUT pMessage VARCHAR(255)
)
BEGIN
  DECLARE vOldStatus ENUM('Pending','Confirmed','Seated','Completed','Cancelled');

  SELECT Status INTO vOldStatus FROM Bookings WHERE BookingID = pBookingID;
  IF vOldStatus IS NULL THEN
    SET pMessage = 'Booking not found.';
    LEAVE proc;
  END IF;

  IF vOldStatus = 'Cancelled' THEN
    SET pMessage = 'Cannot change status of a cancelled booking.';
    LEAVE proc;
  END IF;

  IF vOldStatus = 'Completed' AND pNewStatus <> 'Completed' THEN
    SET pMessage = 'Completed bookings cannot revert.';
    LEAVE proc;
  END IF;

  UPDATE Bookings SET Status = pNewStatus WHERE BookingID = pBookingID;
  SET pMessage = CONCAT('Status updated from ', vOldStatus, ' to ', pNewStatus, '.');

  INSERT INTO BookingAudit (BookingID, Action, OldStatus, NewStatus)
  VALUES (pBookingID, 'STATUS_CHANGE', vOldStatus, pNewStatus);
END //
DELIMITER ;

-- 5) CancelBooking
DELIMITER //
CREATE PROCEDURE CancelBooking(
  IN pBookingID INT,
  OUT pMessage VARCHAR(255)
)
BEGIN
  DECLARE vOldStatus ENUM('Pending','Confirmed','Seated','Completed','Cancelled');

  SELECT Status INTO vOldStatus FROM Bookings WHERE BookingID = pBookingID;
  IF vOldStatus IS NULL THEN
    SET pMessage = 'Booking not found.';
    LEAVE proc;
  END IF;

  UPDATE Bookings SET Status = 'Cancelled' WHERE BookingID = pBookingID;

  SET pMessage = 'Booking cancelled successfully.';

  INSERT INTO BookingAudit (BookingID, Action, OldStatus, NewStatus)
  VALUES (pBookingID, 'CANCEL', vOldStatus, 'Cancelled');
END //
DELIMITER ;
