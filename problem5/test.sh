PORT=${APP_PORT:-3333}
BASE_URL="http://localhost:$PORT/api/users"
TEMP_ID="123456789123456789123456"

echo "Test case: Creating a new user: Success case..."
CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" -H "Content-Type: application/json" -d '{"name": "Vien Nguyen", "mail": "vien.nguyen@example.com", "dayOfBirth": "1996-04-06", "job": "Software Engineer"}')
status=$(printf '%s' "$CREATE_RESPONSE" | tail -n1)
if [ "$status" -ne 201 ]; then
    echo "Test case failed: Expected status code 201, but got $status"
    exit 1
fi
echo "Test case passed: Status code 201\nResponse: $(printf '%s' "$CREATE_RESPONSE" | head -n -1)\n"
USER_ID=$(echo "$(printf '%s' "$CREATE_RESPONSE" | head -n -1)" | jq -r '._id')

echo "Test case: Creating a new user: Missing required fields: name..."
CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" -H "Content-Type: application/json" -d '{"mail": "vien.nguyen@example.com", "dayOfBirth": "1996-04-06", "job": "Software Engineer"}')
status=$(printf '%s' "$CREATE_RESPONSE" | tail -n1)
if [ "$status" -ne 400 ]; then
    echo "Test case failed: Expected status code 400, but got $status"
    exit 1
fi
echo "Test case passed: Status code 400\nResponse: $(printf '%s' "$CREATE_RESPONSE" | head -n -1)\n"

echo "Test case: Creating a new user: Missing required fields: mail..."
CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" -H "Content-Type: application/json" -d '{"name": "Vien Nguyen", "dayOfBirth": "1996-04-06", "job": "Software Engineer"}')
status=$(printf '%s' "$CREATE_RESPONSE" | tail -n1)
if [ "$status" -ne 400 ]; then
    echo "Test case failed: Expected status code 400, but got $status"
    exit 1
fi
echo "Test case passed: Status code 400\nResponse: $(printf '%s' "$CREATE_RESPONSE" | head -n -1)\n"

echo "Test case: Creating a new user: Missing required fields: dayOfBirth..."
CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" -H "Content-Type: application/json" -d '{"name": "Vien Nguyen", "mail": "vien.nguyen@example.com", "job": "Software Engineer"}')
status=$(printf '%s' "$CREATE_RESPONSE" | tail -n1)
if [ "$status" -ne 400 ]; then
    echo "Test case failed: Expected status code 400, but got $status"
    exit 1
fi
echo "Test case passed: Status code 400\nResponse: $(printf '%s' "$CREATE_RESPONSE" | head -n -1)\n"

echo "Test case: Creating a new user: Missing un-required fields: job..."
CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" -H "Content-Type: application/json" -d '{"name": "Vien Nguyen", "mail": "vien.nguyen@example.com", "dayOfBirth": "1996-04-06"}')
status=$(printf '%s' "$CREATE_RESPONSE" | tail -n1)
if [ "$status" -ne 201 ]; then
    echo "Test case failed: Expected status code 201, but got $status"
    exit 1
fi
echo "Test case passed: Status code 201\nResponse: $(printf '%s' "$CREATE_RESPONSE" | head -n -1)\n"

echo "Test case: Get all users..."
GET_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL")
status=$(printf '%s' "$GET_RESPONSE" | tail -n1)
if [ "$status" -ne 200 ]; then
    echo "Test case failed: Expected status code 200, but got $status"
    exit 1
fi
echo "Test case passed: Status code 200\nResponse: $(printf '%s' "$GET_RESPONSE" | head -n -1)\n"


curl -s -o /dev/null -X POST $BASE_URL -H "Content-Type: application/json" -d '{"name":"Vien","mail":"vien@example.com","dayOfBirth":"1996-04-06","job":"Software Engineer"}'
curl -s -o /dev/null -X POST $BASE_URL -H "Content-Type: application/json" -d '{"name":"Anna","mail":"anna@example.com","dayOfBirth":"1995-01-01","job":"Designer"}'
curl -s -o /dev/null -X POST $BASE_URL -H "Content-Type: application/json" -d '{"name":"Viktor","mail":"vik@example.com","dayOfBirth":"1990-02-02","job":"Software Architect"}'
sleep 1
echo "Test case: Get users with filters: name=vi"
GET_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL?name=vi")
status=$(printf '%s' "$GET_RESPONSE" | tail -n1)
if [ "$status" -ne 200 ]; then
    echo "Test case failed: Expected status code 200, but got $status"
    exit 1
