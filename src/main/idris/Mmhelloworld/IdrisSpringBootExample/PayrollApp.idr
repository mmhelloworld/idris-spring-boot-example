module Mmhelloworld.IdrisSpringBootExample.PayrollApp

import Control.App
import Org.Springframework.Context
import Org.Springframework.Data.Jpa.Repository
import Mmhelloworld.IdrisSpringBootExample.PayrollStore
import System.FFI
import Java.Lang
import Java.Util

public export
interface PayrollApp e where
    saveEmployee : Employee -> App e Employee
    getEmployees : App e (JList Employee)

public export
Has [App.PrimIO, SpringContextAware] e => PayrollApp e where
    saveEmployee employee = do
        employeeRepository <- getBean (classLiteral {ty=EmployeeRepository})
        primIO $ save {entity=Employee} {id=Int64} (subtyping employeeRepository) employee

    getEmployees = do
        employeeRepository <- getBean (classLiteral {ty=EmployeeRepository})
        primIO $ findAll {id=Int64} (subtyping employeeRepository)

export
initDatabase : Has [PayrollApp] e => App e ()
initDatabase = do
    ignore $ saveEmployee $ Employee.new "Bilbo Baggins" "burglar"
    ignore $ saveEmployee $ Employee.new "Frodo Baggins" "thief"