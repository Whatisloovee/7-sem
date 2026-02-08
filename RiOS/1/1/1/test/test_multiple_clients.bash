#!/bin/bash

echo "Starting server..."
./bin/server &
SERVER_PID=$!

sleep 2

echo "Starting multiple clients..."
./bin/client 127.0.0.1 1000 &
CLIENT1_PID=$!

./bin/client 127.0.0.1 1500 &
CLIENT2_PID=$!

./bin/client 127.0.0.1 2000 &
CLIENT3_PID=$!

echo "Clients started with PIDs: $CLIENT1_PID, $CLIENT2_PID, $CLIENT3_PID"
echo "Server PID: $SERVER_PID"
echo "Press Ctrl+C to stop all processes"

wait