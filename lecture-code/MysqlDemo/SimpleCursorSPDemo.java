package MysqlDemo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.CallableStatement;
import java.sql.Types;

public class SimpleCursorSPDemo {

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

	public void simpleCursorSP(String spName) {

	try {
		statement = connection.createStatement();
		String listName;
		CallableStatement myCallStmt = connection.
				prepareCall("{call "+spName+"(?)}");
	    myCallStmt.setString(1,"");
	    myCallStmt.registerOutParameter(1,Types.VARCHAR);
        myCallStmt.execute();
        listName = myCallStmt.getString(1);
        System.out.println("The student names are : \n"+listName);

    }
	catch (SQLException e) {
		e.printStackTrace();
	}
} // end of simpleQuery method

public static void main(String args[]) {

	SimpleCursorSPDemo demoObj = new SimpleCursorSPDemo();
	demoObj.Connection();
	String spName ="getClassInfo21";
	demoObj.simpleCursorSP(spName);
}

}

