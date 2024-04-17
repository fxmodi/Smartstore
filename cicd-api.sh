#!/bin/bash

# Reflik klfhsdighsh

##########################################################################################################################################################
#
#TESTSIGMA_API_KEY-->API key generated under Testsigma App-->Configuration-->API Keys
#TESTSIGMA_TEST_PLAN_ID--> Testsigma Testplan ID, U can get this ID from Testsigma_app-->Test Plans--><TEST_PLAN_NAME>-->CI/CD Integration
#MAX_WAIT_TIME_FOR_SCRIPT_TO_EXIT-->Maximum time the script will wait for TEST Plan execution to complete. The sctript will exit if the Maximum time
#is exceeded, however the Test Plan will continue to run. You can check test results by logging to Testsigma.
#REPORT_FILE_PATH-->File path to save report Ex: <DIR_PATH>/report.xml, ./report.xml

##########################################################################################################################################################
# START USER INPUTS #

TESTSIGMA_API_KEY="eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI0MDdiYWU0MC01OWViLTRjZGMtOTIxNy03NTBkNWU4ZTFhYWMiLCJkb21haW4iOiJleHByZXNzcHJvcy5jb20iLCJ0ZW5hbnRJZCI6NjQ4MDd9.hfFzWdVUnNptwIyYXXUG1zVBr-JLsgnbZfUadFDSsCjAvv3op7Ie7zJCSqqJ-_y1lJihrh15Y2HUJLMBPLtD4Q"
TESTSIGMA_TEST_PLAN_ID="47"
REPORT_FILE_PATH="./junit-report.pdf"
MAX_WAIT_TIME_FOR_SCRIPT_TO_EXIT=300

# END USER INPUTS #


TESTSIGMA_TEST_PLAN_REST_URL="https://app.testsigma.com/api/v1/execution_results"
TESTSIGMA_JUNIT_REPORT_URL="https://app.testsigma.com/api/v1/reports/junit"

POLL_INTERVAL_FOR_RUN_STATUS=1
NO_OF_POLLS=$((MAX_WAIT_TIME_FOR_SCRIPT_TO_EXIT / POLL_INTERVAL_FOR_RUN_STATUS))
SLEEP_TIME=$((POLL_INTERVAL_FOR_RUN_STATUS * 60))
LOG_CONTENT=""
APP_URL=""
EXECUTION_STATUS=-1
RUN_ID=""
IS_TEST_RUN_COMPLETED=-1

function get_status {
    RUN_RESPONSE=$(curl -s -X GET -H "Authorization: Bearer $TESTSIGMA_API_KEY" -H "Accept: application/json" -H "Content-Type: application/json" "$status_URL")
    EXECUTION_STATUS=$(echo "$RUN_RESPONSE" | jq -r '.status')
    APP_URL=$(echo "$RUN_RESPONSE" | jq -r '.app_url')
    echo "Execution Status: $EXECUTION_STATUS"
}

function checkTestPlanRunStatus {
    IS_TEST_RUN_COMPLETED=0
    for ((i=0; i<=NO_OF_POLLS; i++)); do
        get_status
        echo "Execution Status before going for wait: $EXECUTION_STATUS ,Status_message:" "$(echo "$RUN_RESPONSE" | jq -r '.message')"
        if [ "$EXECUTION_STATUS" == "STATUS_IN_PROGRESS" ]; then
            echo "Sleep/Wait for $SLEEP_TIME seconds before next poll....."
            sleep "$SLEEP_TIME"
        else
            IS_TEST_RUN_COMPLETED=1
            echo "Automated Tests Execution completed... Total script execution time: $((i * SLEEP_TIME / 60)) minutes"
            break
        fi
    done
}
  
function saveFinalResponseToAFile {
    if [ "$IS_TEST_RUN_COMPLETED" -eq 0 ]; then
        LOG_CONTENT="Wait time exceeded specified maximum time(MAX_WAIT_TIME_FOR_SCRIPT_TO_EXIT). Please visit below URL for Test Plan Run status. $APP_URL"
        echo "LogContent: $LOG_CONTENT Response content: $(echo "$RUN_RESPONSE" | jq -c)" 
    else
        echo "Fetching reports: $TESTSIGMA_JUNIT_REPORT_URL/$RUN_ID"
        REPORT_DATA=$(curl -s -X GET -H "Authorization: Bearer $TESTSIGMA_API_KEY" -H "Accept: application/xml" -H "Content-Type: application/json" "$TESTSIGMA_JUNIT_REPORT_URL/$RUN_ID")
        echo "report data: $REPORT_DATA"
        echo "$REPORT_DATA" > "$REPORT_FILE_PATH"
    fi
    echo "Reports File: $REPORT_FILE_PATH"
}

echo "No of polls: $NO_OF_POLLS"
echo "Polling Interval: $SLEEP_TIME"
echo "Junit report file path: $REPORT_FILE_PATH"

REQUEST_BODY='{"executionId":'"$TESTSIGMA_TEST_PLAN_ID"'}'
TRIGGER_RESPONSE=$(curl -s -X POST -H "Authorization: Bearer $TESTSIGMA_API_KEY" -H "Accept: application/json" -H "Content-Type: application/json" -d "$REQUEST_BODY" "$TESTSIGMA_TEST_PLAN_REST_URL")

RUN_ID=$(echo "$TRIGGER_RESPONSE" | jq -r '.id')
echo "Execution triggered RunID: $RUN_ID"  
status_URL="$TESTSIGMA_TEST_PLAN_REST_URL/$RUN_ID"
echo "$status_URL"

checkTestPlanRunStatus
saveFinalResponseToAFile
