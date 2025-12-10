USE little_lemon;

-- Customers
CREATE TABLE IF NOT EXISTS Customers (
  CustomerID INT AUTO_INCREMENT PRIMARY KEY,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  Email VARCHAR(120) UNIQUE NOT NULL,
  Phone VARCHAR(20),
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staff
CREATE TABLE IF NOT EXISTS Staff (
  StaffID INT AUTO_INCREMENT PRIMARY KEY,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  Role VARCHAR(50) NOT NULL,
  Email VARCHAR(120) UNIQUE,
  Active TINYINT(1) DEFAULT 1
);

-- Tables
CREATE TABLE IF NOT EXISTS RestaurantTables (
  TableID INT AUTO_INCREMENT PRIMARY KEY,
  TableNumber INT NOT NULL UNIQUE,
  Capacity INT NOT NULL,
  Location VARCHAR(50) DEFAULT 'Main',
  CONSTRAINT chk_capacity CHECK (Capacity > 0)
);

-- Menu items
CREATE TABLE IF NOT EXISTS MenuItems (
  MenuItemID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(100) NOT NULL,
  Category VARCHAR(50) NOT NULL,
  Price DECIMAL(8,2) NOT NULL,
  Active TINYINT(1) DEFAULT 1
);

-- Bookings
CREATE TABLE IF NOT EXISTS Bookings (
  BookingID INT AUTO_INCREMENT PRIMARY KEY,
  CustomerID INT NOT NULL,
  TableID INT NOT NULL,
  StaffID INT NULL,
  BookingDate DATE NOT NULL,
  BookingTime TIME NOT NULL,
  Guests INT NOT NULL,
  Status ENUM('Pending','Confirmed','Seated','Completed','Cancelled') DEFAULT 'Pending',
  Notes VARCHAR(255),
  CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
  FOREIGN KEY (TableID) REFERENCES RestaurantTables(TableID),
  FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
  CONSTRAINT chk_guests CHECK (Guests > 0),
  INDEX idx_booking_window (BookingDate, BookingTime, TableID)
);

-- Orders
CREATE TABLE IF NOT EXISTS Orders (
  OrderID INT AUTO_INCREMENT PRIMARY KEY,
  CustomerID INT NOT NULL,
  BookingID INT NULL,
  OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Status ENUM('Pending','Preparing','Served','Closed','Cancelled') DEFAULT 'Pending',
  Total DECIMAL(10,2) DEFAULT 0.00,
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
  FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

-- Order items (UnitPrice snapshot ensures historical revenue correctness)
CREATE TABLE IF NOT EXISTS OrderItems (
  OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT NOT NULL,
  MenuItemID INT NOT NULL,
  Quantity INT NOT NULL,
  UnitPrice DECIMAL(8,2) NOT NULL,
  LineTotal DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID),
  CONSTRAINT chk_quantity CHECK (Quantity > 0)
);

-- Audit log
CREATE TABLE IF NOT EXISTS BookingAudit (
  AuditID BIGINT AUTO_INCREMENT PRIMARY KEY,
  BookingID INT NOT NULL,
  Action ENUM('ADD','UPDATE','CANCEL','STATUS_CHANGE') NOT NULL,
  OldStatus ENUM('Pending','Confirmed','Seated','Completed','Cancelled'),
  NewStatus ENUM('Pending','Confirmed','Seated','Completed','Cancelled'),
  ChangedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ChangedBy VARCHAR(100) DEFAULT 'system',
  FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);
