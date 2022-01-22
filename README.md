<img src="https://related.chat/relatedchat/header1.png">

<img src="https://related.chat/relatedchat/pricing1.png">

<img src="https://related.chat/relatedchat/product2.png">

# Installation instructions

You can install RelatedChat on any servers (Windows, Linux or macOS), by using Docker. Just download the Docker Compose file to your computer and initiate the process.

```
curl -o docker-compose.yml https://gqlite.com/relatedchat/docker-compose.yml

docker-compose up -d
```

Make sure to change all the sensitive values in your YAML file before building your server.

```yaml
environment:
  DB_HOST: pg
  DB_PORT: 5432
  DB_DATABASE: gqlserver
  DB_USER: gqlserver
  DB_PASSWORD: gqlserver

  CACHE_HOST: rd
  CACHE_PORT: 6379
  CACHE_PASSWORD: gqlserver

  MINIO_ROOT_USER: gqlserver
  MINIO_ROOT_PASSWORD: gqlserver

  ADMIN_EMAIL: admin@example.com
  ADMIN_PASSWORD: gqlserver

  SECRET_KEY: f2e85774-9a3b-46a5-8170-b40a05ead6ef
```

---

© Related Code 2022 - All Rights Reserved
