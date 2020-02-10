# Upwork reader
Upwork RSS feed parser and analyzer based on ELK stack
# Requirements
1. Docker Compose
2. Slack with configured webhook if you want to enable notifications for any RSS feed
# Install
1. `mv config-example.yml config.yml`
2. Fill in it with correct values
3. `docker-compose up -d`
4. Access kibana with http://localhost:5601
