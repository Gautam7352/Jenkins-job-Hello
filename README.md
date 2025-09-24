Create a custom Docker image that extends the base Jenkins image. This new image will have Python and your script already baked in,
 and we'll pre-configure the job so it exists as soon as you run the container.

Here are the components you'll need:

Dockerfile: The script to build your custom Docker image.

plugins.txt: A file listing the Jenkins plugins to install.

script.py: Your Python script.

config.xml: The Jenkins job configuration file.

## Step 1: Prepare Your Project Directory
Create a folder for your project and organize it like this:

jenkins-python-job/
├── Dockerfile
├── script.py
└── config.xml

## Step 2: Create the Files
Dockerfile
This file is the core of the setup. It uses the official Jenkins image as a base, then installs Python, copies your files, and installs the necessary Jenkins plugins.

Dockerfile

# Use the official Jenkins LTS image as a base
FROM jenkins/jenkins:lts-jdk11

# Switch to the root user to install packages
USER root

# Install Python and pip
RUN apt-get update && apt-get install -y python3

# Copy your Python script into the image
COPY script.py /usr/src/app/script.py

# Switch back to the jenkins user
USER jenkins

# Install Jenkins plugins from plugins.txt
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# Copy the pre-configured job XML file into Jenkins' jobs directory
COPY config.xml /usr/share/jenkins/ref/jobs/Python-Script-Runner/config.xml

script.py
This is your actual Python script. Let's create a simple one for this example.

Python

# script.py
import datetime

print(f"Hello from Python! The current time is: {datetime.datetime.now()}")


# config.xml
This is the Jenkins job definition. The easiest way to get this file is to configure a job once manually in the Jenkins UI (as described in the previous answer), and then copy the config.xml file that Jenkins generates.

You can find it on your running Jenkins container at: 
/var/jenkins_home/jobs/YOUR_JOB_NAME/config.xml.

Here is an example "config.xml" for a job named "Python-Script-Runner" that runs every minute and executes our Python script:

XML

<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description>A job to run a Python script.</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers>
    <hudson.triggers.TimerTrigger>
      <spec>* * * * *</spec>
    </hudson.triggers.TimerTrigger>
  </triggers>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.tasks.Shell>
      <command>python3 /usr/src/app/script.py</command>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>


## Step 3: Build and Run the Docker Image 🚀
Now that all your files are ready, navigate to your jenkins-python-job directory in your terminal and follow these steps.

1. Build the Docker Image: This command builds your custom image and tags it as my-jenkins.

Bash

docker build -t my-jenkins .


2. Run Your Custom Jenkins Container: Now, run a container from your new image.

Bash

docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home my-jenkins


## What Happens Next?
Once you start this container, go to http://localhost:8080. After the initial setup (getting the admin password), you will see that your job, "Python-Script-Runner", is already created and configured! Because the schedule is set to * * * * *, it will start running within a minute. You can check the "Console Output" of a build to see the print statement from your Python script.

This approach is far more robust for production environments because your entire Jenkins setup is version-controlled and can be easily rebuilt and deployed.