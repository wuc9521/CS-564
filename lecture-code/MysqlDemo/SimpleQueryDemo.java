package MysqlDemo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;

public class SimpleQueryDemo {

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
	    
	    public void simpleQuery(String sqlQuery) {
	    
	    	try {
	    		statement = connection.createStatement();
	    		resultSet = statement.executeQuery(sqlQuery);

	    		ResultSetMetaData metaData = resultSet.getMetaData();
	    		int columns = metaData.getColumnCount();

	    		for (int i=1; i<= columns; i++) {
	    			System.out.print(metaData.getColumnName(i)+"\t");
	    		}

	    		System.out.println();

	    		while (resultSet.next()) {
	       
	    			for (int i=1; i<= columns; i++) {
	    				System.out.print(resultSet.getObject(i)+"\t\t");
	    			}
	    			System.out.println();
	    		}
	    	}
	    	catch (SQLException e) {
	    		e.printStackTrace();
	    	}
	    } // end of simpleQuery method
	    
	    public static void main(String args[]) {
	
	    	SimpleQueryDemo demoObj = new SimpleQueryDemo();
	    	demoObj.Connection();
	    	String sqlQuery ="select sname from student where level = 'JR';";
	    	demoObj.simpleQuery(sqlQuery);
	    }
	    
	
	
}


