## Spring Boot Web Application
This document provides instructions on how to build the Spring Boot web application, how to create machine image in Packer, and how to use git actions to implement CI pipeline.

# Prerequisites
Please githave the following installed on your system:  
Server Operating System: CentOS 8  
Java JDK 21 or newer vgitersion  
Maven: This project uses Maven for dependency management   
MySQL: The project uses MySQL as the database for data management   
Git   
Packer  

# Build and Deploy
git clone https://yourrepositoryurl.git  
cd your-project-directory    
mvn clean install  
cd target/  
java -jar your-application-name.jar  
When you run the application:  
the application will start can be accessed at http://localhost:8080.


 
