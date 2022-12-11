#Check for python 3
EXECUTABLES := python3 podman
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "$(exec) nao esta no PATH. Instale o $(exec) e tente novamente.")))

IMG:=dadosdebanco
CONTAINER_NAME:=dadosdebanco
DOCKERCMD:=podman
SHARED_FOLDER:=$(PWD)/chromium_downloads
CHROMIUM_DATA:=$(PWD)/chromium_data
CONTAINER_UID := 1000
CONTAINER_GID := 1000
TZ := America/Fortaleza

#Obter UID e GID do usuario, o if abaixo eh para
#compatibilidade com MacOS
USER_UID := $(shell id -u $(USER))
USER_GID := $(shell id -g $(USER))
PLATFORM := linux
ifeq ($(shell uname),Darwin)
	USER_GID := $(shell id -u $(USER))
	PLATFORM := mac
	XAUTHORITY := $(HOME)/.Xauthority
	DISPLAY := :0
	NETWORK_INTERFACE := en0
	CONTAINER_UID := $(USER_UID)
	CONTAINER_GID := $(USER_GID)
endif


##### ALVOS ######


.DEFAULT_GOAL := info

.PHONY: build
build:
	$(DOCKERCMD) build -t ${IMG} \
		--build-arg TZ=$(TZ) \
		--build-arg UID_ARG=$(CONTAINER_UID) \
		--build-arg GID_ARG=$(CONTAINER_GID) \
		.
	mkdir -p $(SHARED_FOLDER)
	mkdir -p $(CHROMIUM_DATA)
	@if [ "$(PLATFORM)" = "linux" ] ; then \
		$(DOCKERCMD) unshare chown -r $(USER_UID).$(USER_GID) $(SHARED_FOLDER); \
		$(DOCKERCMD) unshare chown -r $(USER_UID).$(USER_GID) $(CHROMIUM_DATA); \
	fi

.PHONY: start
start: start-debug

.PHONY: start-debug
start-debug:
	@if [ "$(PLATFORM)" = "mac" ] ; then \
		$(eval IP := $(shell ifconfig $(NETWORK_INTERFACE) |  grep inet | tail -1 | awk '{ print $$2 }')) \
		xhost + $(IP) ;  \
		export DISPLAY=$(IP):$(DISPLAY); \
	fi
	$(DOCKERCMD) run -d --rm -it --name ${CONTAINER_NAME} \
		--cap-add CAP_AUDIT_WRITE  --cap-add  CAP_SYS_PTRACE  \
		--net=host \
		-e USER_UID=$(USER_UID) \
		-e USER_GID=$(USER_GID) \
		-e DISPLAY=$(IP)$(DISPLAY) \
		-e DEBUG="1" \
		-e TZ=$(TZ) \
		-v "$(XAUTHORITY):/root/.Xauthority:ro" \
		-v "/tmp/.X11-unix:/tmp/.X11-unix:ro" \
		-v "/etc/machine-id:/etc/machine-id:ro" \
		-v "$(SHARED_FOLDER):/home/user/Downloads:rw" \
		-v "$(CHROMIUM_DATA):/home/user/.config/chromium/Default:rw" \
		$(IMG)
	$(DOCKERCMD) exec ${CONTAINER_NAME} lxterminal

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

.PHONY: rm
rm: remove

.PHONY: remove
remove:
	$(DOCKERCMD) container stop ${CONTAINER_NAME}
	$(DOCKERCMD) container rm ${CONTAINER_NAME}
	rm -rf $(SHARED_FOLDER)
	rm -rf $(CHROMIUM_DATA)

.PHONY: rebuild
rebuild: build ;
