syntax on
filetype plugin indent on
autocmd BufRead,BufNewFile *.sh set filetype=sh
autocmd BufNewFile *.sh call append(0, '#!/bin/bash')
augroup ansible_playbook
  autocmd!
  autocmd BufNewFile *.yml,*.yaml call append(0, [
        \ '---',
        \ '- name: NameOfPlayBook            # The name given to this playbook',
        \ '  hosts: all                      # Which hosts to run this playbook on',
        \ '  # become: true                  # Privileged escalation needed',
        \ '  # become_user: root             # Become this user for privileged escalation',
        \ '  # gather_facts: true            # Gathers information from the managed host that are stored in ansible variables',
        \ '  # remote_user: root             # Ansible connects as this user',
        \ '  # connection: ssh               # How to connect to mananged hosts',
        \ '  # vars:                         # Set variables that will be used in the playbook',
        \ '  #   http_port: 8080',
        \ '  tasks:',
        \ '    - name: Example task',
        \ '      debug:',
        \ '        msg: "Hello, Ansible!"',
        \ '  #   - name: Install Apache',
        \ '  #     package:',
        \ '  #       name: httpd',
        \ '  #       state: present',
        \ '  #   - name: Change Apache listen port to 8080',
        \ '  #     ansible.builtin.lineinfile:',
        \ '  #       path: /etc/httpd/conf/httpd.conf',
        \ '  #       regexp: '^Listen ',
        \ '  #       line: 'Listen "{{ http_port | int }}"   # Quote the {{ variable_name }} and cast the value as an integer',
        \ '  #       backup: yes',
        \ '  #   - name: Start Apache',
        \ '  #     service:',
        \ '  #       name: httpd',
        \ '  #       state: started',
        \ '  #       enabled: true'
        \ ])
augroup END
set tabstop=2 
set shiftwidth=2
set softtabstop=2
set expandtab   
set autoindent
set smartindent
set showmatch