fi
echo "Test case passed: Status code 200\nResponse: $(printf '%s' "$GET_RESPONSE" | grep -o '"name":"[^"]*"')\n"

echo "Test case: Get users with filters: job=software"
GET_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL?job=software")
status=$(printf '%s' "$GET_RESPONSE" | tail -n1)
if [ "$status" -ne 200 ]; then
    echo "Test case failed: Expected status code 200, but got $status"
    exit 1
fi
echo "Test case passed: Status code 200\nResponse: $(printf '%s' "$GET_RESPONSE" | grep -o '"name":"[^"]*"')\n"

echo "Test case: Get users with filters: pagination page=1 limit=2"
GET_RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL?limit=2&page=1")
status=$(printf '%s' "$GET_RESPONSE" | tail -n1)
if [ "$status" -ne 200 ]; then
    echo "Test case failed: Expected status code 200, but got $status"
    exit 1
fi
echo "Test case passed: Status code 200\nResponse: $(printf '%s' "$GET_RESPONSE" | grep -o '"meta":{[^}]*}')\n"

echo "Test case: Get a specific user..."
GET_USER_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/$USER_ID")
status=$(printf '%s' "$GET_USER_RESPONSE" | tail -n1)
if [ "$status" -ne 200 ]; then
    echo "Test case failed: Expected status code 200, but got $status"
    exit 1
fi
echo "Test case passed: Status code 200\nResponse: $(printf '%s' "$GET_USER_RESPONSE" | head -n -1)\n"

echo "Test case: Get a user: with unexist id..."
GET_USER_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/$TEMP_ID")
status=$(printf '%s' "$GET_USER_RESPONSE" | tail -n1)
if [ "$status" -ne 404 ]; then
    echo "Test case failed: Expected status code 404, but got $status"
    exit 1
fi
echo "Test case passed: Status code 404\nResponse: $(printf '%s' "$GET_USER_RESPONSE" | head -n -1)\n"

echo "Test case: Get a user: with invalid id..."
GET_USER_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/invalid_id")
status=$(printf '%s' "$GET_USER_RESPONSE" | tail -n1)
if [ "$status" -ne 500 ]; then
    echo "Test case failed: Expected status code 500, but got $status"
    exit 1
fi
echo "Test case passed: Status code 500\n"

echo "Test case: Update a specific user..."
UPDATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$BASE_URL/$USER_ID" -H "Content-Type: application/json" -d '{"name": "Vien Nguyen Updated", "mail": "vien.nguyen.updated@example.com"}')
status=$(printf '%s' "$UPDATE_RESPONSE" | tail -n1)
if [ "$status" -ne 200 ]; then
    echo "Test case failed: Expected status code 200, but got $status"
    exit 1
fi
echo "Test case passed: Status code 200\nResponse: $(printf '%s' "$UPDATE_RESPONSE" | head -n -1)\n"

echo "Test case: Update a user: with unexist id..."
UPDATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$BASE_URL/$TEMP_ID" -H "Content-Type: application/json" -d '{"name": "Vien Nguyen Updated", "mail": "vien.nguyen.updated@example.com"}')
status=$(printf '%s' "$UPDATE_RESPONSE" | tail -n1)
if [ "$status" -ne 404 ]; then
    echo "Test case failed: Expected status code 404, but got $status"
    exit 1
fi
echo "Test case passed: Status code 404\nResponse: $(printf '%s' "$UPDATE_RESPONSE" | head -n -1)\n"

echo "Test case: Update a user: with unexist id..."
UPDATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "$BASE_URL/invalid_id" -H "Content-Type: application/json" -d '{"name": "Vien Nguyen Updated", "mail": "vien.nguyen.updated@example.com"}')
status=$(printf '%s' "$UPDATE_RESPONSE" | tail -n1)
if [ "$status" -ne 500 ]; then
    echo "Test case failed: Expected status code 500, but got $status"
    exit 1
fi
echo "Test case passed: Status code 500\n"

echo "Test case: Delete a specific user..."
DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/$USER_ID")
status=$(printf '%s' "$DELETE_RESPONSE" | tail -n1)
if [ "$status" -ne 200 ]; then
    echo "Test case failed: Expected status code 200, but got $status"
    exit 1
fi
echo "Test case passed: Status code 200\nResponse: $(printf '%s' "$DELETE_RESPONSE" | head -n -1)\n"

echo "Test case: Delete a user: with unexist id..."
DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/$TEMP_ID")
status=$(printf '%s' "$DELETE_RESPONSE" | tail -n1)
if [ "$status" -ne 404 ]; then
    echo "Test case failed: Expected status code 404, but got $status"
    exit 1
fi
echo "Test case passed: Status code 404\nResponse: $(printf '%s' "$DELETE_RESPONSE" | head -n -1)\n"

echo "Test case: Delete a user: with invalid id..."
DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/invalid_id")
status=$(printf '%s' "$DELETE_RESPONSE" | tail -n1)
if [ "$status" -ne 500 ]; then
    echo "Test case failed: Expected status code 500, but got $status"
    exit 1
fi
echo "Test case passed: Status code 500\n"


