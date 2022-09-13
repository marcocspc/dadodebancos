#Check for python 3
EXECUTABLES = python3 podman
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "$(exec) nao esta no PATH. Instale o $(exec) e tente novamente.")))

IMG=dadosdebanco
CONTAINER_NAME=dadosdebanco
DOCKERCMD=podman
SHARED_FOLDER=$(HOME)/dadosdebanco
CONTAINER_UID = 1000
CONTAINER_GID = 1000
TZ=America/Fortaleza

#Obter UID e GID do usuario, o if abaixo eh para
#compatibilidade com MacOS
USER_UID = $(shell id -u $(USER))
USER_GID = $(shell id -g $(USER))
PLATFORM = linux
ifeq ($(shell uname),Darwin)
	USER_GID = $(shell id -u $(USER))
	PLATFORM = mac
endif


##### ALVOS ######


.DEFAULT_GOAL := info

.PHONY: build
build:
	$(DOCKERCMD) build -t ${IMG} \
		--build-arg UID_ARG=$(CONTAINER_UID) \
		--build-arg GID_ARG=$(CONTAINER_GID) \
		.
	mkdir -p $(SHARED_FOLDER)
	ifeq ($(PLATFORM),linux)
		$(DOCKERCMD) unshare chown $(USER_UID):$(USER_GID) $(SHARED_FOLDER)
	endif

.PHONY: start-debug
start-debug:
	$(DOCKERCMD) run -d --rm -it --name ${CONTAINER_NAME} \
		--cap-add CAP_AUDIT_WRITE  --cap-add  CAP_SYS_PTRACE  \
		--net=host \
		-e USER_UID=$(USER_UID) \
		-e USER_GID=$(USER_GID) \
		-e DISPLAY=$(DISPLAY) \
		-e DEBUG="1" \
		-e TZ=$TZ \
		-v "$(XAUTHORITY):/root/.Xauthority:ro" \
		-v "/tmp/.X11-unix:/tmp/.X11-unix:ro" \
		-v "/etc/machine-id:/etc/machine-id:ro" \
		-v "$(SHARED_FOLDER):/home/user:rw" \
		$(IMG)

.PHONY: clean
clean: stop remove ;

.PHONY: info 
info:
	@echo "make build constroi a imagem."
	@echo "make start-debug inicia o container debug para geração de novos scripts, debug, etc. Ele possui gui, ao contrário do padrão."
	@echo "make logs mostra os logs do container."
	@echo "make clean remove o container e a imagem."
	@echo "make shell te coloca em um terminal dentro do container."
	@echo "make stop para o container."
	@echo "make remove para e apaga o container."


.PHONY: default
default: info ;

.PHONY: logs
logs:
	$(DOCKERCMD) logs -f ${CONTAINER_NAME}

.PHONY: shell
shell:
	$(DOCKERCMD) exec -it ${CONTAINER_NAME} bash

.PHONY: stop
stop:
	$(DOCKERCMD) kill ${CONTAINER_NAME}

.PHONY: remove
remove:
	$(DOCKERCMD) image rm ${CONTAINER_NAME}

.PHONY: rebuild
rebuild: build ;
