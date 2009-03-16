Feature: service starts cluster
  As a service
  I want to start a cluster
  So that I can store my values
  Scenario: start cluster
    Given there is no running cluster
    When I start a cluster
    Then the process table should contain 1 or more erl processes