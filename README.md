# Little Lemon Booking System

A full booking, ordering, and reporting stack for Little Lemon:
- MySQL database with ERD and schema
- Stored procedures: GetMaxQuantity(), ManageBooking(), UpdateBooking(), AddBooking(), CancelBooking()
- Python client that connects, calls procedures, and reacts to changes
- Tableau workbook for dashboards with provided views

## Setup

**Prerequisites:**
- MySQL 8.x
- Python 3.10+
- Tableau Desktop (or Tableau Public)
- MySQL ODBC or native Tableau MySQL connector

**Steps:**
1. Import SQL in order:
   - `sql/00_create_database.sql`
   - `sql/01_tables.sql`
   - `sql/02_triggers.sql`
   - `sql/03_procedures.sql`
   - `sql/04_views.sql`
   - `sql/99_sample_data.sql`
2. Create `.env` in `app/` based on `.env.example`.
3. Install Python dependencies:
   ```bash
   pip install mysql-connector-python python-dotenv
