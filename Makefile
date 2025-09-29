
VENV_DIR=venv
ANSIBLE_VERSION=11.10.0

SHELL=/bin/bash
PYTHON=python3

GREEN=\033[32m
YELLOW=\033[33m
RED=\033[31m
RESET=\033[0m

define echo_green
	echo -e "${GREEN}$(1)${RESET}"
endef

define echo_yellow
	echo -e "${YELLOW}$(1)${RESET}"
endef

define echo_red
	echo -e "${RED}$(1)${RESET}"
endef

.check_venv:
	@if [ -d $(VENV_DIR) ] && [ -f $(VENV_DIR)/bin/activate ]; then \
		exit 0; \
	fi; \
	exit 1 2>/dev/null;

clean:
	@rm -rf $(VENV_DIR) && \
		docker compose -f Docker/plateforme.yml down -v --remove-orphans; \

.install_ansible:
	$(call echo_green,"installation of Ansible $(ANSIBLE_VERSION)");
	$(VENV_DIR)/bin/pip3 install ansible==$(ANSIBLE_VERSION);
	@if [ $? -eq 0 ]; then \
		exit 0; \
	exit 1 2>/dev/null;

.deploy_docker:
	@docker compose -f Docker/plateforme.yml up -d

.deploy_interpero:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/interperso-install.yml --tags install

.deploy_interpero_sample:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/interperso-install.yml --tags sample

.deploy_org:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/organique-install.yml --tags install

.deploy_org_sample:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/organique-install.yml --tags sample

.deploy_smtp:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/smtp-install.yml --tags install

.db_init:
	@docker exec -i postgres_17.6 psql -U root -c "CREATE DATABASE roundcube";

.db_init_webmail:
	@docker cp roundcube_webmail:/var/www/html/SQL/postgres.initial.sql /tmp/postgres.initial.sql && \
	 docker exec -i postgres_17.6  psql -U root -d roundcube < /tmp/postgres.initial.sql;
	@rm -f /tmp/postgres.initial.sql;

.db_init_identity_switch:
	@docker exec -i postgres_17.6  psql -U root -d roundcube < Docker/Roundcube/plugins/identity_switch/SQL/postgres.initial.sql;

.db_init_calendar:
	@docker exec -i postgres_17.6  psql -U root -d roundcube < Docker/Roundcube/plugins/libkolab/SQL/postgres.initial.sql;

.db_init_baikal:
	@docker exec -i postgres_17.6 psql -U root -c "CREATE DATABASE sabredav" && \
	 docker cp baikal:/var/www/baikal/Core/Resources/Db/PgSQL/db.sql /tmp/postgres.baikal.sql && \
	 docker exec -i postgres_17.6  psql -U root -d sabredav < /tmp/postgres.baikal.sql;
	@rm -f /tmp//tmp/postgres.baikal.sql;

install:
	@if ! $(MAKE) .check_venv 2>/dev/null; then \
		$(PYTHON) -m venv $(VENV_DIR); \
		$(call echo_green,"virtual env created in '$(VENV_DIR)'"); \
	else \
		$(call echo_yellow,"virtual env '$(VENV_DIR)' already exist"); \
	fi; 
 
	@if $(MAKE) .install_ansible  2>/dev/null; then \
		$(call echo_red,"installation failure"); \
		exit 1; \
	fi; 
	$(call echo_green,"installation success"); 

	$(MAKE) .deploy_docker;
	$(MAKE) .deploy_interpero;
	$(MAKE) .deploy_org;
	$(MAKE) .deploy_smtp;
	$(MAKE) .db_init;
	$(MAKE) .db_init_webmail;
	$(MAKE) .db_init_calendar;
	$(MAKE) .db_init_identity_switch;
	$(MAKE) .db_init_baikal;

init:
	$(MAKE) .deploy_interpero_sample;
	$(MAKE) .deploy_org_sample;


