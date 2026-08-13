docker-compose -f docker-compose.test.yml build
docker-compose -f docker-compose.test.yml run --rm test
docker-compose -f docker-compose.test.yml down
