@echo off
echo Getting backend IPs...
echo.
echo Backend A:
aws ecs list-tasks --cluster todoapp-cluster --service-name todoapp-backend-a --region us-east-2 > tasks-a.json
aws ecs describe-tasks --cluster todoapp-cluster --tasks $(type tasks-a.json | findstr "task/") --region us-east-2 > task-details-a.json
echo.
echo Backend B:
aws ecs list-tasks --cluster todoapp-cluster --service-name todoapp-backend-b --region us-east-2 > tasks-b.json
aws ecs describe-tasks --cluster todoapp-cluster --tasks $(type tasks-b.json | findstr "task/") --region us-east-2 > task-details-b.json
echo.
echo Check task-details-a.json and task-details-b.json for IP addresses
pause
