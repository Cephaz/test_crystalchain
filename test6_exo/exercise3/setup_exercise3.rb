require 'sqlite3'

db = SQLite3::Database.new 'crystalchain_test.db'

db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS DEPARTMENT (
    ID INTEGER PRIMARY KEY,
    NAME TEXT,
    LOCATION TEXT
  );
SQL

db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS EMPLOYEE (
    ID INTEGER PRIMARY KEY,
    NAME TEXT,
    SALARY INTEGER,
    DEPT_ID INTEGER,
    FOREIGN KEY (DEPT_ID) REFERENCES DEPARTMENT(ID)
  );
SQL

db.execute <<-SQL
  INSERT INTO DEPARTMENT (ID, NAME, LOCATION) VALUES
  (1, 'Executive', 'Sydney'),
  (2, 'Production', 'Sydney'),
  (3, 'Resources', 'Cape Town'),
  (4, 'Technical', 'Texas'),
  (5, 'Management', 'Paris');
SQL

db.execute <<-SQL
  INSERT INTO EMPLOYEE (ID, NAME, SALARY, DEPT_ID) VALUES
  (1, 'Candice', 4685, 1),
  (2, 'Julia', 2559, 2),
  (3, 'Bob', 4405, 4),
  (4, 'Scarlet', 2350, 1),
  (5, 'Ileana', 1151, 4);
SQL

puts 'fake db run'
