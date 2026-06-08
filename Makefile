.PHONY: up down restart logs status shell exec backup help

up:       ## Build and start ComfyUI stack
	docker compose up --build -d

down:     ## Stop and remove containers
	docker compose down

restart:  ## Restart the stack
	$(MAKE) down && $(MAKE) up

logs:     ## Tail container logs (use l=comfyui to filter)
	docker compose logs -f $(l)

status:   ## Show container status and resource usage
	@echo "=== Container status ===" && docker compose ps && echo "" && echo "=== Resource usage ===" && docker stats --no-stream comfyui 2>/dev/null || echo "Container not running."

shell:    ## Open a shell inside the container
	docker compose exec comfyui bash

exec:     ## Run a command inside the container (e.g. make exec c="ls -la")
	docker compose exec comfyui $(c)

backup:   ## Backup user data (excludes model weights)
	@scripts/backup.sh

help:     ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
