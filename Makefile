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

#Obter UID e GID do usuario, o if abaixo eh para
#compatibilidade com MacOS
USER_UID = $(shell id -u $(USER))
USER_GID = $(shell id -g $(USER))
ifeq ($(shell uname),Darwin)
	USER_GID = $(shell id -u $(USER))
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
	$(DOCKERCMD) unshare chown $(USER_UID):$(USER_GID) $(SHARED_FOLDER)

start:
	$(DOCKERCMD) run -d --rm -it --name ${CONTAINER_NAME} \
		--cap-add CAP_AUDIT_WRITE  --cap-add  CAP_SYS_PTRACE  \
		-e USER_UID=$(USER_UID) \
		-e USER_GID=$(USER_GID) \
		-v "$(XAUTHORITY):/root/.Xauthority:ro" \
		-v "/tmp/.X11-unix:/tmp/.X11-unix:ro" \
		-v "/etc/machine-id:/etc/machine-id:ro" \
		-v "$(SHARED_FOLDER):/home/user/Downloads:rw" \
		$(IMG)

.PHONY: clean
clean:
	rm -rf build/ 

.PHONY: info 
info:
	@echo "Execute 'make prepare' para que o código possa"
	@echo "ser preparado para compilação no Arduino IDE."

.PHONY: default
default: info ;

logs:
	$(DOCKERCMD) logs -f ${CONTAINER_NAME}

shell:
	$(DOCKERCMD) exec -it ${CONTAINER_NAME} bash

stop:
	-$(DOCKERCMD) kill ${CONTAINER_NAME}

remove:
	-$(DOCKERCMD) image rm ${CONTAINER_NAME}
