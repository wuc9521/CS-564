package MysqlDemo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.CallableStatement;
import java.sql.Types;

public class SimpleStoreProcedureDemo {

	 static final String databasePrefix ="university";
	 static final String netID ="sqluser"; // Please enter your netId
	 static final String hostName ="localhost"; //washington.uww.edu
	 static final String databaseURL ="jdbc:mysql://"+hostName+"/"+databasePrefix+"?autoReconnect=true&useSSL=false";
	 static final String password="mypass"; // please enter your own password
	  		    
	private Connection connection = null;
	private Statement statement = null;
	private ResultSet resultSet = null;

	public void Connection(){

		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			System.out.println("databaseURL"+ databaseURL);
			connection = DriverManager.getConnection(databaseURL, netID, password);
			System.out.println("Successfully connected to the database");
		}
		catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		catch (SQLException e) {
			e.printStackTrace();
		}
	} // end of Connection

	public void simpleStoreProcedure(String spName) {

	try {
		statement = connection.createStatement();
		int total =0;
		CallableStatement myCallStmt = connection.prepareCall("{call "+spName+"(?)}");
        myCallStmt.registerOutParameter(1,Types.BIGINT);
        myCallStmt.execute();
        total = myCallStmt.getInt(1);
        System.out.println("The total student ="+ total);

	}
	catch (SQLException e) {
		e.printStackTrace();
	}
} // end of simpleQuery method

/*
 
delimiter $$
drop procedure if exists getTotalStudent;
create procedure getTotalStudent(INOUT total int) 
begin 
      select count(*) into total
      from student;
end $$
delimiter ; 

*/
	
	
public static void main(String args[]) {

	SimpleStoreProcedureDemo demoObj = new SimpleStoreProcedureDemo();
	demoObj.Connection();
	String spName ="getTotalStudent";
	demoObj.simpleStoreProcedure(spName);
}



}

