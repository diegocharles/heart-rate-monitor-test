CREATE DATABASE heart_rate_monitor_production;
CREATE USER heart_rate_monitor WITH PASSWORD 'postgres';
GRANT ALL PRIVILEGES ON DATABASE heart_rate_monitor_production TO heart_rate_monitor;
ALTER DATABASE heart_rate_monitor_production OWNER TO heart_rate_monitor;
