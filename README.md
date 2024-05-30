# Idris Spring Boot Example

An example Idris project demonstrating how to export functions and generate classes from Idris to Java. It is a Spring Boot application connecting to MySQL database.

# Build

### Compile
```shell
./mvnw package
```

### Start MySQL server
```shell
mysql.server start
```

### Initialize MySQL
* From MySQL console
```shell
create database payroll_db;
```
```shell
create user 'payroll_admin'@'%' identified by '<enter password>';
```
```shell
grant all on payroll_db.* to 'payroll_admin'@'%';
```

# Run
* Set MySQL password in `PAYROLL_PASSWORD` environment variable
```shell
read -rs PAYROLL_PASSWORD
export PAYROLL_PASSWORD
```
* Start application
```shell
java -cp "build/exec/idrisspringbootexample_app:target/classes:build/exec/idrisspringbootexample_app/*" io.github.mmhelloworld.helloworld.PayrollApplication
```

