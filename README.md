
# How to start it:

1. Using DockerContainer

  Just make sure you have VSCode or Cursor installed on your development machine,

## Using DevContainer for Rails Development

### Prerequisites
- [Docker](https://www.docker.com/products/docker-desktop) installed on your machine
- [Visual Studio Code](https://code.visualstudio.com/) or [Cursor](https://cursor.sh/) installed
- [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension installed in VS Code

### Getting Started

1. Clone this repository to your local machine
2. Open the project folder in VS Code or Cursor
3. When prompted, click "Reopen in Container" or use the command palette (F1) and select "Remote-Containers: Reopen in Container"
4. The first build may take a few minutes as it downloads and sets up the Rails environment
5. Once the container is running, you can access the Rails application at http://localhost:3000

### Container Features
- Ruby and Rails configured for this specific project
- SQLite3 database
- Pre-configured development environment without JavaScript dependencies

### Common Commands
- Start the Rails server: `rails s -b 0.0.0.0`
- Run database migrations: `rails db:migrate`
- Access the Rails console: `rails c`
- Run tests: `rails test`

### Troubleshooting
If you encounter any issues with the DevContainer:
- Rebuild the container: Command Palette → "Remote-Containers: Rebuild Container"
- Check Docker is running properly on your host machine
- Verify port 3000 is not in use by another application



# Code Test

This document outlines a programming evaluation which will test your ability to put together a simple full-stack Rails application. There are a few core components that you will be expected to implement, and some room for your own approach to tackling the problem. The estimated time required for this test is 3 hours.

## Main Task:

Download the data dump at [https://assets.benny.ai/code-test/heart-rate-monitor/data.zip](https://assets.benny.ai/code-test/heart-rate-monitor/data.zip).

You have been given a large CSV dump of (fake) users and their accompanying heart rate monitor (HRM) data (data format is detailed below). Your task will be to take this data and build a Rails app that provides a visualization and reporting interface. This task is meant to evaluate both your front-end and back-end skills. How well you create the UI/UX of the reporting interface, along with how optimally your Rails app operates on the large data-set, will be taken into account.

*You should spend a maximum of 3 hours on this test. The desired features are:*

* Display a listing of all HRM sessions in order of most recently created, showing for each:
  * Mininimum, maximum, and average heart rate.
  * The Amount of time in each heart rate zone for the the associated user.
  * A visualization of the HRM data-points over the entire session.
* Display the overall mininimum, maximum, and average heart rate for all HRM sessions.
* Display the % of time spent in each heart rate zone across all users.

## Guidelines:

* You must use Ruby on Rails as the core web platform.
* You may translate the CSV data into other formats if you wish, you are also free to modify the schema as long as it doesn't alter the nature of the task at hand.
* You are free to use whatever Gems or CSS and JavaScript extensions/frameworks you find useful.
* It's OK if you do not have time to build all features, but be prepared to walk us through your thoughts and strategy.
* Don't worry about setting up user authentication or worrying about security issues in general.
* Performance issues should be a concern to you - wouldn't want a slow request hanging up production would ya?
* Some aspects are left intentionally vague to allow you creative freedom - take this task and run with it, it should demonstrate who you are as a programmer.
* You own whatever code you write, and are free to do whatever you want with it.
* You can deliver your final app to us however you want, but it should be easy for us to get it running and play with the end-result.

## Data Schema

There are 3 separate CSV files that contain data that is relational to one another.

"users.csv" - Contains fake user data. Each user has numbers that define their "heart rate zones." The numbers for each specific user's heart rate zones will be tied to the HRM data for reporting purposes. If you're not familiar with heart rate zones, it's simply a way for an individual to know what their heart rate should be to maintaint a desired intensity level during exercise, and is provided here as a set of numerical ranges provided min/max values for each zone/range.

    Columns:
      User ID (Integer): The unique identifier.
      Created At (Timestamp): When the user record was created.
      Username (String): The unique username.
      Gender (String): male/female.
      Age (Integer): The age in years of the user.
      HR Zone1 BPM Min (Integer): The BPM lower bound (inclusive) of this user's 1st heart rate zone.
      HR Zone1 BPM Max (Integer): The BPM upper bound (inclusive) of this user's 1st heart rate zone.
      HR Zone2 BPM Min (Integer): The BPM lower bound (inclusive) of this user's 2nd heart rate zone.
      HR Zone2 BPM Max (Integer): The BPM upper bound (inclusive) of this user's 2nd heart rate zone.
      HR Zone3 BPM Min (Integer): The BPM lower bound (inclusive) of this user's 3rd heart rate zone.
      HR Zone3 BPM Max (Integer): The BPM upper bound (inclusive) of this user's 3rd heart rate zone.
      HR Zone4 BPM Min (Integer): The BPM lower bound (inclusive) of this user's 4th heart rate zone.
      HR Zone4 BPM Max (Integer): The BPM upper bound (inclusive) of this user's 4th heart rate zone.


"hrm_sessions.csv" - Mimics a "session" of when a user hooked up a HRM and fed data into the system. This can be thought of as a join table between Users and HRM data points.

    Columns:
      Session ID (Integer): The unique identifier.
      User ID (Integer): The User ID this session is associated with.
      Created At (Timestamp): When the session was created.
      Duration in Secs (Integer): How long the session lasted.

"hrm\_data\_points.csv" - Contains timestamped HRM beats per minute (BPM) readings that associate back to a unique HRM session. Each HRM Session has many data points that form a time series of heart rate data. Each BPM reading is for a short but variable period of time (typically 1-5 seconds). Note that when calculating average BPM, the time duration of each reading should be taken into account.

    Columns:
      Session ID (Integer): The Session ID this data point is assocaited with.
      Beats Per Minute (Integer): The BPM reading over the given time period.
      Reading Start Time (Timestamp): The start of the timeframe for this BPM reading.
      Reading End Time (Timestamp): The end of the timeframe for this BPM reading.
      Duration in Secs (Integer): The End Time - Start Time.
