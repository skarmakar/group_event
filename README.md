# README

User can CRUD some group events. Group events can be created with any one attribute, but to publish, need all the attributes, name, description
start date, end date, location name etc.

# TODO

- Add a React FE app to manage this
- Dockerize and deploy in AWS Fargate

## Prerequisite

* Ruby 2.7.3
* PostgreSQL 13.2
* RVM

## Setup

* Update database.yml with proper credentials
* Run `rails db:setup` to create the database and 10 group events
* Run specs: `rspec spec`

## APIs

* APIs can be browsed in the browser by visiting `http://localhost:3000/api/v1/group_events`
